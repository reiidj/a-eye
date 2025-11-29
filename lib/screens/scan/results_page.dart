/*
 * Program Title: results_page.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is located in `lib/screens/scan/` and represents the final
 *   stage of the "Analysis Flow". After the `AnalyzingPage` processes the data,
 *   this screen receives the classification results, confidence scores, and
 *   the AI-generated visualization (heatmap/contour). It is responsible for
 *   presenting these findings in a user-friendly medical report format,
 *   providing health disclaimers, and integrating with the `PdfBuilder` service
 *   to generate and share a downloadable PDF report.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To visualize the AI's diagnosis clearly, educate the user on the findings
 *   (Mature vs Immature), and provide actionable next steps (Find a Doctor or
 *   Save Report).
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * CataractType (Enum): Strongly types the classification result to handle
 *       UI logic (Color coding, Warning icons) consistently.
 *     * String (explainedImageBase64): Holds the visualization image data
 *       returned by the Python backend.
 *
 *   Algorithms:
 *     * Base64 Decoding: Converts the backend's string image response into a
 *       renderable Flutter Image widget.
 *     * PDF Generation: Aggregates user data and analysis results to create
 *       a persistent document via `PdfBuilder`.
 *
 *   Control:
 *     * Asynchronous Sharing: Manages file I/O to save the generated PDF to
 *       temporary storage before invoking the native share sheet.
 *     * External Linking: Uses `url_launcher` to redirect users to external
 *       medical directories.
 */


import 'dart:convert';
import 'dart:io';
import 'package:a_eye/services/pdf_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enum: CataractType
/// Purpose: strict typing for the two possible classification outcomes.
enum CataractType { immature, mature }

/// Class: ResultsPage
/// Purpose: Stateless widget that displays the final analysis report.
class ResultsPage extends StatelessWidget {
  // -- INPUT PARAMETERS --
  final String userName;
  final double confidence;
  final double classificationScore;
  final String explainedImageBase64; // The AI-annotated image
  final String explanationText;      // Detailed textual analysis
  final CataractType cataractType;   // Classification enum

  const ResultsPage({
    super.key,
    required this.userName,
    required this.confidence,
    required this.classificationScore,
    required this.explainedImageBase64,
    required this.explanationText,
    required this.cataractType,
  });

  // -- LOGIC: DYNAMIC TITLE --
  String get _title =>
      cataractType == CataractType.mature
          ? "Mature Cataract Detected"
          : "Immature Cataract Detected";

  @override
  Widget build(BuildContext context) {
    // -- ALGORITHM: RESPONSIVE SIZING --
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // -- UI COMPONENT: BACKGROUND --
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
          // -- UI COMPONENT: MAIN SCROLLABLE CONTENT --
          Column(
            children: [
              // Header Bar
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
                      color: Colors.white,
                      fontSize: screenWidth * 0.0625,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildDiagnosisBox(context, screenWidth, explainedImageBase64),
                      SizedBox(height: screenHeight * 0.03),
                      _buildMedicalDisclaimer(screenWidth),
                      SizedBox(height: screenHeight * 0.03),
                      _buildActionButtons(context, screenWidth),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Widget Build Methods ---

  /// Helper: Builds the main card containing image, score, and status.
  Widget _buildDiagnosisBox(
      BuildContext context, double screenWidth, String explainedImageBase64) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStatusIndicator(screenWidth),
          SizedBox(height: screenWidth * 0.04),
          _buildDescriptionText(screenWidth),
          SizedBox(height: screenWidth * 0.05),
          _buildScoreDisplays(screenWidth),
          SizedBox(height: screenWidth * 0.05),
          _buildEyeImage(screenWidth, explainedImageBase64),
        ],
      ),
    );
  }

  /// Helper: Formats and displays the confidence percentage.
  Widget _buildScoreDisplays(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.1,
        vertical: screenWidth * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(width: screenWidth * 0.02),
              Text(
                "Confidence Score:",
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Right side: The score with enhanced styling
          Text(
            '${(confidence * 100).toStringAsFixed(1)}%', // Algorithm: Format double to percentage string
            style: GoogleFonts.urbanist(
              color: const Color(0xFF5244F3),
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.bold,
              shadows: [ // A subtle glow effect for emphasis
                Shadow(
                  blurRadius: 10.0,
                  color: const Color(0xFF8BC36A).withOpacity(0.5),
                  offset: Offset.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper: Decodes and displays the Base64 image string.
  Widget _buildEyeImage(double screenWidth, String explainedImageBase64) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.memory(
        // Algorithm: Decode Base64 to Uint8List for rendering
        base64Decode(explainedImageBase64),
        width: screenWidth * 0.6,
        height: screenWidth * 0.6,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback UI if decoding fails
          return Container(
            width: screenWidth * 0.6,
            height: screenWidth * 0.6,
            color: Colors.grey[800],
            child: const Icon(Icons.error, color: Colors.white),
          );
        },
      ),
    );
  }

  /// Helper: Builds the colored status bar (Red/Warning or Orange/Immature).
  Widget _buildStatusIndicator(double screenWidth) {
    // Control: Branching logic for color/icon based on CataractType
    final bool isMature = cataractType == CataractType.mature;
    final color = isMature ? const Color(0x26FF6767) : const Color(0xFF362D1A);
    final textColor = isMature ? const Color(0xFFDD0000) : const Color(0xFFE69146);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMature)
            Icon(
              Icons.warning_rounded,
              color: textColor,
              size: screenWidth * 0.06,
            ),
          if (isMature) SizedBox(width: screenWidth * 0.02),
          Flexible(
            child: Text(
              _title,
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText(double screenWidth) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.urbanist(
          fontSize: screenWidth * 0.04,
          color: Colors.white,
          height: 1.5,
        ),
        children: [
          TextSpan(text: "The eye image shows characteristics of "),
          TextSpan(
            text: cataractType == CataractType.mature ? "a mature " : "an immature ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: "cataract. "),
          TextSpan(
            text: cataractType == CataractType.mature
                ? "Surgical removal is recommended. "
                : "Constant monitoring is advisable. ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(
              text: "Please consult an ophthalmologist for further evaluation.")
        ],
      ),
    );
  }

  /// Helper: Displays liability and legal disclaimers.
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
    return Column(
      children: [
        // Logic: Only show specialist notification for Mature cataracts
        if (cataractType == CataractType.mature)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.group_add_outlined),
              label: Text(
                "Notify Eye Specialist",
                style: GoogleFonts.urbanist(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                // Control: Launch external URL
                final url = Uri.parse('https://a-eye-cataract-classification-tool.github.io/A-EYE-Website/doctors.html');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5244F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
              ),
            ),
          ),
        if (cataractType == CataractType.mature)
          SizedBox(height: screenWidth * 0.05),
        _buildConfirmExitButton(context, screenWidth),
      ],
    );
  }

  Widget _buildConfirmExitButton(BuildContext context, double screenWidth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon:
        Icon(Icons.download_for_offline_outlined, size: screenWidth * 0.06),
        label: Text(
          "Save Report & Exit",
          style: GoogleFonts.urbanist(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () async {
          // Trigger Async PDF generation
          await _savePdfAndExit(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF5244F3), width: 2),
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
        ),
      ),
    );
  }

  // --- Action Handlers ---

  /*
   * Function: _savePdfAndExit
   * Purpose: Generates a PDF, saves it locally, shares it, and exits.
   */
  Future<void> _savePdfAndExit(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF report...')),
    );

    try {
      final confidenceString = '${(confidence * 100).toStringAsFixed(2)}%';
      final classificationScoreString = '${(classificationScore * 100).toStringAsFixed(2)}%';

      // -- ALGORITHM: PDF GENERATION --
      // Call the PdfBuilder service (defined in another module)
      final pdfBytes = await generateReportPdf(
        userName: userName,
        classification:
        cataractType == CataractType.mature ? "Mature" : "Immature",
        confidence: confidenceString,
        explanationText: explanationText,
        classificationScore: classificationScoreString,
      );

      // -- ALGORITHM: FILE I/O --
      // Create a temporary file with a timestamped name
      final fileName =
          'A-EYE_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      await File(filePath).writeAsBytes(pdfBytes);

      // -- CONTROL: SHARE SHEET --
      await Share.shareXFiles([XFile(filePath)], text: 'A-Eye Cataract Report');

      if (context.mounted) {
        // Control: Reset Navigation Stack to Welcome Screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
              (route) => false,
          arguments: {'userName': userName},
        );
      }
    } catch (e) {
      print("Error saving/sharing PDF: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
    }
  }
}