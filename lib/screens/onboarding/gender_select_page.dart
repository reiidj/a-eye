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
 *  This module is a core component of the "Onboarding Flow" located within
 *  the `lib/screens/onboarding/` directory. It functions as an intermediate
 *  data collection screen in the user initialization sequence (LandingPage ->
 *  NameInputPage -> AgeSelectPage -> GenderSelectPage). It captures the user's
 *  gender identity and passes this state via callbacks to the navigation
 *  controller, contributing to the profile object that will eventually be
 *  committed to Firestore.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a graphical interface for users to select their gender,
 *   ensuring valid input before proceeding to the next registration step.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * selectedGender (String?): Nullable state variable to track user input.
 *
 *   Algorithms:
 *     * State Management: Updates UI immediately upon radio button selection.
 *
 *   Control:
 *     * Input Validation: Checks if `selectedGender` is null before allowing 'Next'.
 *     * Conditional Styling: Dynamic border rendering based on selection state.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: GenderSelectPage
/// Purpose: Stateful widget for the second step of user onboarding.
class GenderSelectPage extends StatefulWidget {
  // -- INPUT PARAMETERS --
  // Callbacks to handle navigation logic defined in the parent/router
  final void Function(String gender) onNext;
  final void Function(String gender) onBack;
  final String? initialGender; // Pre-fill if coming back from next screen

  const GenderSelectPage({
    super.key,
    required this.onNext,
    required this.onBack,
    this.initialGender,
  });

  @override
  State<GenderSelectPage> createState() => _GenderSelectPageState();
}

class _GenderSelectPageState extends State<GenderSelectPage> {
  // -- LOCAL STATE --
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    // Initialize state with passed data (if any) to preserve user context
    selectedGender = widget.initialGender;
  }

  /*
   * Function: genderOption
   * Purpose: Helper widget to create consistent, selectable gender cards.
   * Input: gender (String) - The label to display.
   * output: Widget - A styled container with a RadioListTile.
   */
  Widget genderOption(String gender) {
    // -- ALGORITHM: SELECTION CHECK --
    final bool isSelected = selectedGender == gender;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      // Structured Programming: Encapsulating style logic
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        // Conditional styling: Show border only if selected
        border: isSelected
            ? Border.all(
          color: const Color(0xFF5244F3),
          width: 2,
        )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10, // Semi-transparent background
          borderRadius: BorderRadius.circular(14),
        ),
        child: RadioListTile<String>(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            gender,
            style: const TextStyle(color: Colors.white),
          ),
          value: gender,
          groupValue: selectedGender,
          // Event Handler: Update state to trigger rebuild
          onChanged: (value) => setState(() => selectedGender = value),
          activeColor: const Color(0xFF5244F3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Design: accurate sizing based on screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // -- UI COMPONENT: BACKGROUND --
          // Decorative gradient circles
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
                // Step indicator (Visualizing Step 2 of 3)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.28,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5244F3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Container(
                        width: screenWidth * 0.28,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5244F3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      // Grayed out step 3
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

                // Scrollable Form Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Calculate minimum height to fill screen minus headers/footers
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: screenHeight * 0.05),
                            Text(
                              "Your gender",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: screenWidth * 0.12,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.04),

                            // -- UI COMPONENT: OPTIONS --
                            // Using helper function to render inputs
                            genderOption("Male"),
                            const SizedBox(height: 15),
                            genderOption("Female"),
                            const SizedBox(height: 15),
                            genderOption("Other"),
                            SizedBox(height: screenHeight * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // -- NAVIGATION CONTROLS --
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button
                      Flexible(
                        child: OutlinedButton(
                          onPressed: () {
                            // -- CONTROL: NAVIGATION LOGIC --
                            // Allows going back even if null, passing empty string if so
                            if (selectedGender != null) {
                              widget.onBack(selectedGender!);
                            } else {
                              widget.onBack('');
                            }
                          },
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
                      // Next Button
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            // -- CONTROL: VALIDATION --
                            if (selectedGender != null) {
                              widget.onNext(selectedGender!);
                            } else {
                              // Error Message: Feedback for missing input
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select a gender"),
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