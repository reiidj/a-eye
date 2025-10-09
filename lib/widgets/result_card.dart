import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:a_eye/services/pdf_builder.dart';

class ResultCard extends StatefulWidget {
  final String date;
  final String title;
  final String? imageAsset;
  final String? imageFilePath;
  final bool showLabel;

  // FIXED: Updated parameters to match PDF builder requirements
  final String? userName;
  final String? confidence;
  final String? classificationScore; // Added classificationScore
  final String? explanationText;

  const ResultCard({
    super.key,
    required this.date,
    required this.title,
    this.imageAsset,
    this.imageFilePath,
    this.showLabel = false,
    this.userName,
    this.confidence,
    this.classificationScore, // Added to constructor
    this.explanationText,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  bool _isGenerating = false;

  Future<void> _generateAndSharePdf(BuildContext context) async {
    if (_isGenerating) return;

    // FIXED: Check for all required data including classificationScore
    if (widget.userName == null ||
        widget.confidence == null ||
        widget.classificationScore == null ||
        widget.explanationText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot generate PDF: Missing report data',
            style: GoogleFonts.urbanist(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Generating PDF report...',
                  style: GoogleFonts.urbanist(),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // FIXED: Generate PDF with all required parameters including classificationScore
      final pdfBytes = await generateReportPdf(
        userName: widget.userName!,
        classification: widget.title,
        confidence: widget.confidence!,
        classificationScore: widget.classificationScore!, // Added classificationScore
        explanationText: widget.explanationText!,
      );

      final fileName = 'A-EYE_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'A-Eye Cataract Report - ${widget.title}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report ready to share or save!',
              style: GoogleFonts.urbanist(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error generating PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate report: $e',
              style: GoogleFonts.urbanist(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing based on screen dimensions
    final imageSize = screenWidth * 0.2;
    final labelFontSize = screenWidth * 0.0375;
    final dateFontSize = screenWidth * 0.0375;
    final titleFontSize = screenWidth * 0.05;
    final warningFontSize = screenWidth * 0.035;
    final loadingFontSize = screenWidth * 0.035;

    // Responsive padding and spacing
    final cardMargin = EdgeInsets.only(bottom: screenHeight * 0.015);
    final cardPadding = EdgeInsets.all(screenWidth * 0.04);
    final labelPadding = EdgeInsets.only(bottom: screenHeight * 0.01);
    final imageSpacing = screenWidth * 0.04;
    final textSpacing = screenHeight * 0.008;
    final warningTopPadding = screenHeight * 0.015;

    final imageWidget = widget.imageFilePath != null
        ? Image.file(
      File(widget.imageFilePath!),
      width: imageSize,
      height: imageSize,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image,
          size: imageSize,
          color: Colors.white30,
        );
      },
    )
        : Image.asset(
      widget.imageAsset ?? 'assets/images/placeholder.png',
      width: imageSize,
      height: imageSize,
      fit: BoxFit.cover,
    );

    final bool isMature = widget.title.toLowerCase().contains('mature') &&
        !widget.title.toLowerCase().contains('immature');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Padding(
            padding: labelPadding,
            child: Text(
              "Most Recent",
              style: GoogleFonts.urbanist(
                fontSize: labelFontSize,
                color: Colors.white,
              ),
            ),
          ),
        InkWell(
          onTap: _isGenerating ? null : () => _generateAndSharePdf(context),
          borderRadius: BorderRadius.circular(24),
          splashColor: const Color(0xFF5244F3).withOpacity(0.2),
          highlightColor: const Color(0xFF5244F3).withOpacity(0.1),
          child: Container(
            margin: cardMargin,
            padding: cardPadding,
            decoration: BoxDecoration(
              color: const Color(0xFF242443),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageWidget,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: screenWidth * 0.05,
                              color: const Color(0xFF5244F3),
                            ),
                            SizedBox(width: screenWidth * 0.015),
                            Text(
                              "SAVE",
                              style: GoogleFonts.urbanist(
                                fontSize: screenWidth * 0.04,
                                color: const Color(0xFF5244F3),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: imageSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.date,
                            style: GoogleFonts.urbanist(
                              fontSize: dateFontSize,
                              color: Colors.grey[300],
                            ),
                          ),
                          SizedBox(height: textSpacing),
                          Text(
                            widget.title,
                            style: GoogleFonts.urbanist(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (isMature)
                            Padding(
                              padding: EdgeInsets.only(top: warningTopPadding),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.027, // specifically 27 so it doesnt overflow
                                  vertical: screenHeight * 0.012,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x26FF6767),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning_rounded,
                                      color: Colors.red,
                                      size: screenWidth * 0.05,
                                    ),
                                    SizedBox(width: screenWidth * 0.02),
                                    Expanded(
                                      child: Text(
                                        "Please consult now with an eye doctor.",
                                        style: GoogleFonts.urbanist(
                                          fontSize: warningFontSize,
                                          color: const Color(0xFFDD0000),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                // Loading overlay
                if (_isGenerating)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.1,
                              height: screenWidth * 0.1,
                              child: const CircularProgressIndicator(
                                color: Color(0xFF5244F3),
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              'Generating PDF...',
                              style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: loadingFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}