import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class WelcomeScreenWithResult extends StatelessWidget {
  final VoidCallback onNext;
  final String userName;

  const WelcomeScreenWithResult({
    super.key,
    required this.onNext,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
    final fallbackName = Hive.box('userBox').get('name', defaultValue: 'Guest');
    final hiveName = userBox.get('name', defaultValue: '').toString();
    final displayName = hiveName.isNotEmpty ? hiveName : userName;

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
                        Text.rich(
                          TextSpan(
                            style: GoogleFonts.urbanist(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                            children: [
                              const TextSpan(text: "Welcome Back, "),
                              TextSpan(
                                text: "$displayName",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: "!"),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

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
                            "Thank you for choose A-Eye!",
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
                              "Ready for your next scan? Tap below to get started.",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.urbanist(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), //spacing lang to

                    Text(
                      "Your Eye Health History",
                      style: GoogleFonts.urbanist(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color(0XFF5244F3),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Yung results box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(32, 10, 32, 10), // LEFT TOP RIGHT BOTTOM // 32 left and right always
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // VISIT PAO ORG TEXT BOX
                          // VISIT PAO ORG TEXT BOX (Matching Red Sign Style)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                                          text: " to find certified eye specialists for proper eye analysis.",
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),//END OF PAO ORG BOX
                        ],
                      ),
                    ),

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
