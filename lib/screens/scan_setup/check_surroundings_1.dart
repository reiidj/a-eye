/*
 * Program Title: check_surroundings_1.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is part of the "Scan Setup" flow, specifically the pre-scan
 *   checklist. It is presented to the user before accessing the camera to
 *   ensure optimal scanning conditions. This specific screen verifies if the
 *   user is performing a self-scan, which helps set user expectations for
 *   the difficulty of centering the eye without assistance.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a visual guide and confirmation step ensuring the user is
 *   aware of the scanning procedure (self-scan context) before proceeding.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * VoidCallback (onNext): Delegate function to trigger the transition
 *       to the next instruction screen or the camera.
 *
 *   Algorithms:
 *     * Z-Order Layout: Uses a `Stack` to layer the interactive button over
 *       a full-screen instructional background image.
 *
 *   Control:
 *     * Navigation: Uses `Navigator.pop` for backward navigation and the
 *       `onNext` callback for forward progression.
 */


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: CheckSurroundings1
/// Purpose: Stateless widget displaying the first environment check (Self-scan confirmation).
class CheckSurroundings1 extends StatelessWidget {
  // -- INPUT PARAMETERS --
  final VoidCallback onNext; // Logic for the "Yes" button

  const CheckSurroundings1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Layout: content extends behind the status bar/app bar for immersion
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

      // -- UI COMPONENT: LAYOUT STACK --
      body: Stack(
        children: [
          // Layer 1: Full screen Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Surroundings 1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Layer 2: Bottom Action Button
          Positioned(
            bottom: 20, // Fixed margin from bottom of screen
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: OutlinedButton(
                  // Control: Execute the passed callback
                  onPressed: onNext,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "Yes, I'm scanning by myself",
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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