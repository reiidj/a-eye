// lib/screens/scan/analyzing_page.dart

import 'dart:async';
import 'dart:typed_data'; // Required for image bytes
import 'package:a_eye/services/analysis_service.dart';
import 'package:a_eye/screens/scan/results_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/services/firestore_service.dart';

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

    // Run analysis after the first frame is built
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
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['imageBytes'] == null) {
        throw Exception("No image data provided to analyzing page.");
      }

      // We only need the image bytes and path from the arguments
      final Uint8List imageBytes = args['imageBytes'];
      final String imagePath = args['imagePath'] as String? ?? '';

      // Create an instance of the service and run the analysis
      final result = await AnalysisService().analyzeImageAndSave(
        imageBytes: imageBytes,
        imagePath: imagePath,
      );

      // Fetch the user's name from Firestore for the results page
      String userName = 'Guest';
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirestoreService().getUser(user.uid);
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userName = userData['name'] ?? 'Guest';
        }
      }

      // Determine the CataractType enum from the classification string
      final cataractType = result.classification.contains('Mature')
          ? CataractType.mature
          : CataractType.immature;

      // Navigate to the results page with all the necessary data
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/results',
          arguments: {
            'cataractType': cataractType,
            'prediction': result.probability,
            'imagePath': imagePath,
            'userName': userName,
          },
        );
      }
    } catch (e) {
      print("An error occurred during analysis: $e");
      // You could navigate to an error page here if you wanted
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains exactly the same
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