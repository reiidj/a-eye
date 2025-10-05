import 'package:flutter/material.dart';
import 'package:a_eye/screens/onboarding/landing_page.dart';
import 'package:a_eye/screens/onboarding/name_input_page.dart';
import 'package:a_eye/screens/onboarding/gender_select_page.dart';
import 'package:a_eye/screens/onboarding/age_select_page.dart';

// Welcome page
import 'package:a_eye/screens/welcome_screen.dart';
import 'package:a_eye/screens/guide_page.dart';

// Scan setup
import 'package:a_eye/screens/scan_setup/scan_mode_page.dart';
import 'package:a_eye/screens/scan_setup/check_surroundings_1.dart';
import 'package:a_eye/screens/scan_setup/check_surroundings_2.dart';
import 'package:a_eye/screens/scan_setup/disclaimer_page.dart';
import 'package:a_eye/screens/scan_setup/profile_page.dart';

// Scan
import 'package:a_eye/screens/scan/capture/camera_page.dart';
import 'package:a_eye/screens/scan/analyzing_page.dart';
import 'package:a_eye/screens/scan/results_page.dart';

// Scan/capture
import 'package:a_eye/screens/scan/capture/crop_image_page.dart';
import 'package:a_eye/screens/scan/capture/invalid_image_page.dart';

// Scan/upload
import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:a_eye/screens/scan/upload/upload_select_page.dart';
import 'package:a_eye/screens/scan/upload/upload_invalid_page.dart';

import 'package:a_eye/auth_check_screen.dart';

CataractType _determineCataractType(String classification) {
  final lowerClassification = classification.toLowerCase().trim();

  // Check for mature indicators
  if (lowerClassification.contains('mature')) {
    return CataractType.mature;
  }

  // Check for immature indicators
  if (lowerClassification.contains('immature')) {
    return CataractType.immature;
  }

  // Default to immature if unclear
  print("WARNING: Unknown classification '$classification', defaulting to immature");
  return CataractType.immature;
}

final Map<String, WidgetBuilder> appRoutes = {

  // Auth page
  '/': (context) => const AuthCheckScreen(),

  // Landing Page
  '/landing': (context) => LandingPage(
    onNext: () {
      Navigator.pushReplacementNamed(context, '/name');
    },
  ),

  // Name Input Page
  '/name': (context) => NameInputPage(
    onNext: (name) {
      Navigator.pushNamed(
        context,
        '/gender',
        arguments: name,
      );
    },
    onBack: () {
      Navigator.pushReplacementNamed(context, '/');
    },
  ),

  // Gender Select Page
  '/gender': (context) {
    final userName = ModalRoute.of(context)!.settings.arguments as String;
    return GenderSelectPage(
      onNext: (gender) {
        Navigator.pushNamed(
          context,
          '/age',
          arguments: {'name': userName, 'gender': gender},
        );
      },
      onBack: (gender) => Navigator.pop(context),
    );
  },

  // Age Select Page
  '/age': (context) {
    // Get the arguments from the previous page
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final userName = args['name'];
    final gender = args['gender'];

    // Pass only the required data and the onBack callback.
    // The onNext logic is now handled inside the AgeSelectPage itself.
    return AgeSelectPage(
      userName: userName,
      gender: gender,
      onBack: (ageGroup) => Navigator.pop(context),
    );
  },

  // Welcome Page
  '/welcome': (context) {
    // Extract the arguments sent from the result page
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userName = args?['userName'] as String? ?? 'Guest';

    // Return the WelcomeScreen with its required callbacks
    return WelcomeScreen(
      userName: userName,
      onNext: () => Navigator.pushNamed(context, '/scanMode'),
      onProfile: () => Navigator.pushNamed(context, '/ProfilePage'),
      onGuide: () => Navigator.pushNamed(context, '/guide'),
    );
  },

  '/guide': (context) {
    return GuidePage(
      onNext: () => Navigator.pushNamed(context, '/scanMode'),
    );
  },

  //Profile page
  '/ProfilePage': (context) {
    return ProfilePage(
      onNext: () => Navigator.pushNamed(context, '/scanMode'),
    );
  },

  // Scan Setup Flow
  '/scanMode': (context) => ScanModePage(
    onUpload: () => Navigator.pushNamed(context, '/uploadSelect'),
    onCapture: () => Navigator.pushNamed(context, '/check1'),
  ),

  '/check1': (context) => CheckSurroundings1(
    onNext: () => Navigator.pushNamed(context, '/check2'),
  ),

  '/check2': (context) => CheckSurroundings2(
    onNext: () => Navigator.pushNamed(context, '/disclaimer'),
  ),

  '/disclaimer': (context) => DisclaimerPage(
    onNext: () => Navigator.pushNamed(context, '/camera'),
  ),

  // Scan Capture
  '/camera': (context) => const CameraPage(),

  '/crop': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return CropImagePage(
      imagePath: args['imagePath'] as String,
      selectedEye: args['selectedEye'] as String,
    );
  },

  '/invalid': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return InvalidImagePage(
      imagePath: args['imagePath'] as String,
      selectedEye: args['selectedEye'] as String,
      reason: args['reason'] as String,
      onBack: () => Navigator.of(context).pop(),
    );
  },

  '/analyzing': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return AnalyzingPage(
      onComplete: () {
        // Forward the arguments to the complete page
        Navigator.pushNamed(context, '/complete', arguments: args);
      },
    );
  },

  '/results': (context) {
    // 1. Get the single 'analysisResult' map passed as an argument.
    final analysisResult = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // 2. Extract the data using the correct keys from your API response.
    final String classification = analysisResult['classification'];
    final String confidence = analysisResult['confidencePercentage'];
    final String explainedImageBase64 = analysisResult['explained_image_base64'];
    final String explanationText = analysisResult['explanation'];
    // Note: 'userName' is not in the API response, so we handle it safely.
    // You will need to pass it along with the analysisResult if you need it.
    final String userName = analysisResult['userName'] ?? 'Guest';

    // 3. Use your helper function to determine the cataract type.
    final CataractType cataractType = _determineCataractType(classification);

    // 4. Pass the processed data to your ResultsPage.
    // IMPORTANT: Your ResultsPage must be updated to accept these parameters.
    return ResultsPage(
      userName: userName,
      confidence: confidence, // e.g., "98.76%"
      explainedImageBase64: explainedImageBase64, // The image string
      explanationText: explanationText, // The detailed report
      cataractType: cataractType,
    );
  },

  // Upload Flow
  '/uploadSelect': (context) => SelectPage(
    onNext: () {
      // This onNext is handled inside the SelectPage widget itself
    },
  ),

  '/uploadCrop': (context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return UploadCropPage(
      imagePath: args['imagePath'],
      onNext: args['onNext'],
      onBack: args['onBack'],
    );
  },

  '/uploadInvalid': (context) {
    // Extract the arguments sent from the UploadSelectPage
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Pass the extracted arguments into the widget's constructor
    return UploadInvalidPage(
      imagePath: args?['imagePath'] ?? '',
      reason: args?['reason'] ?? "The image isn't suitable for analysis.",
      onBack: () => Navigator.pop(context),
    );
  },
};