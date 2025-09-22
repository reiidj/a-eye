import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:a_eye/database/app_database.dart';
import 'package:a_eye/services/analysis_service.dart';
// Import the ResultsPage to access the CataractType enum
import 'package:a_eye/screens/scan/results_page.dart';

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

  /// The page's only responsibility: get arguments, call the service, and navigate.
  Future<void> _runAnalysisAndNavigate() async {
    // Get the database instance from the provider
    final database = Provider.of<AppDatabase>(context, listen: false);

    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || args['imageBytes'] == null) {
        print("Error: No image data provided.");
        return;
      }

      // Get the current user from the database
      final currentUser = await database.getLatestUser();
      final imagePath = args['imagePath'] as String? ?? '';

      // Call the service with all the required info
      final result = await AnalysisService.analyzeImage(
        imageBytes: args['imageBytes'],
        imagePath: imagePath,
        currentUser: currentUser,
        database: database,
      );

      final userName = currentUser?.name ?? 'Guest';

      // --- FIX: Convert the string classification to the CataractType enum ---
      final cataractType = result.classification == 'Mature'
          ? CataractType.mature
          : CataractType.immature;
      // --- END OF FIX ---

      // Navigate to the single, unified results page with all necessary arguments.
      Navigator.pushReplacementNamed(
        context,
        '/results', // The new unified route
        arguments: {
          // Pass the correct enum type now
          'cataractType': cataractType,
          'prediction': result.probability,
          'imagePath': imagePath,
          'userName': userName,
        },
      );

    } catch (e) {
      print("An error occurred: $e");
      // Optionally, navigate to an error page or show a dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method does not need any changes
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