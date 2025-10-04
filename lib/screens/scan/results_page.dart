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
                  padding: EdgeInsets.only(top: screenHeight * 0.03),
                  child: Text(
                    "Eye Health Report",
                    style: GoogleFonts.urbanist(
                      color: const Color(0xFF5E7EA6),
                      fontSize: screenWidth * 0.0625,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDiagnosisBox(screenWidth, explainedImageBase64),
                        SizedBox(height: cataractType == CataractType.immature ? screenHeight * 0.04 : screenHeight * 0.02),
                        _buildMedicalDisclaimer(screenWidth),
                        SizedBox(height: cataractType == CataractType.immature ? screenHeight * 0.04 : screenHeight * 0.02),
                        _buildActionButtons(context, screenWidth),
                        SizedBox(height: screenHeight * 0.02),
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

  Widget _buildConfirmExitButton(BuildContext context, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(
          Icons.download_for_offline_outlined,
          size: screenWidth * 0.06,
        ),
        label: Text(
          "Save Report & Exit",
          style: GoogleFonts.urbanist(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saving PDF report...')),
          );

          await _savePdfToDownloads(context);

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
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
        ),
      ),
    );
  }

  Widget _buildDiagnosisBox(double screenWidth, String explainedImageBase64) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.08,
        screenWidth * 0.05,
        screenWidth * 0.08,
        screenWidth * 0.05,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStatusIndicator(screenWidth),
          SizedBox(height: screenWidth * 0.03),
          _buildDescriptionText(screenWidth),
          SizedBox(height: screenWidth * 0.04),
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

  Widget _buildStatusIndicator(double screenWidth) {
    if (cataractType == CataractType.immature) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenWidth * 0.01,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF362D1A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Immature Cataract Detected",
            style: GoogleFonts.urbanist(
              fontSize: screenWidth * 0.05,
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
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.01,
        ),
        decoration: BoxDecoration(
          color: const Color(0x26FF6767),
          borderRadius: BorderRadius.circular(24),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_rounded,
                color: const Color(0xFFDD0000),
                size: screenWidth * 0.07,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Mature Cataract Detected",
                style: GoogleFonts.urbanist(
                  fontSize: screenWidth * 0.05,
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

  Widget _buildDescriptionText(double screenWidth) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.urbanist(
          fontSize: screenWidth * 0.0375,
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

  Widget _buildMedicalDisclaimer(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.08,
        screenWidth * 0.025,
        screenWidth * 0.08,
        screenWidth * 0.025,
      ),
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
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5244F3),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.urbanist(
                fontSize: screenWidth * 0.0375,
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
          SizedBox(height: screenWidth * 0.04),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF242443),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: const Color(0xFF5244F3),
                  size: screenWidth * 0.08,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.urbanist(
                        fontSize: screenWidth * 0.0375,
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

  Widget _buildActionButtons(BuildContext context, double screenWidth) {
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
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
              ),
              child: Text(
                "Notify Eye Specialist",
                style: GoogleFonts.urbanist(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          _buildConfirmExitButton(context, screenWidth),
        ],
      );
    } else {
      return _buildConfirmExitButton(context, screenWidth);
    }
  }
}