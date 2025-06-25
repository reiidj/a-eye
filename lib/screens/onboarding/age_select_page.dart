import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

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
        // Use border instead of gradient for the highlight effect
        border: isSelected
            ? Border.all(
          color: const Color(0xFF5244F3),
          width: 2,
        )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10, // Semi-transparent color
          borderRadius: BorderRadius.circular(14), // Match outer radius
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
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final userName = args?['name'] ?? 'Guest';
    final gender = args?['gender'] ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Glowing circles
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
                const SizedBox(height: 300), // Pushes content down
                Text(
                  "Your Age Group",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 50,
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

          // Step indicator
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
                OutlinedButton(
                  onPressed: () {
                    if (selectedAgeGroup != null) {
                      Hive.box('userBox').put('name', userName);
                      Hive.box('userBox').put('gender', gender);
                      Hive.box('userBox').put('ageGroup', selectedAgeGroup);

                      widget.onNext(selectedAgeGroup!); // Save current age
                    } else {
                      widget.onBack(''); // Optional fallback
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 16),
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
                ElevatedButton(
                  onPressed: () {
                    if (selectedAgeGroup != null) {
                      widget.onNext(selectedAgeGroup!); // Save and go to Welcome
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
                    padding: const EdgeInsets.symmetric(horizontal: 63, vertical: 16),
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
