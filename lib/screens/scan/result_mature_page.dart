import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:a_eye/screens/welcome_screen.dart';

class MaturePage extends StatelessWidget {
  final String? imagePath;
  final String userName;

  const MaturePage({
    super.key,
    required this.userName,
    this.imagePath,
  });


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
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

              // Main content
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Diagnosis box
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
                              // Alert box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                decoration: BoxDecoration(
                                  color: const Color(0x26FF6767),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_rounded,
                                      color: Color(0xFFDD0000),
                                      size: 28,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Mature Cataract Detected",
                                        style: GoogleFonts.urbanist(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFDD0000),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: GoogleFonts.urbanist(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  children: const [
                                    TextSpan(
                                        text: "The scanned eye shows characteristics of a mature cataract. Due to high lens opacity, "),
                                    TextSpan(
                                      text: "surgical removal is recommended",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                        text: ". Please consult an ophthalmologist for further evaluation and to discuss options."),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: imagePath != null && File(imagePath!).existsSync()
                                    ? Image.file(
                                  File(imagePath!),
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
                        const SizedBox(height: 16),

                        // Disclaimer
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
                                    TextSpan(text: "This app is for informational purposes only. It does "),
                                    TextSpan(
                                      text: "not replace a licensed ophthalmologist’s diagnosis.",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Visit PAO.org.ph
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF242443),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
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
                                              text: " to find certified eye specialists for proper eye analysis.",
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
                        const SizedBox(height: 16),

                        // Action buttons
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,

                              // Notify Eye Specialist button
                              child: ElevatedButton(
                                onPressed: () async {
                                  const url = 'https://your-placeholder-site.com'; // REPLACE WITH SITE
                                  try {
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(
                                        Uri.parse(url),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      // Show user-friendly message instead of throwing
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Unable to open website at this time'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Error opening website'),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5244F3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  "Notify Eye Specialist",
                                  style: GoogleFonts.urbanist(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Confirm and Exit Report button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WelcomeScreen(
                                        userName: userName,
                                        onNext: () => Navigator.pushNamed(context, '/scanMode'),
                                        onProfile: () => Navigator.pushNamed(context, '/ProfilePage'),
                                      ),
                                    ),
                                        (route) => false,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
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
