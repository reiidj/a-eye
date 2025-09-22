import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImmaturePage extends StatelessWidget {
  final String imagePath;
  final String userName;
  final double prediction;

  const ImmaturePage({
    super.key,
    required this.userName,
    required this.prediction,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
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
              // Top bar
              Container(
                width: double.infinity,
                height: screenHeight * 0.1149,
                color: const Color(0xFF131A21),
                alignment: Alignment.center,
                child: Text(
                  "Eye Health Report",
                  style: GoogleFonts.urbanist(
                    color: const Color(0xFF5E7EA6),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable content
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SingleChildScrollView(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Main Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Yellow warning box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF362D1A),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  "Immature Cataract Detected",
                                  style: GoogleFonts.urbanist(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE69146),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Info text
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.urbanist(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  children: const [
                                    TextSpan(
                                        text:
                                        "The uploaded eye image exhibits characteristics consistent with an immature cataract. "),
                                    TextSpan(
                                      text: "Constant monitoring ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text:
                                        "of cataract is advisable. You can opt for surgical removal if it affects your daily life."),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: imagePath.isNotEmpty &&
                                    File(imagePath).existsSync()
                                    ? Image.file(
                                  File(imagePath),
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.5,
                                  fit: BoxFit.cover,
                                )
                                    : Image.asset(
                                  'assets/images/Immature.png',
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.5,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Medical Disclaimer
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5244F3),
                                ),
                              ),
                              const SizedBox(height: 8),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.urbanist(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  children: const [
                                    TextSpan(
                                        text:
                                        "This app is for informational purposes only. It does "),
                                    TextSpan(
                                      text:
                                      "not replace a licensed ophthalmologist’s diagnosis.",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Visit PAO Box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF242443),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.campaign_rounded,
                                      color: Color(0xFF5244F3),
                                      size: 32,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.urbanist(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                          children: const [
                                            TextSpan(text: "Visit "),
                                            TextSpan(
                                              text: "pao.org.ph",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontStyle: FontStyle.italic,
                                                color: Color(0xFF8BC36A),
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                              " to find certified eye specialists for proper eye analysis.",
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
                        ),
                        const SizedBox(height: 32),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            // --- THIS IS THE FIX ---
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/welcome',
                                  (route) => false,
                              arguments: {'userName': userName},
                            ),
                            // ---------------------
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF5244F3), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Confirm & Exit Report",
                              style: GoogleFonts.urbanist(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}