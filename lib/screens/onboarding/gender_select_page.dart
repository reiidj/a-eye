import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GenderSelectPage extends StatefulWidget {
  final void Function(String gender) onNext;
  final void Function(String gender) onBack;
  final String? initialGender;

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
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialGender;
  }

  // GENDER OPTION WIDGET
  Widget genderOption(String gender) {
    final bool isSelected = selectedGender == gender;

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
            gender,
            style: const TextStyle(color: Colors.white),
          ),
          value: gender,
          groupValue: selectedGender,
          onChanged: (value) => setState(() => selectedGender = value),
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
          // Glowing circles and other UI elements...
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

          // Main scrollable content
          SafeArea(
            child: Column(
              children: [
                // Step indicator
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
                              "Your gender",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.urbanist(
                                color: Colors.white,
                                fontSize: screenWidth * 0.12,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.04),

                            // Gender options
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

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: OutlinedButton(
                          onPressed: () {
                            if (selectedGender != null) {
                              widget.onBack(selectedGender!); // Save + go back
                            } else {
                              widget.onBack(''); // If nothing selected yet, still go back
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.12,
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
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedGender != null) {
                              widget.onNext(selectedGender!);
                            } else {
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
          //end of navigation buttons
        ],
      ),
    );
  }
}