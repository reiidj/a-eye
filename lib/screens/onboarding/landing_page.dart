import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'name_input_page.dart'; // next page which is name input page

class LandingPage extends StatelessWidget {
  final VoidCallback onNext;

  const LandingPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage('assets/images/Eye Sprite Page 1.png'),
            fit: BoxFit.contain,
            // Added alignment to center the image if it doesn't fill the whole screen
            alignment: Alignment(0.0, -1),
          ),


          // Left-aligned and vertically adjusted overlay text
          Align(
            alignment: Alignment(-1.0, 0.45), // X = -1.0 (left), Y = the bigger the y the lower the text
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A-EYE:',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: 70,
                    ),
                  ),
                const SizedBox(height: 3),
                RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: GoogleFonts.urbanist(
                      fontSize: 60,
                    ),
                    children: const [
                      TextSpan(
                        text: 'cataract ',
                        style: TextStyle(color: Color(0xFF5244F3)),
                      ),
                      TextSpan(
                        text: 'maturity ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'classification',
                        style: TextStyle(color: Color(0xFF5244F3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),

          // Bottom Next Button
          Positioned(
            bottom: 50,
            right: 20,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5244F3),
              ),
              child: Text(
                'Next',
                style: GoogleFonts.urbanist(fontSize: 20, color: Colors.white),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
