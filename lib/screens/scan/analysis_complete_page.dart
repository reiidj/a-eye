import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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

    Future.delayed(const Duration(seconds: 2), () async {
      final userBox = Hive.box('userBox');
      final userName = userBox.get('name') ?? 'Guest';

      final scanBox = Hive.box('scanResultsBox');
      final String? imagePath = scanBox.get('latestImagePath');

      final bool isMature = DateTime.now().millisecondsSinceEpoch % 2 == 0;
      final resultTitle = isMature ? 'Mature Cataract' : 'Immature Cataract';

      final List existingResults = scanBox.get('results', defaultValue: []).cast<Map>();

      final newResult = {
        'date': DateFormat('MMMM d, y, h:mm a').format(
          DateTime.now().toUtc().add(const Duration(hours: 8)),
        ),
        'title': resultTitle,
        'imagePath': imagePath,
      };

      existingResults.insert(0, newResult);
      await scanBox.put('results', existingResults);

      // Navigate to correct result page
      Navigator.pushNamed(
        context,
        isMature ? '/mature' : '/immature',
        arguments: {'name': userName},
      );
    });
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
