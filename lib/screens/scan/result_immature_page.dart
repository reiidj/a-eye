import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// REMOVED: import 'package:hive/hive.dart';
import 'dart:io';

class ImmaturePage extends StatelessWidget {
  final VoidCallback onNext;

  const ImmaturePage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get the image path from the navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final imagePath = args?['imagePath'] as String?;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background and other UI...
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
              // top bar
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

              // Content below top bar inside scroll
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
                        // Main Message Box (Contains Red Sign Text and Image)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(
                              32, 20, 32, 20), // LEFT TOP RIGHT BOTTOM
                          decoration: BoxDecoration(
                            color: const Color(0xFF161616),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // YELLOW SIGN TEXT BOX
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                    8, 4, 8, 4), // LEFT TOP RIGHT BOTTOM
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFF362D1A), // yellow brown mukhang tae background
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Alert Text
                                    Expanded(
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
                                  ],
                                ),
                              ), // end of red sign text box
                              const SizedBox(height: 12),

                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.urbanist(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  // INFORMATIVE TEXT INSIDE BOX
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

                              //IMAGE INSIDE THE BOX
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: imagePath != null && File(imagePath).existsSync()
                                    ? Image.file(
                                  File(imagePath),
                                  width: screenWidth * 0.5,
                                  height: screenWidth * 0.5,
                                  fit: BoxFit.cover,
                                )
                                    : Image.asset(
                                  // fallback if image isn't available
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

                        // SECOND BOX: MEDICAL DISCLAIMER BOX
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(32, 10, 32,
                              10), // LEFT TOP RIGHT BOTTOM // 32 left and right always
                          decoration: BoxDecoration(
                            color: const Color(0xFF131A21),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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

                              // VISIT PAO ORG TEXT BOX
                              Container(
                                width: double.infinity,
                                padding:
                                const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF242443), // BOX BACKGROUND
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.campaign_rounded,
                                      color: const Color(0xFF5244F3),
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
                              ), //END OF PAO ORG BOX
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Buttons
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: onNext,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFF5244F3), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14), //PADDING
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