import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/database/app_database.dart';

class UploadInvalidPage extends StatelessWidget {
  final VoidCallback? onBack;
  final AppDatabase database;

  const UploadInvalidPage({
    super.key,
    required this.database,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: Column(
        children: [
          // Top bar
          Container(
            height: screenHeight * 0.1149,
            width: double.infinity,
            alignment: Alignment.center,
            color: const Color(0xFF131A21),
            child: Text(
              "Image Review",
              style: GoogleFonts.urbanist(
                color: const Color(0xFF5E7EA6),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Image preview
          SizedBox(
            height: screenHeight * 0.5095,
            width: double.infinity,
            child: Image.asset(
              'assets/images/Immature.png',
              fit: BoxFit.cover,
            ),
          ),

          const Spacer(),

          // Warning box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 37.0, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFA20000).withOpacity(0.49),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.urbanist(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(
                            text: "The image isn’t suitable for analysis. Please upload an image with ",
                          ),
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
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                "Re-upload Image",
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
