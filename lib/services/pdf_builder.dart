import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Generates a PDF report from the analysis results.
/// Returns a [Future<Uint8List>] containing the bytes of the generated PDF.
Future<Uint8List> generateReportPdf({
  required String userName,
  required String classification,
  required String confidence, // This will be the main confidence score (e.g., "98.76%")
  required String classificationScore, // This is the new score
  required String explanationText,
}) async {
  // Create a new PDF document
  final pdf = pw.Document();

  // Add a page to the document
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- Header ---
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('A-EYE Analysis Report',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
                ],
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // --- Patient and Prediction Info ---
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

            // --- UPDATED: Display both scores correctly ---
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 12),
                children: [
                  pw.TextSpan(
                      text: 'Confidence in Result: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: confidence), // The main confidence
                ],
              ),
            ),
            pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                children: [
                  pw.TextSpan(
                      text: 'Classification Score: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.TextSpan(text: classificationScore), // The threshold score
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // --- Explainability Report Section ---
            pw.Text(
              explanationText.trim(),
              style: pw.TextStyle(font: pw.Font.courier(), fontSize: 10),
            ),
            pw.SizedBox(height: 40),

            // --- Disclaimer ---
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

  // Return the PDF document as a byte list
  return pdf.save();
}