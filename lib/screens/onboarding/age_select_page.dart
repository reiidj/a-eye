import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a_eye/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgeSelectPage extends StatefulWidget {
  final void Function(String ageGroup) onNext;
  final void Function(String ageGroup) onBack;
  final String? initialAgeGroup;

  const AgeSelectPage({
    super.key,
    required this.onNext,
    required this.onBack,
    this.initialAgeGroup,
  });

  @override
  State<AgeSelectPage> createState() => _AgeSelectPageState();
}

class _AgeSelectPageState extends State<AgeSelectPage> {
  String? selectedAgeGroup;

  @override
  void initState() {
    super.initState();
    selectedAgeGroup = widget.initialAgeGroup;
  }

  // AGE OPTION WIDGET
  Widget ageOption(String age) {
    final bool isSelected = selectedAgeGroup == age;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(
          color: const Color(0xFF5244F3),
          width: 2,
        )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: RadioListTile<String>(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            age,
            style: const TextStyle(color: Colors.white),
          ),
          value: age,
          groupValue: selectedAgeGroup,
          onChanged: (value) => setState(() => selectedAgeGroup = value),
          activeColor: const Color(0xFF5244F3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userName = args['name'] as String;
    final gender = args['gender'] as String;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background UI elements...
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


          // Content nung age radio buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 250), // Pushes content down
                Text(
                  "Your Age Group",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 45,
                  ),
                ),
                const SizedBox(height: 30),

                // Age options
                ageOption("Under 20"),
                const SizedBox(height: 15),
                ageOption("20 - 40"),
                const SizedBox(height: 15),
                ageOption("40 - 60"),
                const SizedBox(height: 15),
                ageOption("Above 60"),
              ],
            ),
          ),
          // Step indicator and other UI...
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5244F3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  width: 120,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5244F3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  width: 120,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5244F3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),

          // Navigation buttons
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // previous button
                OutlinedButton(
                  onPressed: () {
                    widget.onBack(''); // Optional fallback
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 45, vertical: 16),
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

                // next button
                ElevatedButton(
                  onPressed: () async {
                    if (selectedAgeGroup != null) {
                      // 3. Get the currently signed-in anonymous user
                      final user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        // 4. Prepare the user data to be saved in Firestore
                        final userData = {
                          'name': userName,
                          'gender': gender,
                          'ageGroup': selectedAgeGroup,
                          'createdAt': Timestamp.now(),
                        };

                        // 5. Use the FirestoreService to save the data
                        await FirestoreService().addUser(user.uid, userData);

                        // 6. Call the original onNext callback to navigate
                        widget.onNext(selectedAgeGroup!);

                      } else {
                        // Handle case where user isn't signed in
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Error: Could not find user."),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 16),
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
              ],
            ),
          ),
          //end of navigation buttons
        ],
      ),
    );
  }
}