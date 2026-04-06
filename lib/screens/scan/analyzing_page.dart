/*
 * Program Title: A-Eye: Cataract Maturity Classification Tool
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is the logic core of the "Analysis Flow". It acts as a
 *   bridge between the Image Acquisition (Crop) and the Visualization (Results)
 *   stages. While displaying a loading UI to the user, it orchestrates
 *   asynchronous operations: transmitting the image to the AI API, interpreting
 *   the JSON classification, uploading the result visualization to Firebase
 *   Storage, saving the scan history to Cloud Firestore, and determining the
 *   final navigation route based on success or failure.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a visual feedback mechanism during high-latency network operations,
 *   securely handle data persistence across multiple cloud services, and
 *   robustly manage runtime errors during the analysis phase.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * Timer (_dotTimer): Manages the periodic UI update for the loading animation.
 *     * Map<String, dynamic>: Used extensively for parsing API JSON responses
 *       and structuring Firestore documents.
 *     * Uint8List: Holds binary image data decoded from Base64 strings.
 *
 *   Algorithms:
 *     * Base64 Decoding: Converts the API's string-encoded visualization image
 *       back into raw bytes for storage.
 *     * Helper Parsing (_toDouble): Safely casts dynamic numeric types from JSON
 *       to prevent runtime type errors.
 *
 *   Control:
 *     * Post-Frame Callback: Triggers the async analysis logic only after the
 *       initial UI frame renders to ensure context availability.
 *     * Exception Handling: Catches critical failures (Network, API, Parsing)
 *       and redirects users to the Error Page instead of crashing.
 */


import 'dart:async';
import 'dart:typed_data';
import 'package:a_eye/screens/scan/results_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/services/firestore_service.dart';
import 'package:a_eye/services/api_service.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

/// Class: AnalyzingPage
/// Purpose: Stateful widget handling the "Loading" state and logic orchestration.
class AnalyzingPage extends StatefulWidget {
  final VoidCallback? onComplete;
  const AnalyzingPage({super.key, this.onComplete});

  @override
  State<AnalyzingPage> createState() => _AnalyzingPageState();
}

class _AnalyzingPageState extends State<AnalyzingPage> {
  // -- LOCAL STATE --
  String animatedText = "Analyzing";
  int dotCount = 0;
  Timer? _dotTimer; // Handle for the animation loop

  @override
  void initState() {
    super.initState();

    // -- ALGORITHM: ANIMATION LOOP --
    // Updates the text every 500ms to show "Analyzing.", "Analyzing..", etc.
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        dotCount = (dotCount + 1) % 4;
        animatedText = "Analyzing${"." * dotCount}";
      });
    });

    // -- CONTROL: ASYNC TRIGGER --
    // Ensure the build method completes before starting the heavy async logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysisAndNavigate();
    });
  }

  // -- CONTROL: RESOURCE MANAGEMENT --
  @override
  void dispose() {
    _dotTimer?.cancel(); // Prevent memory leaks
    super.dispose();
  }

  /*
   * Function: _runAnalysisAndNavigate
   * Purpose: The main controller function. Orchestrates API calls, Database
   * writes, and Navigation.
   */
  Future<void> _runAnalysisAndNavigate() async {
    try {
      // 1. Get the image path from the arguments passed by navigation
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['imagePath'] == null) {
        throw Exception("No image path provided to analyzing page.");
      }
      final String imagePath = args['imagePath'];

      // 2. Call the API (High Latency Operation)
      final ApiService apiService = ApiService();
      final Map<String, dynamic> result = await apiService.classifyAndExplainImage(imagePath);

      print('[DEBUG] API Result: $result'); // Debug print

      // 3. Handle the response logic
      if (result.containsKey('error')) {
        // --- CONTROL: ERROR PATH ---
        // Navigate to invalid page if API returns specific logical errors
        final String errorMessage = result['error'] ?? 'An unknown analysis error occurred.';
        print("Error during analysis: $errorMessage");

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/uploadInvalid',
            arguments: {'reason': errorMessage, 'imagePath': imagePath},
          );
        }

      } else {
        // --- CONTROL: SUCCESS PATH ---
        // 4. Extract the data from the result with safe casting
        final String classification = result['classification'] ?? 'Unknown';

        // FIXED: Safe conversion using helper algorithm to handle int/double/string
        final double confidence = _toDouble(result['confidence']) ?? 0.0;
        final double classificationScore = _toDouble(result['classificationScore']) ?? 0.0;

        print('[DEBUG] Confidence: $confidence, ClassificationScore: $classificationScore');

        final String explainedImageBase64 = result['explained_image_base64'] ?? '';
        final String explanationText = result['explanation'] ?? '';

        // 5. Firebase Integration: Upload Result Image
        final user = FirebaseAuth.instance.currentUser;
        String? imageUrl;

        if (user != null && explainedImageBase64.isNotEmpty) {
          try {
            // Algorithm: Base64 Decoding
            // Convert the string from API back into binary image data
            final Uint8List imageBytes = base64Decode(explainedImageBase64);
            final String imageName = 'scan_${DateTime.now().millisecondsSinceEpoch}.png';

            // Upload to Firebase Cloud Storage
            final Reference storageRef = FirebaseStorage.instance
                .ref()
                .child('scans/${user.uid}/$imageName');

            final uploadTask = storageRef.putData(imageBytes);
            final snapshot = await uploadTask.whenComplete(() => {});

            // Fetch the permanent URL for the database
            imageUrl = await snapshot.ref.getDownloadURL();
            print("Image uploaded to Firebase Storage: $imageUrl");
          } catch (e) {
            print("Error uploading image to Firebase Storage: $e");
            // Control: Soft fail - continue even if image upload fails (save text data)
          }
        }

        // 6. Firestore Integration: Save Scan History
        if (user != null) {
          final scanData = {
            'result': classification,
            'confidence': '${(confidence * 100).toStringAsFixed(2)}%',
            'classificationScore': classificationScore,
            'explanation': explanationText,
            'timestamp': Timestamp.now(),
            'imagePath': imageUrl ?? imagePath, // Fallback to local path
          };
          await FirestoreService().addScan(user.uid, scanData);
        }

        // 7. User Metadata Retrieval
        String userName = 'Guest';
        if (user != null) {
          final userDoc = await FirestoreService().getUser(user.uid);
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            userName = userData['name'] ?? 'Guest';
          }
        }

        // 8. Business Logic: Map string result to Enum
        CataractType cataractType;
        if (classification.toLowerCase().contains('mature') &&
            !classification.toLowerCase().contains('immature')) {
          cataractType = CataractType.mature;
        } else {
          cataractType = CataractType.immature;
        }

        // 9. Navigation: Move to Results Page with all gathered data
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                userName: userName,
                confidence: confidence,
                classificationScore: classificationScore,
                explainedImageBase64: explainedImageBase64,
                explanationText: explanationText,
                cataractType: cataractType,
              ),
            ),
          );
        }
      }
    } catch (e, st) {
      // --- CONTROL: CRITICAL ERROR PATH ---
      // Catch-all for network crashes, parsing errors, etc.
      print("A critical error occurred in _runAnalysisAndNavigate: $e");
      print(st);
      if (mounted) {
        Navigator.pushReplacementNamed(
            context,
            '/uploadInvalid',
            arguments: {'reason': 'A critical error occurred: $e'}
        );
      }
    }
  }

  // Algorithm: Safe Numeric Conversion
  // Helper method to handle inconsistent JSON number types (int vs float vs string)
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 150),

          // -- UI COMPONENT: ANIMATED LOADER --
          SizedBox(
            height: 360,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Static Background Image
                const Image(
                  image: AssetImage('assets/images/Analyzing.png'),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Dynamic Text Overlay
                Positioned(
                  bottom: 54,
                  child: Text(
                    animatedText, // Updates via _dotTimer
                    style: GoogleFonts.urbanist(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5244F3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -- UI COMPONENT: INFO CARD --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Early detection helps in treating cataracts more effectively.",
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Spacer(),

          // Footer Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Results are generated in real-time. Please wait a moment while we process your results...",
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}