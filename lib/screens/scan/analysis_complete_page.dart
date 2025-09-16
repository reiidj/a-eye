import 'dart:async';
import 'package:a_eye/database/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AnalyzedPage extends StatefulWidget {
  final VoidCallback? onComplete;

  const AnalyzedPage({super.key, this.onComplete});

  @override
  State<AnalyzedPage> createState() => _AnalyzedPageState();
}

class _AnalyzedPageState extends State<AnalyzedPage> {
  @override
  void initState() {
    super.initState();
    _scheduleAnalysisCompletion();
  }

  void _scheduleAnalysisCompletion() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;

      final database = Provider.of<AppDatabase>(context, listen: false);

      // The image path should be passed via arguments from the crop page
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final imagePath = args?['imagePath'] as String?;

      // Get the most recent user to associate the scan with
      final user = await database.getLatestUser();

      if (user == null || imagePath == null) {
        print("Error: Could not find user or image path to save scan.");
        if (mounted) Navigator.pop(context);
        return;
      }

      // Determine the result randomly (as in the original code)
      final isMature = DateTime.now().millisecondsSinceEpoch % 2 == 0;
      final resultTitle = isMature ? 'Mature Cataract' : 'Immature Cataract';

      // Create a new scan record using Drift
      final newScan = ScansCompanion(
        userId: drift.Value(user.id),
        result: drift.Value(resultTitle),
        imagePath: drift.Value(imagePath),
        timestamp: drift.Value(DateTime.now()),
      );

      // Insert the scan into the database
      await database.insertScan(newScan);

      // Navigate to the appropriate result page
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          isMature ? '/mature' : '/immature',
          arguments: {'name': user.name},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // The UI of this page remains the same
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
                    "Analysis completed",
                    style: GoogleFonts.urbanist(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5244F3),
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
                color: Colors.white.withOpacity(0.15),
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
          const SizedBox(height: 210),
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
        ],
      ),
    );
  }
}