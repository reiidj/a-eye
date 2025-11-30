/*
 * Program Title: routes.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module serves as the central nervous system for application navigation.
 *   It defines the static routing table (`appRoutes`) that maps string
 *   identifiers (e.g., '/welcome') to specific Widget constructors. It also
 *   handles the extraction and type-casting of arguments passed between screens,
 *   particularly converting raw JSON data from the `AnalyzingPage` into
 *   strongly-typed parameters for the `ResultsPage`.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To decouple navigation logic from individual screens, providing a single
 *   source of truth for the app's structure and ensuring type safety when
 *   passing complex data objects between route boundaries.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * Map<String, WidgetBuilder>: The core lookup table for named routes.
 *     * Enum (CataractType): Used to normalize string classifications.
 *
 *   Algorithms:
 *     * String Normalization: `_determineCataractType` cleans and parses raw
 *       API strings to determine the correct medical classification enum.
 *     * Safe Casting: Converts dynamic numeric types (int/double) from JSON
 *       maps into Dart doubles to prevent runtime type errors.
 *
 *   Control:
 *     * ModalRoute Extraction: Retrieves arguments passed via
 *       `Navigator.pushNamed`.
 *     * Conditional Fallback: Provides default values ('Guest', 'Immature') if
 *       expected arguments are missing or malformed.
 */


import 'package:flutter/material.dart';
import 'package:a_eye/screens/onboarding/landing_page.dart';
import 'package:a_eye/screens/onboarding/user_data_page.dart';

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

import 'package:a_eye/screens/crop_guide_page.dart';
import 'package:a_eye/auth_check_screen.dart';

/*
 * Function: _determineCataractType
 * Purpose: Helper algorithm to map API string results to internal Enums.
 * Logic: Case-insensitive substring matching.
 */
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

  // Default to immature if unclear to avoid crashing
  print("WARNING: Unknown classification '$classification', defaulting to immature");
  return CataractType.immature;
}

/// Data Structure: appRoutes
/// Purpose: A map linking route names (Strings) to Widget Builders.
final Map<String, WidgetBuilder> appRoutes = {

  // -- SECTION: AUTHENTICATION & ENTRY --
  '/': (context) => const AuthCheckScreen(),

  // -- SECTION: ONBOARDING FLOW --
  '/landing': (context) => LandingPage(
    onNext: () {
      // Control: Replace stack to prevent going back to splash
      Navigator.pushReplacementNamed(context, '/userData');
    },
  ),

  //  New Consolidated Onboarding Route
  '/userData': (context) => const UserDataPage(),

  // -- SECTION: DASHBOARD --
  '/welcome': (context) {
    // Extract arguments sent from Auth or Results page
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userName = args?['userName'] as String? ?? 'Guest';

    // Return the WelcomeScreen with required callbacks for navigation
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

  '/ProfilePage': (context) {
    return ProfilePage(
      onNext: () => Navigator.pushNamed(context, '/scanMode'),
    );
  },

  // -- SECTION: SCAN SETUP FLOW --
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

  // -- SECTION: CAMERA CAPTURE FLOW --
  '/camera': (context) => const CameraPage(),

  '/crop': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return CropImagePage(
      imagePath: args['imagePath'] as String,
    );
  },

  '/invalid': (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return InvalidImagePage(
      imagePath: args['imagePath'] as String,
      reason: args['reason'] as String,
      onBack: () => Navigator.pop(context),
    );
  },

  // -- SECTION: ANALYSIS LOGIC --
  '/analyzing': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return AnalyzingPage(
      onComplete: () {
        // Forward the arguments to the complete page if needed
        Navigator.pushNamed(context, '/complete', arguments: args);
      },
    );
  },

  '/results': (context) {
    // -- DATA EXTRACTION --
    final analysisResult = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String classification = analysisResult['classification'];

    // -- ALGORITHM: TYPE CASTING --
    // Control: Ensure numeric types from JSON are safely converted to double
    final double confidence = (analysisResult['confidence'] as num).toDouble();
    final double classificationScore = (analysisResult['classificationScore'] as num).toDouble();

    final String explainedImageBase64 = analysisResult['explained_image_base64'];
    final String explanationText = analysisResult['explanation'];
    final String userName = analysisResult['userName'] ?? 'Guest';

    // Logic: Convert string classification to Enum for the UI
    final CataractType cataractType = _determineCataractType(classification);

    return ResultsPage(
      userName: userName,
      confidence: confidence, // Passed as double (e.g., 0.9876)
      classificationScore: classificationScore, // Passed as double (e.g., 0.7543)
      explainedImageBase64: explainedImageBase64,
      explanationText: explanationText,
      cataractType: cataractType,
    );
  },

  // -- SECTION: UPLOAD FLOW --
  '/uploadSelect': (context) => SelectPage(
    onNext: () {
      // Note: Navigation logic handled internally by SelectPage
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

  // -- SECTION: HELP --
  '/cropGuide': (context) => const CropGuidePage(),
};