import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class uploadInvalidPage extends StatelessWidget {
  final VoidCallback? onBack;

  const uploadInvalidPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: Column(
        children: [

          // Top bar has the Image Review text
          Container(
            height: screenHeight * 0.1149,
            width: double.infinity,
            color: const Color(0xFF131A21),
            alignment: Alignment.center,
            child: Text(
              "Image Review",
              style: GoogleFonts.urbanist(
                color: const Color(0xFF5E7EA6),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Image taking up 50% of the screen
          SizedBox(
            height: screenHeight * 0.5095,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/Immature.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // WARNING SIGN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 37.0, vertical: 12), // increase horizontal to make the box smalelr
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFA20000).withOpacity(0.49),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // X Icon
                  const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12), // distance between x icon and text

                  // Text Message
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

          // Retake photo button
          Padding(
            padding: const EdgeInsets.only(bottom: 96), // space from the bottom part
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

          // END OF CHILDREN

        ],
      ),
    );
  }
}
