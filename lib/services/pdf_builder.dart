/*
 * Program Title: pdf_builder.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is located in `lib/services/` and functions as the report
 *   generation engine. Triggered by the `ResultsPage`, it takes the raw data
 *   (Analysis results, User metadata) and formats it into a professional,
 *   portable document format (PDF). It utilizes the `pdf` package to
 *   algorithmically construct the visual layout before serializing the
 *   document into binary data for storage or sharing.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To create a permanent, sharable record of the cataract analysis that
 *   users can present to medical professionals, formatted securely and
 *   legibly on standard A4 paper.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * pw.Document: The root object representing the PDF file structure.
 *     * pw.Column/Row: Layout widgets used to organize text spatially.
 *     * Uint8List: The byte array representation of the final PDF file.
 *
 *   Algorithms:
 *     * Document Composition: A declarative approach to building the PDF,
 *       similar to building a Flutter UI widget tree.
 *     * Binary Serialization: The `pdf.save()` method compresses and encodes
 *       the document structure into a byte stream.
 *
 *   Control:
 *     * Sequential Build: The page builder executes linearly to stack
 *       elements (Header -> Info -> Scores -> Disclaimer) vertically.
 */


import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Generates a PDF report from the analysis results.
/// Returns a [Future<Uint8List>] containing the bytes of the generated PDF.
Future<Uint8List> generateReportPdf({
  required String userName,
  required String classification,
  required String confidence, // This will be the main confidence score "98.76%"
  required String classificationScore,
  required String explanationText,
}) async {

  // -- DATA STRUCTURE: DOCUMENT ROOT --
  final pdf = pw.Document();

  // -- ALGORITHM: PAGE LAYOUT --
  // Add a single page using standard A4 dimensions
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        // Layout: Vertical Column for structured data presentation
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- Section 1: Header ---
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('A-EYE Analysis Report',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  // Algorithm: Timestamp generation for record keeping
                  pw.Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
                ],
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // --- Section 2: Patient and Prediction Info ---
            pw.Paragraph(
              text: 'Report for: $userName',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 12),
                children: [
                  pw.TextSpan(
                      text: 'Predicted Class: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: classification),
                ],
              ),
            ),

            // --- Section 3: Scoring Metrics ---
            // Display Confidence (Probability)
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 12),
                children: [
                  pw.TextSpan(
                      text: 'Confidence in Result: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: confidence),
                ],
              ),
            ),
            // Display Raw Classification Score (Logits/Threshold distance)
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                children: [
                  pw.TextSpan(
                      text: 'Classification Score: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: classificationScore),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // --- Section 4: Explainability Report ---
            // Detailed text from the backend explaining *why* the decision was made
            pw.Text(
              explanationText.trim(),
              style: pw.TextStyle(font: pw.Font.courier(), fontSize: 10),
            ),
            pw.SizedBox(height: 40),

            // --- Section 5: Disclaimer ---
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Paragraph(
              text:
              'Disclaimer: This app is for informational purposes only and does not replace a licensed ophthalmologist\'s diagnosis. Please consult a certified eye specialist for proper medical advice.',
              style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
            ),
          ],
        );
      },
    ),
  );

  // -- ALGORITHM: BINARY SERIALIZATION --
  // Convert the object tree into a standard PDF byte stream
  return pdf.save();
}