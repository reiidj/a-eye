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
 *   entry point for the "Upload Flow". Unlike the camera capture route,
 *   this screen interfaces with the device's native gallery application via
 *   the `image_picker` plugin. It allows users to select pre-existing photos
 *   for analysis and routes the selected file path to the `UploadCropPage`.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a streamlined interface for accessing the device's photo library,
 *   handling permissions (implicitly via plugin), and managing the transition
 *   from file selection to image processing.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * ImagePicker: A utility class for accessing the platform's media library.
 *     * XFile: An abstraction of the selected file path returned by the OS.
 *
 *   Algorithms:
 *     * Asynchronous I/O: Uses `await` to pause execution while the external
 *       gallery app is open and resumes only after a user selection (or cancellation).
 *
 *   Control:
 *     * Null Checking: Verifies that `pickImage` returned a valid object before
 *       attempting navigation, preventing crashes if the user cancels selection.
 *     * Navigation Stack: Pushes the `UploadCropPage` onto the stack, passing
 *       the file path as a routing argument.
 */


import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// Class: SelectPage
/// Purpose: Stateful widget that displays the upload background and triggers the gallery picker.
class SelectPage extends StatefulWidget {
  // -- INPUT PARAMETERS --
  final VoidCallback onNext; // Callback for potential forward navigation

  const SelectPage({super.key, required this.onNext});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {

  /*
   * Function: _pickImage
   * Purpose: Triggers the native gallery, waits for result, and navigates.
   */
  Future<void> _pickImage() async {
    // -- DATA STRUCTURE: IMAGE PICKER --
    final ImagePicker picker = ImagePicker();

    // -- ALGORITHM: ASYNC SELECTION --
    // Opens the OS-specific gallery sheet. Execution pauses here.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // -- CONTROL: SELECTION VALIDATION --
    // If image is null, the user likely cancelled the picker dialog.
    if (image != null) {
      if (mounted) {
        // Success: Navigate to the Upload Crop Page with the selected path
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadCropPage(imagePath: image.path),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Layout: Allow body to extend behind the transparent app bar
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      // -- UI COMPONENT: NAVIGATION BAR --
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      // -- UI COMPONENT: BACKGROUND --
      body: Stack(
        children: [
          // Background Image (Surroundings)
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

          // -- UI COMPONENT: ACTION BUTTON --
          // Fixed at the bottom center of the screen
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: OutlinedButton(
                  // Control: Trigger file picker on tap
                  onPressed: _pickImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "Upload Image",
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