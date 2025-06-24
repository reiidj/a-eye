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
import 'package:a_eye/screens/scan/capture/camera_page.dart';
import 'package:a_eye/screens/scan/analyzing_page.dart';
import 'package:a_eye/screens/scan/analysis_complete_page.dart';
import 'package:a_eye/screens/scan/result_immature_page.dart';
import 'package:a_eye/screens/scan/result_mature_page.dart';

// scan/capture folder
import 'package:a_eye/screens/scan/capture/crop_image_page.dart';
import 'package:a_eye/screens/scan/capture/invalid_image_page.dart';

// scan/upload folder
import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:a_eye/screens/scan/upload/upload_select_page.dart';
import 'package:a_eye/screens/scan/upload/upload_invalid_page.dart';


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
          onUpload: () => goToPage(6), // or route to upload instruction page
          onCapture: () => goToPage(9), // or route to capture instruction page
        ),

        selectPage( // THIS IS PAGE 6
          onNext: () {
            final random = DateTime.now().millisecondsSinceEpoch % 2; // Random 0 or 1
            if (random == 0) {
              goToPage(7); // Page 7
            } else {
              goToPage(8); // Page 8
            }
          },
        ),

        uploadInvalidPage( // THIS IS PAGE 7
          onBack: () => goToPage(6),
        ),

        uploadCropPage(// THIS IS PAGE 8
          onNext: () => goToPage(15),
          onBack: () => goToPage(6),
        ),


        CheckSurroundings1( // THIS IS PAGE 9
          onNext: () => goToPage(10),
        ),

        CheckSurroundings2( // THIS IS PAGE 10
          onNext: () => goToPage(11),
        ),

        DisclaimerPage( // THIS IS PAGE 11
          onNext: () => goToPage(12),
        ),

        CameraPage( // THIS IS PAGE 12 ( RANDOMLY GOES TO INVALID IMAGE CAPTURED OR CROP PAGE)
          onNext: () {
            final random = DateTime.now().millisecondsSinceEpoch % 2; // Random 0 or 1
            if (random == 0) {
              goToPage(13); // Page 13
            } else {
              goToPage(14); // Page 14
            }
          },
        ),

        CropPage( // THIS IS PAGE 13
          onNext: () => goToPage(15), // GOES TO ANALYZING PAGE
          onBack: () =>goToPage(12), // GOES TO CAPTURE PAGE IF GUSTO ULIT MAG CAPTURE NG NEW ONE
        ),

        InvalidPage( // THIS IS PAGE 14
          onBack: () =>goToPage(12), //ONLY RETURNS TO CAPTURE PAGE
        ),

        AnalyzingPage(// THIS IS PAGE 15
          onComplete: () => goToPage(16), // Navigate to AnalyzedPage
        ),

        AnalyzedPage( // THIS IS PAGE 16 (RANDOMIZE EITHER GOES TO MATURE OR IMMATURE)
          onComplete: () {
            final random = DateTime.now().millisecondsSinceEpoch % 2; // Random 0 or 1
            if (random == 0) {
              goToPage(17); // Page 17
            } else {
              goToPage(17); // Page 18
            }
          },
        ),

        MaturePage( // THIS IS PAGE 17
          onComplete: () => goToPage(17),
        ),

        ImmaturePage( // THIS IS PAGE 18
          onComplete: () => goToPage(18),
        ),

        // Add more pages here...
      ],
    );
  }
}
