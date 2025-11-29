/*
 * Program Title: crop_guide_page.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is a support screen within the "Analysis Flow". It is
 *   accessible from the `CropImagePage`, `UploadCropPage`, and `InvalidImagePage`.
 *   Its specific role is to educate the user on how to prepare their image
 *   for the AI, providing visual examples of "Good" vs "Bad" crops to increase
 *   the likelihood of a successful classification.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide static, visual instructions on how to correctly isolate the
 *   pupil in an image, thereby improving the accuracy of the ML model.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * bool (isGoodExample): Flag used in the helper method to toggle between
 *       positive (Green/Check) and negative (Red/Cross) styling.
 *
 *   Algorithms:
 *     * Modular Widget Construction: Uses `_buildGuideSection` to reduce code
 *       duplication when rendering similar layout blocks.
 *
 *   Control:
 *     * Navigation: `Navigator.pop` returns the user to the previous active
 *       task (Cropping or Reviewing errors).
 */


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: CropGuidePage
/// Purpose: Stateless widget displaying educational content on image cropping.
class CropGuidePage extends StatelessWidget {
  const CropGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    // -- ALGORITHM: RESPONSIVE SIZING --
    // Fetch screen dimensions for proportional scaling
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      // -- UI COMPONENT: HEADER --
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A21),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Crop Guide",
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // -- UI COMPONENT: SCROLLABLE BODY --
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),

            // -- UI COMPONENT: GOOD EXAMPLE SECTION --
            _buildGuideSection(
              context,
              title: "Good Crop",
              description:
              "Ensure the eye is centered and fills the entire frame. The eyelids should be open, and the pupil clearly visible.",
              imagePath:
              'assets/images/Good_Crop.png',
              isGoodExample: true,
            ),
            SizedBox(height: screenHeight * 0.04),

            // -- UI COMPONENT: BAD EXAMPLE SECTION --
            _buildGuideSection(
              context,
              title: "Bad Crop",
              description:
              "Avoid cropping too far out or cutting off parts of the eye. Make sure there are no obstructions like hair or reflections.",
              imagePath:
              'assets/images/Bad_Crop.jpg',
              isGoodExample: false,
            ),
            SizedBox(height: screenHeight * 0.05),

            // -- UI COMPONENT: DISMISS BUTTON --
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5244F3),
                  padding:
                  EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Got it",
                  style: GoogleFonts.urbanist(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  /*
   * Function: _buildGuideSection
   * Purpose: Helper method to render consistent instructional blocks.
   * Inputs: Title, Description, Image Path, and a Boolean flag for styling.
   */
  Widget _buildGuideSection(BuildContext context,
      {required String title,
        required String description,
        required String imagePath,
        required bool isGoodExample}) {
    final screenWidth = MediaQuery.of(context).size.width;

    // -- ALGORITHM: CONDITIONAL STYLING --
    // Select color and icon based on whether this is a "Good" or "Bad" example
    final iconColor = isGoodExample ? Colors.green : Colors.red;
    final iconData = isGoodExample ? Icons.check_circle : Icons.cancel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(iconData, color: iconColor, size: screenWidth * 0.08),
            SizedBox(width: screenWidth * 0.03),
            Text(
              title,
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.03),

        // Example Image Container
        Container(
          height: screenWidth * 0.5,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white30),
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            // Error Handling: Fallback text if asset is missing
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_not_supported,
                        color: Colors.white70, size: 50),
                    const SizedBox(height: 8),
                    Text(
                      'Add image at:\n$imagePath',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: screenWidth * 0.03),

        // Description Text
        Text(
          description,
          style: GoogleFonts.urbanist(
            color: Colors.white70,
            fontSize: screenWidth * 0.04,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}