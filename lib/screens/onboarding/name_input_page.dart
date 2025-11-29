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
 *   This module is located in `lib/screens/onboarding/` and represents the
 *   first data collection step in the Onboarding Flow. Following the
 *   Landing Page, it captures the user's display name. It serves as the
 *   initial state of the user profile creation process, passing the
 *   validated text input to the subsequent `GenderSelectPage` via callbacks.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a simple, responsive interface for users to input their name,
 *   featuring real-time input management and validation to prevent empty
 *   submissions.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * TextEditingController (_nameController): A Flutter controller used to
 *       read and manipulate the text within the input field.
 *
 *   Algorithms:
 *     * String Manipulation: Uses `.trim()` to remove accidental leading/trailing
 *       whitespace before storage.
 *
 *   Control:
 *     * Resource Management: Overrides `dispose()` to free controller memory.
 *     * Input Validation: Checks if the trimmed string is empty before allowing
 *       navigation to the next screen.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Class: NameInputPage
/// Purpose: Stateful widget for the first step of user registration.
class NameInputPage extends StatefulWidget {
  // -- INPUT PARAMETERS --
  // Callbacks to delegate navigation logic to the parent/router
  final void Function(String name) onNext;
  final void Function() onBack;

  const NameInputPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  // -- LOCAL STATE --
  // Controller to maintain the text input state
  final TextEditingController _nameController = TextEditingController();

  // -- CONTROL: MEMORY MANAGEMENT --
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // -- ALGORITHM: RESPONSIVE SIZING --
    // Calculate dimensions based on current device screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // -- UI COMPONENT: BACKGROUND --
          // Layer 1: Decorative glowing circles
          Positioned(
            top: -500,
            right: -500,
            child: Container(
              width: 1000,
              height: 1000,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5244F3).withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -500,
            left: -500,
            child: Container(
              width: 1000,
              height: 1000,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5244F3).withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // -- MAIN CONTENT --
          SafeArea(
            child: Column(
              children: [
                // -- UI COMPONENT: PROGRESS INDICATOR --
                // Visualizing Step 1 of 3 (Active, Inactive, Inactive)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active Step (Colored)
                      Container(
                        width: screenWidth * 0.28,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5244F3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Inactive Step (Gray)
                      Container(
                        width: screenWidth * 0.28,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Inactive Step (Gray)
                      Container(
                        width: screenWidth * 0.28,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),

                // -- SCROLLABLE FORM AREA --
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Ensure minimum height allows for scrolling on small screens
                        minHeight: screenHeight -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            screenHeight * 0.02 -
                            120,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.05),
                            Text(
                              "What's your name?",
                              style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: screenWidth * 0.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.025),

                            // -- UI COMPONENT: INPUT FIELD --
                            TextField(
                              controller: _nameController,
                              autofocus: true, // Automatically open keyboard
                              maxLength: 13, // Limit input length
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                counterText: '', // Hide character counter
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                    width: 2.0,
                                  ),
                                ),
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // -- NAVIGATION CONTROLS --
                Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button: Returns to Landing Page
                      Flexible(
                        child: OutlinedButton(
                          onPressed: widget.onBack,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.10,
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: GoogleFonts.urbanist(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Next Button: Validates and Proceed
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            // -- CONTROL: INPUT VALIDATION --
                            // Algorithm: Check if string is not empty after trimming spaces
                            if (_nameController.text.trim().isNotEmpty) {
                              widget.onNext(_nameController.text.trim());
                            } else {
                              // Error Handling: Show feedback via SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter your name"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5244F3),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.13,
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.urbanist(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}