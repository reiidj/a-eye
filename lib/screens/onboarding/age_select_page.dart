import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a_eye/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgeSelectPage extends StatefulWidget {
  final Function(String? ageGroup) onBack;
  final String userName;
  final String gender;

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
  // State variable to hold the user's selection
  String? _selectedAgeGroup;

  /// Handles creating the user profile and navigating to the welcome screen.
  Future<void> _handleNext() async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pop(context); // Dismiss loading indicator
      // Handle error: user not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Could not find user.")),
      );
      return;
    }

    try {
      final firestoreService = FirestoreService();
      final int newLocalId = await firestoreService.getNextLocalId();
      final Map<String, dynamic> userData = {
        'name': widget.userName,
        'gender': widget.gender,
        'ageGroup': _selectedAgeGroup,
        'email': user.email,
        'localId': newLocalId,
        'lastUpdated': Timestamp.now(),
      };

      await firestoreService.addUser(user.uid, userData);

      // Navigate to the welcome screen, removing all previous routes.
      // This dismisses the loading indicator automatically.
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/welcome',
            (route) => false,
        arguments: {'userName': widget.userName},
      );
    } catch (e) {
      Navigator.pop(context); // Dismiss loading indicator on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user profile: $e')),
      );
    }
  }

  /// Reusable widget for the age selection options.
  Widget _ageOption(String age) {
    final bool isSelected = _selectedAgeGroup == age;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: isSelected ? Border.all(color: const Color(0xFF5244F3), width: 2) : null,
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
          onChanged: (value) => setState(() => _selectedAgeGroup = value),
          activeColor: const Color(0xFF5244F3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background UI
          Positioned(
            top: -500,
            right: -500,
            child: Container(
              width: 1000,
              height: 1000,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF5244F3).withOpacity(0.6), Colors.transparent],
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
                  colors: [const Color(0xFF5244F3).withOpacity(0.6), Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: Column(
              children: [
                // Step Indicator
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

                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenHeight -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            screenHeight * 0.02 -
                            120, // Approximate space for indicator and buttons
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

                // Navigation Buttons
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
                          onPressed: () => widget.onBack(_selectedAgeGroup),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.10,
                                vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            if (_selectedAgeGroup != null) {
                              _handleNext(); // Call the refactored logic
                            } else {
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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