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

          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 250),
                Text(
                  "Your Age Group",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(color: Colors.white, fontSize: 45),
                ),
                const SizedBox(height: 30),
                _ageOption("Under 20"),
                const SizedBox(height: 15),
                _ageOption("20 - 40"),
                const SizedBox(height: 15),
                _ageOption("40 - 60"),
                const SizedBox(height: 15),
                _ageOption("Above 60"),
              ],
            ),
          ),

          // Step Indicator
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) =>
                  Container(
                    width: 120,
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

          // Navigation Buttons
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                OutlinedButton(
                  onPressed: () => widget.onBack(_selectedAgeGroup),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    'Previous',
                    style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                // Next Button
                ElevatedButton(
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
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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