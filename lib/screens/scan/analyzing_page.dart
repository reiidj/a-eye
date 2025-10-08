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
        // --- SUCCESS PATH ---
        // 4. Extract the data from the result
        final String classification = result['classification'];
        final String confidence = result['confidencePercentage'];
        final String explainedImageBase64 = result['explained_image_base64'] ?? '';
        final String explanationText = result['explanation'] ?? '';

        // 5. Upload image to Firebase Storage and get URL
        final user = FirebaseAuth.instance.currentUser;
        String? imageUrl;

        if (user != null && explainedImageBase64.isNotEmpty) {
          try {
            // Convert base64 to image bytes
            final Uint8List imageBytes = base64Decode(explainedImageBase64);
            final String imageName = 'scan_${DateTime.now().millisecondsSinceEpoch}.png';

            // Upload to Firebase Storage
            final Reference storageRef = FirebaseStorage.instance
                .ref()
                .child('scans/${user.uid}/$imageName');

            final uploadTask = storageRef.putData(imageBytes);
            final snapshot = await uploadTask.whenComplete(() => {});

            // Get the download URL
            imageUrl = await snapshot.ref.getDownloadURL();
            print("Image uploaded to Firebase Storage: $imageUrl");
          } catch (e) {
            print("Error uploading image to Firebase Storage: $e");
            // Continue even if image upload fails
          }
        }

        // 6. Save complete data to Firestore (with Firebase Storage URL)
        if (user != null) {
          final scanData = {
            'result': classification,
            'confidence': confidence,
            'explanation': explanationText, // Added this line to save the explanation
            'timestamp': Timestamp.now(),
            'imagePath': imageUrl ?? imagePath, // Use Firebase URL if available, fallback to local path
          };
          await FirestoreService().addScan(user.uid, scanData);
        }

        // 7. Get userName
        String userName = 'Guest';
        if (user != null) {
          final userDoc = await FirestoreService().getUser(user.uid);
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            userName = userData['name'] ?? 'Guest';
          }
        }

        // 8. Convert classification string to CataractType enum
        CataractType cataractType;
        if (classification.toLowerCase().contains('mature') &&
            !classification.toLowerCase().contains('immature')) {
          cataractType = CataractType.mature;
        } else {
          cataractType = CataractType.immature;
        }

        // 9. Navigate to ResultsPage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                userName: userName,
                confidence: confidence,
                explainedImageBase64: explainedImageBase64,
                explanationText: result['explanation'] ?? '',
                cataractType: cataractType,
              ),
            ),
          );
        }
      }
    } catch (e, st) {
      print("A critical error occurred in _runAnalysisAndNavigate: $e");
      print(st);
      if (mounted) {
        Navigator.pushReplacementNamed(
            context,
            '/uploadInvalid',
            arguments: {'reason': 'A critical error occurred.'}
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
