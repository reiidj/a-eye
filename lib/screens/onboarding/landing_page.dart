import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_slide_to_act/gradient_slide_to_act.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback onNext;

  const LandingPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive UI
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const baseColor = Color(0xFF5244F3);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          const Image(
            image: AssetImage('assets/images/Eye Sprite Page 1.png'),
            fit: BoxFit.contain,
            alignment: Alignment(0.0, -1),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 0.8, 1.0],
              ),
            ),
          ),

          // Left-aligned and vertically adjusted overlay text
          Align(
            alignment: const Alignment(-1.0, 0.45),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        baseColor,
                        Color.lerp(baseColor, Colors.white, 0.4)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Text(
                      'A-EYE:',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontSize: screenWidth * 0.18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: GoogleFonts.urbanist(
                        // Responsive font size
                        fontSize: screenWidth * 0.15,
                      ),
                      children: const [
                        TextSpan(
                          text: 'cataract ',
                          style: TextStyle(color: baseColor),
                        ),
                        TextSpan(
                          text: 'maturity ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'classification',
                          style: TextStyle(color: baseColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Slider Fixed ---
          Positioned(
            left: screenWidth * 0.05,
            right: screenWidth * 0.1,
            bottom: screenHeight * 0.06,
            child: GradientSlideToAct(
              height: screenHeight * 0.065,
              text: 'Slide to Begin',
              textStyle: GoogleFonts.urbanist(
                fontSize: screenWidth * 0.05,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              backgroundColor: const Color(0xff080D2B),
              onSubmit: onNext,

              dragableIconBackgroundColor: Colors.white,
              dragableIcon: Icons.double_arrow,

              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff484EC6),
                    Color(0xff5244F3),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

