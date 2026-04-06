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
 *   This module is located in `lib/screens/scan/upload/` and serves as the
 *   specific error handler for the "Upload Flow". Unlike the camera flow,
 *   when a gallery image fails validation (e.g., blurry, low resolution),
 *   this screen is presented. It displays the rejected image, the specific
 *   algorithmic reason for rejection, and routes the user back to the
 *   gallery picker ("Re-upload") rather than the camera viewfinder.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide specific feedback on why a user-uploaded image was rejected
 *   by the validation API, preventing invalid data from entering the analysis
 *   pipeline and guiding the user to select a better image.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * String (imagePath): Path to the temporary file of the cropped upload.
 *     * String (reason): Validation error message returned by the backend.
 *
 *   Algorithms:
 *     * File System Verification: Checks `File(imagePath).existsSync()` before
 *       attempting to render to prevent crash loops on broken paths.
 *
 *   Control:
 *     * Conditional Rendering: Displays a grey placeholder if the image file
 *       cannot be loaded.
 *     * Navigation Stack: Pops the current route to return to the parent
 *       `UploadCropPage` or `UploadSelectPage`.
 */


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: UploadInvalidPage
/// Purpose: Stateless widget displaying error details for failed gallery uploads.
class UploadInvalidPage extends StatelessWidget {
  // -- INPUT PARAMETERS --
  final String imagePath;
  final String reason;
  final VoidCallback? onBack; // Custom back handler (usually closes crop page too)

  const UploadInvalidPage({
    super.key,
    required this.imagePath,
    required this.reason,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // -- ALGORITHM: RESPONSIVE SIZING --
    // Scale UI elements proportional to screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // -- UI COMPONENT: HEADER --
              Container(
                height: screenHeight * 0.1149,
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  "Image Review",
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: screenWidth * 0.0625,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // -- UI COMPONENT: IMAGE PREVIEW --
              SizedBox(
                height: screenHeight * 0.5095,
                width: double.infinity,
                // Control: Safety check to ensure file exists before rendering
                child: imagePath.isNotEmpty && File(imagePath).existsSync()
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : Container(
                  // Fallback UI if image is missing/corrupted
                  color: Colors.grey[800],
                  child: const Center(child: Text('No image available')),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // -- UI COMPONENT: ERROR FEEDBACK --
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.09,
                  vertical: screenHeight * 0.015,
                ),
                child: Container(
                  // Visual Cue: Red background for error state
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
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      // Display the specific API validation error
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
              SizedBox(height: screenHeight * 0.02),

              // -- UI COMPONENT: ACTION BUTTONS --
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                child: Column(
                  children: [
                    // Button 1: Re-upload
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        // Control: Execute custom callback (pop twice) or default pop
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
                          "Re-upload Image",
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),

                    // Button 2: Scan Guide
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
                            fontSize: screenWidth * 0.045,
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