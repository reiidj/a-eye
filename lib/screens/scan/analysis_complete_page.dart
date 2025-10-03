import 'dart:async';
import 'dart:io';
import 'package:a_eye/screens/scan/results_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyzedPage extends StatefulWidget {
  final double prediction;
  final String imagePath;

  const AnalyzedPage({
    super.key,
    required this.prediction,
    required this.imagePath,
  });

  @override
  State<AnalyzedPage> createState() => _AnalyzedPageState();
}

class _AnalyzedPageState extends State<AnalyzedPage> {
  @override
  void initState() {
    super.initState();
    // After a delay, navigate to the results page
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final cataractType = widget.prediction > 0.5
            ? CataractType.mature
            : CataractType.immature;

        Navigator.pushReplacementNamed(
          context,
          '/results',
          arguments: {
            'cataractType': cataractType,
            'prediction': widget.prediction,
            'imagePath': widget.imagePath,
            // userName will be fetched on the results page itself if needed
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the captured image
            Container(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(File(widget.imagePath)),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: const Color(0xFF5244F3),
                  width: 6,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Analysis Complete',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Redirecting to results...',
              style: GoogleFonts.urbanist(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}