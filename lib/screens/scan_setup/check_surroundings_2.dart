/*
 * Program Title: check_surroundings_2.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is the final screen of the "Scan Setup" flow located in
 *   `lib/screens/scan_setup/`. It follows `CheckSurroundings1`. After the user
 *   confirms they are ready, this screen provides the final environmental
 *   instruction (typically regarding lighting) and the "Start Scan" button,
 *   which initiates the transition to the `ScanModePage` (Camera/Upload selection).
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To ensure the user's environment is well-lit and suitable for scanning,
 *   and to provide the definitive trigger to begin the image acquisition process.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * VoidCallback (onNext): Function pointer that executes the navigation
 *       to the Scan Mode selection screen.
 *
 *   Algorithms:
 *     * Overlay Layout: Uses `Stack` and `Positioned` widgets to place the
 *       Call-to-Action button securely at the bottom of the instructional graphic.
 *
 *   Control:
 *     * Event Handling: The `ElevatedButton` triggers the `onNext` callback,
 *       effectively ending the setup phase and starting the active scan phase.
 */


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: CheckSurroundings2
/// Purpose: Stateless widget displaying the final pre-scan check (Lighting).
class CheckSurroundings2 extends StatelessWidget {
  // -- INPUT PARAMETERS --
  final VoidCallback onNext; // Logic to transition to Scan Mode

  const CheckSurroundings2({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Layout: Extend body behind app bar for seamless full-screen background
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
      body: Stack(
        children: [
          // Layer 1: Background image (Instructional Graphic)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Surroundings 2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Layer 2: "Start Scan" Action Button
          Positioned(
            bottom: 20, // Anchor to bottom with padding
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      // Control: Trigger the next phase (Scan Mode)
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5244F3), // Brand Color
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      // Button Content: Icon + Text
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
                            "Start Scan",
                            style: GoogleFonts.urbanist(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}