import 'dart:convert';
import 'dart:io';
import 'package:a_eye/services/firestore_service.dart';
import 'package:a_eye/services/pdf_builder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum CataractType { immature, mature }

class ResultsPage extends StatelessWidget {
  final String userName;
  final double confidence;
  final double classificationScore;
  final String explainedImageBase64;
  final String explanationText;
  final CataractType cataractType;

  const ResultsPage({
    super.key,
    required this.userName,
    required this.confidence,
    required this.classificationScore,
    required this.explainedImageBase64,
    required this.explanationText,
    required this.cataractType,
  });

  String get _title =>
      cataractType == CataractType.mature
          ? "Mature Cataract Detected"
          : "Immature Cataract Detected";

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

  Widget _buildScoreDisplays(double screenWidth) {
    return Column(
      children: [
        Text(
          "Confidence in Result",
          style: GoogleFonts.urbanist(
            color: Colors.white70,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${(confidence * 100).toStringAsFixed(2)}%',
          style: GoogleFonts.urbanist(
            color: const Color(0xFF5244F3),
            fontSize: screenWidth * 0.08,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        Text(
          "Raw Classification Score",
          style: GoogleFonts.urbanist(
            color: Colors.white54,
            fontSize: screenWidth * 0.035,
          ),
        ),
        Text(
          '(${(classificationScore * 100).toStringAsFixed(2)}% used to determine maturity)',
          textAlign: TextAlign.center,
          style: GoogleFonts.urbanist(
            color: Colors.white54,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ],
    );
  }

  Widget _buildEyeImage(double screenWidth, String explainedImageBase64) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.memory(
        base64Decode(explainedImageBase64),
        width: screenWidth * 0.6,
        height: screenWidth * 0.6,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
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

  Widget _buildStatusIndicator(double screenWidth) {
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

  Widget _buildMedicalDisclaimer(double screenWidth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
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
          Text(
            "This app is for informational purposes only and does not replace a licensed ophthalmologist's diagnosis.",
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontSize: screenWidth * 0.04,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, double screenWidth) {
    return Column(
      children: [
        if (cataractType == CataractType.mature)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.group_add_outlined),
              label: Text(
                "Find an Eye Specialist",
                style: GoogleFonts.urbanist(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
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
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
              ),
            ),
          ),
        if (cataractType == CataractType.mature)
          SizedBox(height: screenWidth * 0.03),
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
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () async {
          await _savePdfAndExit(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF5244F3), width: 2),
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
        ),
      ),
    );
  }

  // --- Action Handlers ---

  Future<void> _savePdfAndExit(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF report...')),
    );

    try {
      final confidenceString = '${(confidence * 100).toStringAsFixed(2)}%';
      final classificationScoreString = '${(classificationScore * 100).toStringAsFixed(2)}%';

      final pdfBytes = await generateReportPdf(
        userName: userName,
        classification:
        cataractType == CataractType.mature ? "Mature" : "Immature",
        confidence: confidenceString,
        explanationText: explanationText,
        classificationScore: classificationScoreString,
      );

      final fileName =
          'A-EYE_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      await File(filePath).writeAsBytes(pdfBytes);

      await Share.shareXFiles([XFile(filePath)], text: 'A-Eye Cataract Report');

      if (context.mounted) {
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