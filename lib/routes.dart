import 'package:flutter/material.dart';
import 'package:a_eye/screens/onboarding/landing_page.dart';
import 'package:a_eye/screens/onboarding/name_input_page.dart';
import 'package:a_eye/screens/onboarding/gender_select_page.dart';
import 'package:a_eye/screens/onboarding/age_select_page.dart';

// Welcome page
import 'package:a_eye/screens/welcome_screen.dart';
import 'package:a_eye/screens/welcome_screen_with_result.dart';

// Scan setup
import 'package:a_eye/screens/scan_setup/scan_mode_page.dart';
import 'package:a_eye/screens/scan_setup/check_surroundings_1.dart';
import 'package:a_eye/screens/scan_setup/check_surroundings_2.dart';
import 'package:a_eye/screens/scan_setup/disclaimer_page.dart';

// Scan
import 'package:a_eye/screens/scan/capture/camera_page.dart';
import 'package:a_eye/screens/scan/analyzing_page.dart';
import 'package:a_eye/screens/scan/analysis_complete_page.dart';
import 'package:a_eye/screens/scan/result_immature_page.dart';
import 'package:a_eye/screens/scan/result_mature_page.dart';

// Scan/capture
import 'package:a_eye/screens/scan/capture/crop_image_page.dart';
import 'package:a_eye/screens/scan/capture/invalid_image_page.dart';

// Scan/upload
import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:a_eye/screens/scan/upload/upload_select_page.dart';
import 'package:a_eye/screens/scan/upload/upload_invalid_page.dart';

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
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final userName = args['name'];
    return WelcomeScreen(
      userName: userName,
      onNext: () => Navigator.pushNamed(context, '/scanMode'),
    );
  },

  // Welcome page if the user has a history
  '/welcomeWithResult': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final userName = args['name'];
    return WelcomeScreenWithResult(
      userName: userName,
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
  '/camera': (context) => const CameraPage(
  ),

  // NEW: Image processing route that handles the random logic
  '/processImage': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String imagePath = args?['imagePath'] ?? '';
    final String selectedEye = args?['selectedEye'] ?? 'Left';

    // Random logic moved here from camera page
    final random = DateTime.now().millisecondsSinceEpoch % 2;

    // Navigate immediately to either crop or invalid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (random == 0) {
        Navigator.pushReplacementNamed(
          context,
          '/crop',
          arguments: {
            'imagePath': imagePath,
            'selectedEye': selectedEye,
          },
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/invalid',
          arguments: {
            'imagePath': imagePath,
            'selectedEye': selectedEye,
          },
        );
      }
    });

    // Return a loading screen while navigation happens
    return const Scaffold(
      backgroundColor: Color(0xFF131A21),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5244F3),
        ),
      ),
    );
  },

  '/crop': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String imagePath = args?['imagePath'] ?? '';
    final String selectedEye = args?['selectedEye'] ?? 'Left';

    return CropPage(
      imagePath: imagePath,
      onNext: () {
        // Navigate to analyzing page after cropping
        Navigator.pushNamed(context, '/analyzing');
      },
      onBack: () {
        // Go back to camera page
        Navigator.popUntil(context, ModalRoute.withName('/camera'));
      },
    );
  },

  '/invalid': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String imagePath = args?['imagePath'] ?? '';
    final String selectedEye = args?['selectedEye'] ?? 'Left';

    return InvalidPage(
      imagePath: imagePath,
      onBack: () {
        // Go back to camera page
        Navigator.popUntil(context, ModalRoute.withName('/camera'));
      },
    );
  },

  '/analyzing': (context) => AnalyzingPage(
    onComplete: () => Navigator.pushNamed(context, '/complete'),
  ),

  '/complete': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final userName = args?['name'] ?? 'Guest';

    return AnalyzedPage(
      onComplete: () {
        final random = DateTime.now().millisecondsSinceEpoch % 2;
        if (random == 0) {
          Navigator.pushNamed(
            context,
            '/mature',
            arguments: {'name': userName},
          );
        } else {
          Navigator.pushNamed(
            context,
            '/immature',
            arguments: {'name': userName},
          );
        }
      },
    );
  },

  '/mature': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final userName = (args is Map && args.containsKey('name')) ? args['name'] : 'Guest';

    return MaturePage(
      onNext: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreenWithResult(
            userName: userName,
            onNext: () => Navigator.pushNamed(context, '/scanMode'),
          ),
        ),
            (route) => false,
      ),
    );
  },

  '/immature': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final userName = (args is Map && args.containsKey('name')) ? args['name'] : 'Guest';

    return ImmaturePage(
      onNext: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomeScreenWithResult(
            userName: userName,
            onNext: () => Navigator.pushNamed(context, '/scanMode'),
          ),
        ),
            (route) => false,
      ),
    );
  },

  // Upload Flow
  '/uploadSelect': (context) => SelectPage(
    onNext: () {
      final random = DateTime.now().millisecondsSinceEpoch % 2;
      if (random == 0) {
        Navigator.pushNamed(context, '/uploadInvalid');
      } else {
        Navigator.pushNamed(context, '/uploadCrop');
      }
    },
  ),

  '/uploadCrop': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return UploadCropPage(
      imagePath: args['imagePath'],
      onNext: args['onNext'],
      onBack: args['onBack'],
    );
  },

  '/uploadInvalid': (context) => uploadInvalidPage(
    onBack: () => Navigator.pop(context),
  ),
};
