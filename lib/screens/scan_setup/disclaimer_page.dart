/*
 * Program Title: disclaimer_page.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is a critical legal and ethical component of the "Scan Setup"
 *   flow. It is presented to the user immediately before entering the active
 *   scanning phase. It displays the medical disclaimer, informing the user
 *   that the AI analysis is for informational purposes only and does not
 *   substitute professional medical advice. It acts as a liability gate
 *   requiring user acknowledgement (via the "Proceed" button) to continue.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To ensure the user is fully informed of the application's limitations
 *   regarding medical diagnosis and to capture their intent to proceed under
 *   these terms.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * VoidCallback (onNext): Function pointer used to delegate the navigation
 *       logic to the next step (Check Surroundings).
 *
 *   Algorithms:
 *     * Layered Rendering: Uses a `Stack` to superimpose the interactive button
 *       onto the static disclaimer graphic.
 *
 *   Control:
 *     * Navigation: `Navigator.pop` handles the exit intent, while `onNext`
 *       advances the workflow to the environment check.
 */


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: DisclaimerPage
/// Purpose: Stateless widget displaying the medical liability waiver.
class DisclaimerPage extends StatelessWidget {
  // -- INPUT PARAMETERS --
  final VoidCallback onNext; // Logic to proceed after reading

  const DisclaimerPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Layout: Extend body behind app bar for full-screen graphic
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
          // Layer 1: Background Image containing the Disclaimer Text
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Disclaimer.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Layer 2: Action Button
          Positioned(
            bottom: 200, // Fixed position relative to the bottom
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      // Control: Acknowledge disclaimer and proceed
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
                            "Proceed to Scan",
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