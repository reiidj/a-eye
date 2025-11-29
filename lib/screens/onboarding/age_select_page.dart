/*
 * Program Title: age_select_page.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *  This module is part of the `lib/screens/onboarding/` directory. In this
 *  specific implementation, it acts as the data controller for the final
 *  stage of the Onboarding Flow. It aggregates the user's name, gender,
 *  and the locally selected age group, then interfaces with the
 *  `FirestoreService` to commit the full user profile to the cloud database
 *  before transitioning the user to the `WelcomeScreen`.
 *
 * Date Written: August 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a graphical interface for users to select their age demographic,
 *   validate this input, and securely transmit the complete user profile
 *   to the backend database while managing UI states (loading, success, error).
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * userData (Map<String, dynamic>): A JSON-like key-value pair structure
 *       used to organize profile data before transmission to Firestore.
 *     * _selectedAgeGroup (String?): Nullable state variable holding the
 *       user's current selection.
 *
 *   Algorithms:
 *     * Asynchronous Data Persistence: Uses `await` pattern to handle
 *       network latency when writing to Firestore.
 *     * Local ID Generation: Fetches and increments a counter for readable IDs.
 *
 *   Control:
 *     * Input Validation: Ensures `_selectedAgeGroup` is not null before proceeding.
 *     * Authentication Check: Verifies `FirebaseAuth.instance.currentUser` exists.
 *     * Exception Handling: Try/Catch blocks manage network or permission errors
 *       and provide user feedback via SnackBars.
 */


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a_eye/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Class: AgeSelectPage
/// Purpose: Stateful widget representing the third stage of user registration.
/// It receives data from the previous screen to finalize the user profile.
class AgeSelectPage extends StatefulWidget {
  // -- CONSTANT IDENTIFIERS & PARAMETERS --
  final Function(String? ageGroup) onBack; // Callback for navigation state
  final String userName;                   // Data passed from Step 1
  final String gender;                     // Data passed from Step 2

  const AgeSelectPage({
    super.key,
    required this.onBack,
    required this.userName,
    required this.gender,
  });

  @override
  State<AgeSelectPage> createState() => _AgeSelectPageState();
}

class _AgeSelectPageState extends State<AgeSelectPage> {
  // -- LOCAL VARIABLES --
  // Stores the user's selection. Nullable to represent "no selection made".
  String? _selectedAgeGroup;

  /*
   * Function: _handleNext
   * Length: Medium (Logic + UI Feedback)
   * Purpose: Validates input, aggregates data, and saves to Firestore.
   * Returns: Future<void> (Asynchronous operation)
   */
  Future<void> _handleNext() async {
    // -- CONTROL: UI FEEDBACK --
    // Show loading indicator to prevent double submissions during network calls
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // -- CONTROL: AUTHENTICATION CHECK --
    final user = FirebaseAuth.instance.currentUser;

    // Error Return Convention: Early exit if user is not authenticated
    if (user == null) {
      Navigator.pop(context); // Dismiss loader
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Could not find user.")),
      );
      return;
    }

    try {
      // -- ALGORITHM: DATA PERSISTENCE --
      final firestoreService = FirestoreService();

      // Fetch the next sequential ID (Business Logic)
      final int newLocalId = await firestoreService.getNextLocalId();

      // -- DATA STRUCTURE: MAP --
      // Aggregating all user data into a single object for storage efficiency
      final Map<String, dynamic> userData = {
        'name': widget.userName,
        'gender': widget.gender,
        'ageGroup': _selectedAgeGroup,
        'email': user.email,
        'localId': newLocalId,
        'lastUpdated': Timestamp.now(),
      };

      // Write to database using the Service Layer
      await firestoreService.addUser(user.uid, userData);

      // -- CONTROL: NAVIGATION --
      // On Success: Clear navigation stack and move to Welcome screen
      // This prevents the user from going "back" to the registration form
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/welcome',
            (route) => false,
        arguments: {'userName': widget.userName},
      );
    } catch (e) {
      // -- CONTROL: ERROR HANDLING --
      Navigator.pop(context); // Dismiss loading indicator on error

      // Error Message: Display specific exception to user for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user profile: $e')),
      );
    }
  }

  /*
   * Function: _ageOption
   * Length: Short (Helper Widget)
   * Purpose: Renders a consistent radio button choice with styling.
   * Param: age (String) - The label for the option.
   */
  Widget _ageOption(String age) {
    // Logic to determine visual state (Selected vs Unselected)
    final bool isSelected = _selectedAgeGroup == age;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      // Structured Programming: Separation of style logic
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        // Conditional styling based on selection state
        border: isSelected
            ? Border.all(color: const Color(0xFF5244F3), width: 2)
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: RadioListTile<String>(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(age, style: const TextStyle(color: Colors.white)),
          value: age,
          groupValue: _selectedAgeGroup,
          // Updates state when user taps an option
          onChanged: (value) => setState(() => _selectedAgeGroup = value),
          activeColor: const Color(0xFF5244F3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Accessing device dimensions for responsive layout calculations
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // -- UI COMPONENT: BACKGROUND GRADIENTS --
          // Positioned widgets create the ambient glow effect
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
                    Colors.transparent
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
                    Colors.transparent
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // -- MAIN CONTENT AREA --
          SafeArea(
            child: Column(
              children: [
                // Step Indicator (Visualizing progress: Step 3 of 3)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) =>
                        Container(
                          width: screenWidth * 0.28,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5244F3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ),
                  ),
                ),

                // Scrollable Form Section
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Dynamic height calculation to ensure content fits
                        // without overflow on smaller screens
                        minHeight: screenHeight -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            screenHeight * 0.02 -
                            120, // Approximate space for indicator/buttons
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: screenHeight * 0.05),
                            Text(
                              "Your Age Group",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: screenWidth * 0.11,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.04),

                            // Rendering options using the helper method
                            // to maintain Structured Programming principles
                            _ageOption("Under 20"),
                            const SizedBox(height: 15),
                            _ageOption("20 - 40"),
                            const SizedBox(height: 15),
                            _ageOption("40 - 60"),
                            const SizedBox(height: 15),
                            _ageOption("Above 60"),
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
                      // Previous Button: Navigates back to Gender Selection
                      Flexible(
                        child: OutlinedButton(
                          onPressed: () => widget.onBack(_selectedAgeGroup),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF5244F3),
                                width: 2
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.10,
                                vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
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

                      // Next Button: Triggers Validation and Submission
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            // -- CONTROL: NULL CHECK --
                            if (_selectedAgeGroup != null) {
                              _handleNext(); // Validated: Proceed to logic
                            } else {
                              // Error Message: User feedback for missing input
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select an age group"),
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
                                borderRadius: BorderRadius.circular(20)
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