import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvalidImagePage extends StatelessWidget {
  final String imagePath;
  final String selectedEye;
  final String reason;
  final VoidCallback? onBack;

  const InvalidImagePage({
    super.key,
    required this.imagePath,
    required this.selectedEye,
    required this.reason,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Image Review",
                style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: Image.file(File(imagePath), fit: BoxFit.cover),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 37.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFA20000).withOpacity(0.49),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reason,
                      style: GoogleFonts.urbanist(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: OutlinedButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 110, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("Retake Photo", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}