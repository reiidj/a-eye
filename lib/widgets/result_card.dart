/*
 * Program Title: result_card.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is located in `lib/widgets/` and serves as a reusable UI component
 *   used primarily by the `WelcomeScreen`. It represents a single historical
 *   analysis record. Beyond simple display, it encapsulates the logic to
 *   regenerate and share a PDF report for that specific historical entry,
 *   interacting with the `PdfBuilder` service directly.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To display a concise summary of a previous scan (Date, Result, Confidence)
 *   and provide a direct interface for the user to export that specific record
 *   as a PDF document.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * ResultCard (StatefulWidget): Holds all metadata required to reconstruct
 *       the full report (UserName, Scores, Explanation).
 *     * File (dart:io): Handles the local image file reference for the thumbnail.
 *
 *   Algorithms:
 *     * On-Demand Generation: PDF reports are not stored; they are generated
 *       algorithmically via `_generateAndSharePdf` only when the user taps the card.
 *     * Visual Hierarchy: Uses conditional logic to render "Mature" results with
 *       urgent red styling versus standard styling for "Immature" results.
 *
 *   Control:
 *     * State Management: Uses `_isGenerating` semaphore to prevent multiple
 *       tap events while the PDF service is busy.
 *     * Error Handling: Validates that all required fields are present before
 *       attempting PDF generation to prevent null pointer exceptions.
 */


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:a_eye/services/pdf_builder.dart';

/// Class: ResultCard
/// Purpose: Reusable widget displaying a single scan history item with PDF export capabilities.
class ResultCard extends StatefulWidget {
  // -- INPUT PARAMETERS --
  final String date;
  final String title;
  final String? imageAsset;    // Fallback image
  final String? imageFilePath; // Local path to scan image
  final bool showLabel;        // Toggle for "Most Recent" tag

  // Data required for re-generating the PDF report
  final String? userName;
  final String? confidence;
  final String? classificationScore;
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
    this.classificationScore,
    this.explanationText,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  // -- LOCAL STATE --
  bool _isGenerating = false; // Locks UI during PDF generation

  /*
   * Function: _generateAndSharePdf
   * Purpose: Re-creates the PDF report from stored metadata and opens the share sheet.
   */
  Future<void> _generateAndSharePdf(BuildContext context) async {
    // Control: Prevent double-taps
    if (_isGenerating) return;

    // -- CONTROL: DATA VALIDATION --
    // Ensure all components needed for the PDF exist before calling the service
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
      // UI Feedback: Show snackbar while processing
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

      // -- ALGORITHM: PDF GENERATION --
      // Call the PdfBuilder service
      final pdfBytes = await generateReportPdf(
        userName: widget.userName!,
        classification: widget.title,
        confidence: widget.confidence!,
        classificationScore: widget.classificationScore!,
        explanationText: widget.explanationText!,
      );

      // -- ALGORITHM: FILE I/O --
      // Save to temp storage to allow sharing
      final fileName = 'A-EYE_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // -- CONTROL: SHARE SHEET --
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
    // -- ALGORITHM: RESPONSIVE LAYOUT --
    // Calculate all dimensions relative to screen size for consistency
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final imageSize = screenWidth * 0.2;
    final labelFontSize = screenWidth * 0.0375;
    final dateFontSize = screenWidth * 0.0375;
    final titleFontSize = screenWidth * 0.042;
    final warningFontSize = screenWidth * 0.035;
    final loadingFontSize = screenWidth * 0.035;

    // Styles
    final cardMargin = EdgeInsets.only(bottom: screenHeight * 0.015);
    final cardPadding = EdgeInsets.all(screenWidth * 0.04);
    final labelPadding = EdgeInsets.only(bottom: screenHeight * 0.01);
    final imageSpacing = screenWidth * 0.04;
    final textSpacing = screenHeight * 0.008;
    final warningTopPadding = screenHeight * 0.015;

    // Control: Determine image source (Local File vs Asset Placeholder)
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

    // Logic: Determine severity for styling
    final bool isMature = widget.title.toLowerCase().contains('mature') &&
        !widget.title.toLowerCase().contains('immature');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Most Recent" Label
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

        // Main Card Body
        InkWell(
          // Control: Trigger PDF generation on tap
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
                    // Left Side: Image + Save Icon
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

                    // Right Side: Text Details
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
                          // Conditional Warning for Mature Cataracts
                          if (isMature)
                            Padding(
                              padding: EdgeInsets.only(top: warningTopPadding),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.027,
                                  vertical: screenHeight * 0.012,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x26FF6767), // Red Background
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

                // Loading Overlay (Visible during PDF Generation)
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