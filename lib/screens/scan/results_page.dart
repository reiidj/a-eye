import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:a_eye/services/pdf_builder.dart';
import 'dart:typed_data';
// firebase
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a_eye/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CataractType { immature, mature }

class ResultsPage extends StatelessWidget {
  final String userName;
  final String confidence;
  final String explainedImageBase64;
  final String explanationText;
  final CataractType cataractType;

  const ResultsPage({
    Key? key,
    required this.userName,
    required this.confidence,
    required this.explainedImageBase64,
    required this.explanationText,
    required this.cataractType,
  }) : super(key: key);

  String get _title => cataractType == CataractType.mature ? "Mature Cataract Detected" : "Immature Cataract Detected";
  String get _description {
    return cataractType == CataractType.mature
        ? "The scanned eye shows characteristics of a mature cataract. Due to high lens opacity, surgical removal is recommended. Please consult an ophthalmologist for further evaluation and to discuss options."
        : "The uploaded eye image exhibits characteristics consistent with an immature cataract. Constant monitoring of cataract is advisable. You can opt for surgical removal if it affects your daily life.";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Results BG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                height: screenHeight * 0.1149,
                color: const Color(0xFF131A21),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    "Eye Health Report",
                    style: GoogleFonts.urbanist(
                      color: const Color(0xFF5E7EA6),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDiagnosisBox(screenWidth, explainedImageBase64),
                        SizedBox(height: cataractType == CataractType.immature ? 32 : 16),
                        _buildMedicalDisclaimer(),
                        SizedBox(height: cataractType == CataractType.immature ? 32 : 16),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _savePdfToDownloads(BuildContext context) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final downloadsDirectoryPath = Platform.isAndroid
            ? '/storage/emulated/0/Download'
            : directory.path;

        final downloadsDir = Directory(downloadsDirectoryPath);
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final pdfBytes = await generateReportPdf(
          userName: userName,
          classification: cataractType == CataractType.mature ? "Mature Cataract" : "Immature Cataract",
          confidence: confidence,
          explanationText: explanationText,
        );

        final fileName = 'A-EYE_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
        final filePath = '${downloadsDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report saved to Downloads folder!')),
          );
        }
      } catch (e) {
        print("Error saving PDF: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save report.')),
          );
        }
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to save the report.')),
        );
      }
    }
  }

  Widget _buildConfirmExitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.download_for_offline_outlined),
        label: Text(
          "Save Report & Exit",
          style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        onPressed: () async {
          // Show a loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saving result...')),
          );

          // 1. Save the PDF locally
          await _savePdfToDownloads(context);

          // 2. Upload Image and Save Data to Firestore
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              // --- START: NEW IMAGE UPLOAD LOGIC ---
              // Convert base64 string to image data
              final Uint8List imageBytes = base64Decode(explainedImageBase64);
              final String imageName = 'scan_${DateTime.now().millisecondsSinceEpoch}.png';

              // Create a reference to Firebase Storage
              final Reference storageRef = FirebaseStorage.instance
                  .ref()
                  .child('scans/${user.uid}/$imageName');

              // Upload the data
              final uploadTask = storageRef.putData(imageBytes);
              final snapshot = await uploadTask.whenComplete(() => {});

              // Get the public URL
              final String imageUrl = await snapshot.ref.getDownloadURL();
              // --- END: NEW IMAGE UPLOAD LOGIC ---

              final firestoreService = FirestoreService();
              final classification = cataractType == CataractType.mature ? "Mature Cataract" : "Immature Cataract";

              // Prepare the data with the new image URL
              final scanData = {
                'result': classification,
                'confidence': confidence,
                'timestamp': FieldValue.serverTimestamp(),
                'imagePath': imageUrl, // Use the new URL here
              };

              await firestoreService.addScan(user.uid, scanData);
            }
          } catch (e) {
            print("Error saving to Firestore or Storage: $e");
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not save result to your history.')),
              );
            }
          }

          // 3. Navigate away
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
                  (route) => false,
              arguments: {'userName': userName},
            );
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF5244F3), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }


  Widget _buildDiagnosisBox(double screenWidth, String explainedImageBase64) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStatusIndicator(),
          const SizedBox(height: 12),
          _buildDescriptionText(),
          const SizedBox(height: 16),
          _buildEyeImage(screenWidth, explainedImageBase64),
        ],
      ),
    );
  }

  Widget _buildEyeImage(double screenWidth, String explainedImageBase64) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.memory(
        base64Decode(explainedImageBase64),
        width: screenWidth * 0.5,
        height: screenWidth * 0.5,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: screenWidth * 0.5,
            height: screenWidth * 0.5,
            color: Colors.grey,
            child: const Icon(Icons.error, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (cataractType == CataractType.immature) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF362D1A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Immature Cataract Detected",
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE69146),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x26FF6767),
          borderRadius: BorderRadius.circular(24),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFDD0000),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                "Mature Cataract Detected",
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDD0000),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDescriptionText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.urbanist(
          fontSize: 15,
          color: Colors.white,
        ),
        children: cataractType == CataractType.immature
            ? const [
          TextSpan(text: "The uploaded eye image exhibits characteristics consistent with an immature cataract. "),
          TextSpan(text: "Constant monitoring ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "of cataract is advisable. You can opt for surgical removal if it affects your daily life."),
        ]
            : const [
          TextSpan(text: "The scanned eye shows characteristics of a mature cataract. Due to high lens opacity, "),
          TextSpan(text: "surgical removal is recommended", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ". Please consult an ophthalmologist for further evaluation and to discuss options."),
        ],
      ),
    );
  }

  Widget _buildMedicalDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131A21),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "Medical Disclaimer",
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5244F3),
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.urbanist(
                fontSize: 15,
                color: Colors.white,
              ),
              children: const [
                TextSpan(text: "This app is for informational purposes only. It does "),
                TextSpan(
                  text: "not replace a licensed ophthalmologist's diagnosis.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF242443),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.campaign_rounded,
                  color: Color(0xFF5244F3),
                  size: 32,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.urbanist(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      children: const [
                        TextSpan(text: "Visit "),
                        TextSpan(
                          text: "pao.org.ph",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF8BC36A),
                          ),
                        ),
                        TextSpan(
                          text: " to find certified eye specialists for proper eye analysis.",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (cataractType == CataractType.mature) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final url = Uri.parse('https://a-eye-cataract-classification-tool.github.io/A-EYE-Website/doctors.html');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch website')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5244F3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                "Notify Eye Specialist",
                style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildConfirmExitButton(context),
        ],
      );
    } else {
      return _buildConfirmExitButton(context);
    }
  }
}