/*
 * Program Title: A-Eye: Cataract Maturity Classification Tool
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module acts as the "Failure State" handler within the Analysis Flow.
 *   It is triggered specifically by the `CropImagePage` (or `ApiService`) when
 *   the preliminary image validation fails (e.g., image is blurry, not an eye,
 *   or too dark). It closes the loop on invalid inputs by forcing the user to
 *   review the error and restart the capture process, ensuring only high-quality
 *   data reaches the main analysis model.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide clear, actionable feedback to the user regarding why their
 *   image was rejected, displaying the specific error reason and providing
 *   shortcuts to the Capture Guide or Retake function.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * String (imagePath): The local path to the rejected file for review.
 *     * String (reason): The specific error message returned by the API/Validator.
 *
 *   Algorithms:
 *     * UI Layout: Uses a scrollable Column to ensure content fits on all screen
 *       sizes without overflow errors.
 *
 *   Control:
 *     * Navigation: The `onBack` callback or default `Navigator.pop` returns the
 *       user to the previous screen (usually Crop or Camera) to try again.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: InvalidImagePage
/// Purpose: Stateless widget that displays the rejected image and the reason for rejection.
class InvalidImagePage extends StatelessWidget {
  // -- INPUT PARAMETERS --
  final String imagePath; // Path to the failed image
  final String reason;    // Error message (e.g., "Image too blurry")
  final VoidCallback? onBack; // Optional override for back navigation

  const InvalidImagePage({
    super.key,
    required this.imagePath,
    required this.reason,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // -- ALGORITHM: RESPONSIVE SIZING --
    // Calculate dimensions based on current device screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // -- UI COMPONENT: HEADER --
              SizedBox(
                height: screenHeight * 0.1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "Image Review",
                    style: GoogleFonts.urbanist(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.0125),

              // -- UI COMPONENT: IMAGE PREVIEW --
              // Displays the rejected image so the user can see the issue
              SizedBox(
                height: screenHeight * 0.5,
                width: double.infinity,
                child: Image.file(File(imagePath), fit: BoxFit.cover),
              ),
              SizedBox(height: screenHeight * 0.025),

              // -- UI COMPONENT: ERROR FEEDBACK BOX --
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                child: Container(
                  // Visual Cue: Red background indicates error/stop
                  decoration: BoxDecoration(
                    color: const Color(0xFFA20000).withOpacity(0.49),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: screenWidth * 0.07,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      // Display the specific validation error passed from API
                      Expanded(
                        child: Text(
                          reason,
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.0425,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.025),

              // -- UI COMPONENT: ACTION BUTTONS --
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                child: Column(
                  children: [
                    // Button 1: Retake Photo
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        // Control: Execute custom callback or default pop
                        onPressed: onBack ?? () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Retake Photo",
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // Button 2: Scan Guide
                    // Allows user to learn how to take a better photo
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/guide');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5244F3),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Scan Guide",
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}