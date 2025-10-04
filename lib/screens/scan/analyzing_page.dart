import 'dart:async';
import 'dart:typed_data';
import 'package:a_eye/screens/scan/results_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/services/firestore_service.dart';
import 'package:a_eye/services/api_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AnalyzingPage extends StatefulWidget {
  final VoidCallback? onComplete;
  const AnalyzingPage({super.key, this.onComplete});

  @override
  State<AnalyzingPage> createState() => _AnalyzingPageState();
}

class _AnalyzingPageState extends State<AnalyzingPage> {
  String animatedText = "Analyzing";
  int dotCount = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        dotCount = (dotCount + 1) % 4;
        animatedText = "Analyzing${"." * dotCount}";
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnalysisAndNavigate();
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  Future<void> _runAnalysisAndNavigate() async {
    try {
      // 1. Get the image path from the arguments
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['imagePath'] == null) {
        throw Exception("No image path provided to analyzing page.");
      }
      final String imagePath = args['imagePath'];

      // 2. Call the API
      final ApiService apiService = ApiService();
      final Map<String, dynamic> result = await apiService.classifyAndExplainImage(imagePath);

      // 3. Handle the response
      if (result.containsKey('error')) {
        // --- ERROR PATH ---
        // If the API returns an error, show it and stop.
        final String errorMessage = result['error'] ?? 'An unknown analysis error occurred.';
        print("Error during analysis: $errorMessage");

        if (mounted) {
          // Optional: Navigate to an invalid/error page
          Navigator.pushReplacementNamed(
            context,
            '/uploadInvalid', // Or your generic invalid page
            arguments: {'reason': errorMessage, 'imagePath': imagePath},
          );
        }

      } else {
        // --- SUCCESS PATH ---
        // If the API call is successful, proceed.

        // 4. Extract the correct data from the result
        final String classification = result['classification'];
        final String confidence = result['confidencePercentage']; // Use the correct key

        // 5. Save the CORRECT data to Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final scanData = {
            'result': classification,      // e.g., "Mature Cataract"
            'confidence': confidence,      // e.g., "98.76%"
            'timestamp': Timestamp.now(),  // The current time
            'imagePath': imagePath,        // The local path of the image
          };
          // This now saves the correct "Mature" result before you see the history page.
          await FirestoreService().addScan(user.uid, scanData);
        }

        // 6. Navigate to the ResultsPage with the complete, correct data
        if (mounted) {
          // We add the userName here so the results page can display it
          String userName = 'Guest';
          if (user != null) {
            final userDoc = await FirestoreService().getUser(user.uid);
            if (userDoc.exists) {
              final userData = userDoc.data() as Map<String, dynamic>;
              userName = userData['name'] ?? 'Guest';
            }
          }
          result['userName'] = userName;

          Navigator.pushReplacementNamed(
            context,
            '/results',
            arguments: result, // Pass the entire successful result map
          );
        }
      }
    } catch (e, st) {
      print("A critical error occurred in _runAnalysisAndNavigate: $e");
      print(st);
      if (mounted) {
        // Handle unexpected errors (e.g., failed to get arguments)
        Navigator.pushReplacementNamed(context, '/uploadInvalid', arguments: {'reason': 'A critical error occurred.'});
      }
    }
  }
// pass etc etc to firebase
  @override
  Widget build(BuildContext context) {
    // The build method does not need to change.
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 150),
          SizedBox(
            height: 360,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/images/Analyzing.png'),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 54,
                  child: Text(
                    animatedText,
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