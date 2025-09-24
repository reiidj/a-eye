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
import 'package:a_eye/screens/scan/analysis_complete_page.dart';

import 'package:a_eye/screens/scan/results_page.dart';

// Scan/capture
import 'package:a_eye/screens/scan/capture/crop_image_page.dart';
import 'package:a_eye/screens/scan/capture/invalid_image_page.dart';

// Scan/upload
import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:a_eye/screens/scan/upload/upload_select_page.dart';
import 'package:a_eye/screens/scan/upload/upload_invalid_page.dart';

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
  // Landing Page
  '/': (context) => LandingPage(
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
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final userName = args['name'];
    final gender = args['gender'];
    return AgeSelectPage(
      onNext: (ageGroup) {
        Navigator.pushNamed(
          context,
          '/welcome',
          arguments: {
            'name': userName,
            'gender': gender,
            'ageGroup': ageGroup,
          },
        );
      },
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
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String imagePath = args?['imagePath'] ?? '';

    return CropPage(
      imagePath: imagePath,
      onNext: () {
        // Pass the image path to the analyzing page
        Navigator.pushNamed(context, '/analyzing',
            arguments: {'imagePath': imagePath});
      },
      onBack: () {
        Navigator.popUntil(context, ModalRoute.withName('/camera'));
      },
    );
  },

  '/invalid': (context) {
    // Extract the arguments sent from the CameraPage
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Pass the extracted arguments into the widget's constructor
    return InvalidImagePage(
      imagePath: args?['imagePath'] ?? '',
      reason: args?['reason'] ?? "The image isn't suitable for analysis.",
      onBack: () {
        // This popUntil logic is correct
        Navigator.popUntil(context, ModalRoute.withName('/camera'));
      },
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

  '/complete': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Example: read prediction
    final prediction = args?['prediction'] ?? 0.0;
    final imagePath = args?['imagePath'] ?? '';

    return AnalyzedPage(
      prediction: prediction,
      imagePath: imagePath,
    );
  },

  '/results': (context) {
    // Get the arguments passed from the AnalyzingPage
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    // Directly extract the arguments with the correct types
    final cataractType = args['cataractType'] as CataractType;
    final userName = args['userName'] as String;
    final prediction = args['prediction'] as double;
    final imagePath = args['imagePath'] as String;

    // Pass the data directly to the ResultsPage
    return ResultsPage(
      userName: userName,
      prediction: prediction,
      imagePath: imagePath,
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