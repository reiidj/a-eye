import 'package:flutter/material.dart';
import 'package:a_eye/screens/onboarding/landing_page.dart';
import 'package:a_eye/screens/onboarding/name_input_page.dart';
import 'package:a_eye/screens/onboarding/gender_select_page.dart';
import 'package:a_eye/screens/onboarding/age_select_page.dart';

//welcome page
import 'package:a_eye/screens/welcome_screen.dart';

//scan_set up folder
import 'package:a_eye/screens/scan_setup/scan_mode_page.dart';
import 'package:a_eye/screens/scan_setup/check_surroundings_1.dart';
import 'package:a_eye/screens/scan_setup/check_surroundings_2.dart';
import 'package:a_eye/screens/scan_setup/disclaimer_page.dart';

//scan folder
import 'package:a_eye/screens/scan/camera_page.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

// wrapper
class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _controller = PageController();

  void goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  //======================================================================================
  // Stores the user name,gender, age group
  //======================================================================================
  String userName = '';
  String gender = '';
  String ageGroup = '';

  // Handle setting the name, gender, and age group
    void handleNameSubmitted(String name) {
      setState(() {
        userName = name;
      });
      goToPage(2); // Go to gender select page after name input
    }

    void handleGenderSelected(String selected) {
      setState(() {
        gender = selected;
      });
      goToPage(3); // Navigate to age select page
    }
    void handleGenderBack(String selected) {
      setState(() {
        gender = selected;
      });
      goToPage(1); // Back to name input
    }

    void handleAgeSelected(String age) {
      setState(() {
        ageGroup = age;
      });
      goToPage(4); // Welcome screen
    }
    void handleAgeBack(String age) {
      setState(() {
        ageGroup = age;
      });
      goToPage(2); // Back to gender
    }

  //======================================================================================
  //======================================================================================


  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        LandingPage(onNext: () => goToPage(1)),
        NameInputPage(
          initialName: userName, //passes the stored name
          onNext: handleNameSubmitted,
          onBack: () => goToPage(0),
        ),

        GenderSelectPage(
          initialGender: gender,
          onNext: handleGenderSelected,   // still same
          onBack: handleGenderBack,       // saves selection before going back
        ),

        AgeSelectPage(
          initialAgeGroup: ageGroup,
          onNext: handleAgeSelected,
          onBack: handleAgeBack,
        ),

        WelcomeScreen(
          userName: userName,
          onNext: () => goToPage(5),
        ),

        ScanModePage(
          onSelfScan: () => goToPage(6), // or route to self-scan instruction page
          onAssistedScan: () => goToPage(6), // or route to assisted-scan instruction page
        ),

        CheckSurroundings1(
          onNext: () => goToPage(7),
        ),

        CheckSurroundings2(
          onNext: () => goToPage(8),
        ),

        DisclaimerPage(
          onNext: () => goToPage(9),
        ),

        CameraPage(
        ),

        // Add more pages here...
      ],
    );
  }
}
