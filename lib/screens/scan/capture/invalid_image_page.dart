import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvalidPage extends StatelessWidget {
  final VoidCallback? onBack;
  final String imagePath;

  // Alternative constructor that's more flexible
  const InvalidPage({
    Key? key, // Made key optional and nullable
    required this.imagePath,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: Column(
        children: [

          // Header
          Container(
            height: screenHeight * 0.1149,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              "Image Review",
              style: GoogleFonts.urbanist(
                color: const Color(0xFF5E7EA6),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Display captured image with error handling
          SizedBox(
            height: screenHeight * 0.5095,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: imagePath.isNotEmpty && File(imagePath).existsSync()
                      ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Text(
                        'No image available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Warning
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 37.0, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFA20000).withOpacity(0.49),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.urbanist(fontSize: 17, color: Colors.white),
                        children: const [
                          TextSpan(text: "The image isn't suitable for analysis. Please upload an image with "),
                          TextSpan(
                            text: "visible formation of cataract.",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Retake button
          Padding(
            padding: const EdgeInsets.only(bottom: 96),
            child: OutlinedButton(
              onPressed: onBack ?? () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 110, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                "Retake Photo",
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}