import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaturePage extends StatelessWidget {
  final VoidCallback onComplete;

  const MaturePage({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: [
            // Edge-to-edge Top Bar
            Container(
              height: screenHeight * 0.1149,
              width: double.infinity,
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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // MAIN MESSAGE BOX
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x26FF6767),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Mature Cataract Detected",
                              style: GoogleFonts.urbanist(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              children: const [
                                TextSpan(
                                  text:
                                  "The scanned eye shows characteristics of a mature cataract. Due to high lens opacity, ",
                                ),
                                TextSpan(
                                  text: "surgical removal is recommended",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                  ". Please consult an ophthalmologist for further evaluation and to discuss options.",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Image.asset(
                            'assets/images/Mature.png',
                            width: screenWidth * 0.5,
                            height: screenWidth * 0.5,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // MEDICAL DISCLAIMER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF5244F3),
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              children: const [
                                TextSpan(
                                    text:
                                    "This app is for informational purposes only. It does "),
                                TextSpan(
                                  text:
                                  "not replace a licensed ophthalmologist’s diagnosis.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.campaign,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.urbanist(
                                      fontSize: 14,
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
                                          " to find certified eye specialists for proper eye analysis."),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // BUTTONS
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Notify logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5244F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Notify Eye Specialist",
                              style: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: onComplete,
                            style: OutlinedButton.styleFrom(
                              side:
                              const BorderSide(color: Color(0xFF5244F3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Confirm & Exit Report",
                              style: GoogleFonts.urbanist(
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
          ],
        ),
      ),
    );
  }
}
