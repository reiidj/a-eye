import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:a_eye/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

enum CataractType { immature, mature }

class ResultsPage extends StatefulWidget {
  final String imagePath;
  final String userName;
  final double prediction;
  final CataractType cataractType;

  const ResultsPage({
    super.key,
    required this.userName,
    required this.prediction,
    required this.imagePath,
    required this.cataractType,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String? _permanentImagePath;

  @override
  void initState() {
    super.initState();
    // Run the file operation after the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _makeImagePathPermanent();
    });
  }

  /// Copies the image from its temporary location to permanent storage
  /// and updates the database record.
  Future<void> _makeImagePathPermanent() async {
    // Ensure the temporary file exists before proceeding
    final tempFile = File(widget.imagePath);
    if (!await tempFile.exists()) {
      // If the temp file is gone, just use what we have
      setState(() {
        _permanentImagePath = widget.imagePath;
      });
      return;
    }

    // Get the app's permanent documents directory
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.png';
    final permanentPath = p.join(directory.path, fileName);

    // Copy the file to the new permanent path
    await tempFile.copy(permanentPath);

    // Update the database record with the new path
    final database = Provider.of<AppDatabase>(context, listen: false);
    final latestScan = await database.getLatestScan();

    if (latestScan != null) {
      final updatedScan = latestScan.toCompanion(true).copyWith(
        imagePath: drift.Value(permanentPath),
      );
      await database.updateScan(updatedScan);
    }

    // Update the UI with the new path
    if (mounted) {
      setState(() {
        _permanentImagePath = permanentPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use the new permanent path if available, otherwise fallback to the old one
    final displayPath = _permanentImagePath ?? widget.imagePath;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
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
              // Top bar
              Container(
                width: double.infinity,
                height: screenHeight * 0.1149,
                color: const Color(0xFF131A21),
                alignment: Alignment.center,
                child: Text(
                  "Eye Health Report",
                  style: GoogleFonts.urbanist(
                    color: const Color(0xFF5E7EA6),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable content
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Main diagnosis box
                        _buildDiagnosisBox(screenWidth, displayPath), // Pass the path
                        SizedBox(height: widget.cataractType == CataractType.immature ? 32 : 16),

                        // Medical disclaimer
                        _buildMedicalDisclaimer(),
                        SizedBox(height: widget.cataractType == CataractType.immature ? 32 : 16),

                        // Action buttons
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

  // --- Helper Widgets ---
  // (These remain mostly the same, but now accept the image path)

  Widget _buildDiagnosisBox(double screenWidth, String imagePath) {
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
          _buildEyeImage(screenWidth, imagePath), // Use the passed path
        ],
      ),
    );
  }

  Widget _buildEyeImage(double screenWidth, String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      // Show a loading indicator while the permanent path is being set
      child: _permanentImagePath == null
          ? SizedBox(
        width: screenWidth * 0.5,
        height: screenWidth * 0.5,
        child: const Center(child: CircularProgressIndicator()),
      )
          : imagePath.isNotEmpty && File(imagePath).existsSync()
          ? Image.file(
        File(imagePath),
        width: screenWidth * 0.5,
        height: screenWidth * 0.5,
        fit: BoxFit.cover,
      )
          : Image.asset( // Fallback
        'assets/images/Immature.png',
        width: screenWidth * 0.5,
        height: screenWidth * 0.5,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    if (widget.cataractType == CataractType.immature) {
      // This part is already responsive, so no changes are needed here.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF362D1A),
          borderRadius: BorderRadius.circular(24),
        ),
        // FittedBox ensures the text scales down if it's too long
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
      // This is where the fix is applied for the mature cataract case.
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x26FF6767),
          borderRadius: BorderRadius.circular(24),
        ),
        // By wrapping the Row with FittedBox, the contents will scale down
        // to fit the available width, preventing any text wrapping.
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
              const SizedBox(width: 8), // Added a bit more space
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
    if (widget.cataractType == CataractType.immature) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.urbanist(
            fontSize: 15,
            color: Colors.white,
          ),
          children: const [
            TextSpan(
              text: "The uploaded eye image exhibits characteristics consistent with an immature cataract. ",
            ),
            TextSpan(
              text: "Constant monitoring ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: "of cataract is advisable. You can opt for surgical removal if it affects your daily life.",
            ),
          ],
        ),
      );
    } else {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.urbanist(
            fontSize: 15,
            color: Colors.white,
          ),
          children: const [
            TextSpan(
              text: "The scanned eye shows characteristics of a mature cataract. Due to high lens opacity, ",
            ),
            TextSpan(
              text: "surgical removal is recommended",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: ". Please consult an ophthalmologist for further evaluation and to discuss options.",
            ),
          ],
        ),
      );
    }
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

          // Visit PAO Box
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
    if (widget.cataractType == CataractType.mature) {
      // Mature cataract shows both buttons
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                const url = 'https://pao.org.ph';
                try {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error opening website'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5244F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                "Notify Eye Specialist",
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildConfirmExitButton(context),
        ],
      );
    } else {
      // Immature cataract shows only exit button
      return _buildConfirmExitButton(context);
    }
  }

  Widget _buildConfirmExitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
              (route) => false,
          arguments: {'userName': widget.userName},
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF5244F3), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          "Confirm & Exit Report",
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}