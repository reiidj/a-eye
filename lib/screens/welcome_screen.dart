import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onProfile;
  final String userName;

  const WelcomeScreen({
    super.key,
    required this.onNext,
    required this.onProfile,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),

        child: Stack(
          children: [
            // Top icons
            SafeArea(
              child: Stack(
                children: [
                  // Profile button - top left
                  Positioned(
                    top: 20,
                    left: 30,
                    child: GestureDetector(
                      onTap: onProfile,
                      child: Image.asset(
                        'assets/images/Profile btn.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.menu, color: Colors.white, size: 28);
                        },
                      ),
                    ),
                  ),

                  // A-Eye icon - top right
                  Positioned(
                    top: -30,
                    right: 0,
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Image.asset(
                        'assets/images/A-Eye Icon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.info_outline, color: Colors.white, size: 28);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Align(
            alignment: const Alignment(0.0, 0.7),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row( // <--- Wrap the Text widgets in a Row
                      mainAxisSize: MainAxisSize.min, // Essential: Makes the Row take only the space its children need horizontally
                      children: [
                        Text(
                          "Hello, ", // First part: regular weight
                          style: GoogleFonts.urbanist(
                            fontSize: 40,
                            fontWeight: FontWeight.normal, // Explicitly normal
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          userName, // <--- Second part: the username, make this bold
                          style: GoogleFonts.urbanist(
                            fontSize: 40,
                            fontWeight: FontWeight.w700, // Make this part bold
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "!", // Third part: regular weight
                          style: GoogleFonts.urbanist(
                            fontSize: 40,
                            fontWeight: FontWeight.normal, // Explicitly normal
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Outer box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white12.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome to A-Eye!",
                            style: GoogleFonts.urbanist(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Inner box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Ready to check your eyes? Scan now to begin.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.urbanist(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32), //spacing lang to

                    // Hero image yung card sa gitna
                    SizedBox(
                      height: 380,
                      width: double.infinity,
                      child: ClipRRect( // ClipRRect to apply borderRadius to the image
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/images/Welcome Card.png',
                          fit: BoxFit.contain, // Ensure the image covers the container
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),


                    // start eye scan na button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5244F3),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Image.asset(
                                'assets/images/eye_scan_sprite.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Start Eye Scan",
                              style: GoogleFonts.urbanist(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )


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
