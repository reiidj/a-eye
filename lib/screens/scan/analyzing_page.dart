import 'dart:async';
import 'dart:typed_data';
import 'package:a_eye/screens/scan/results_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/services/firestore_service.dart';
import 'package:a_eye/services/api_service.dart';

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
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['imageBytes'] == null) {
        throw Exception("No image data provided to analyzing page.");
      }

      final Uint8List imageBytes = args['imageBytes'];
      final String imagePath = args['imagePath'] as String? ?? '';

      // 2. Create an instance of the new ApiService and classify the image
      final ApiService apiService = ApiService();
      final Map<String, dynamic> result = await apiService.classifyImage(imageBytes);

      final String classification = result['classification'];
      final double confidence = result['confidence'];
      // final String explanation = result['explanation']; // You can use this later

      // 3. Save the result from the API to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final scanData = {
          'result': classification,
          'confidence': confidence,
          'timestamp': Timestamp.now(),
          'imagePath': imagePath, // In a real app, upload to Firebase Storage and save URL
        };
        // Use your existing FirestoreService to save the data
        await FirestoreService().addScan(user.uid, scanData);
      }

      // --- The rest of the logic remains mostly the same ---

      String userName = 'Guest';
      if (user != null) {
        final userDoc = await FirestoreService().getUser(user.uid);
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          userName = userData['name'] ?? 'Guest';
        }
      }

      final cataractType = classification.contains('Mature')
          ? CataractType.mature
          : CataractType.immature;

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/results',
          arguments: {
            'cataractType': cataractType,
            'prediction': confidence,
            'imagePath': imagePath,
            'userName': userName,
          },
        );
      }
    } catch (e) {
      print("An error occurred during analysis: $e");
      // Optional: Navigate to an error page to inform the user
      // if (mounted) {
      //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ErrorPage(message: e.toString())));
      // }
    }
  }

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