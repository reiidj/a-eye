import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadInvalidPage extends StatelessWidget {

  final String imagePath;
  final String reason;
  final VoidCallback? onBack;

  const UploadInvalidPage({
    super.key,
    required this.imagePath,
    required this.reason,
    this.onBack,
  });
  // --- FIX END ---

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    // The build method now uses properties from the constructor
    // instead of extracting arguments itself.

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.1149,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text("Image Review", /* ... */),
          ),
          SizedBox(
            height: screenHeight * 0.5095,
            width: double.infinity,
            // --- FIX: Use the 'imagePath' from the constructor ---
            child: imagePath.isNotEmpty && File(imagePath).existsSync()
                ? Image.file(File(imagePath), fit: BoxFit.cover)
                : Container(
              color: Colors.grey[800],
              child: const Center(child: Text('No image available')),
            ),
          ),
          const Spacer(),
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
                    // --- FIX: Use the 'reason' from the constructor ---
                    child: Text(
                      reason,
                      style: GoogleFonts.urbanist(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 96),
            child: OutlinedButton(
              // --- FIX: Use the 'onBack' callback from the constructor ---
              onPressed: onBack ?? () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text("Re-upload Image", /* ... */),
            ),
          ),
        ],
      ),
    );
  }
}