/*
 * Program Title: scan_mode_page.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module acts as the central branching point for the "Analysis Flow".
 *   Positioned after the setup/checklist screens (`CheckSurroundings`,
 *   `Disclaimer`), it presents the user with the two primary methods of
 *   data acquisition: Gallery Upload or Camera Capture. It delegates the
 *   routing logic to the parent controller via callbacks, initiating either
 *   the `SelectPage` or `CameraPage`.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a clear, accessible interface for users to choose their preferred
 *   method of inputting an eye image for analysis.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * VoidCallback (onUpload/onCapture): Function pointers that abstract
 *       the navigation implementation, allowing this widget to remain stateless
 *       and reusable.
 *
 *   Algorithms:
 *     * Responsive Layout: Uses `MediaQuery` to calculate button padding and
 *       font sizes dynamically, ensuring usability on both small phones and tablets.
 *
 *   Control:
 *     * Event Handling: Maps button taps to specific callbacks, effectively
 *       forking the user journey into two distinct paths (Upload Flow vs. Capture Flow).
 */


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: ScanModePage
/// Purpose: Stateless widget displaying the choice between Camera and Gallery input.
class ScanModePage extends StatelessWidget {
  // -- INPUT PARAMETERS --
  final VoidCallback onUpload;  // Trigger for Gallery Flow
  final VoidCallback onCapture; // Trigger for Camera Flow

  const ScanModePage({
    super.key,
    required this.onUpload,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    // -- ALGORITHM: RESPONSIVE SIZING --
    // Fetch device dimensions for proportional scaling
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Layout: Allow background to extend behind the status bar
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      // -- UI COMPONENT: NAVIGATION HEADER --
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      // -- UI COMPONENT: MAIN CONTENT --
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Layer 1: Background Texture
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.075,
              vertical: screenHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Text
                Text(
                  "Select image input method:",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: screenWidth * 0.105,
                  ),
                ),
                SizedBox(height: screenHeight * 0.07),

                // -- UI COMPONENT: HERO IMAGE --
                // Central Logo/Icon with Error Handling
                SizedBox(
                  height: screenWidth * 0.75,
                  width: screenWidth * 0.75,
                  child: Image.asset(
                    'assets/images/AEYE Logo P6.png',
                    fit: BoxFit.cover,
                    // Algorithm: Fallback builder prevents crash if asset is missing
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white30,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.07),

                // -- UI COMPONENT: UPLOAD BUTTON --
                // Triggers the Gallery selection flow
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    // Control: Execute upload callback
                    onPressed: onUpload,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.085,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Upload an image from gallery",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                // -- UI COMPONENT: CAPTURE BUTTON --
                // Triggers the Camera flow
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Control: Execute capture callback
                    onPressed: onCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5244F3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.17,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Capture using camera",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}