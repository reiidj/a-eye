import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Animate dots every 500ms
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        dotCount = (dotCount + 1) % 4;
        animatedText = "Analyzing${"." * dotCount}";
      });
    });

    // Navigate to the completion page after 3 seconds
    // Navigate to the completion page after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Get the arguments from the current route
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

        // Debug print to see what we have
        print('AnalyzingPage arguments: $args');

        // Pass the arguments along when calling onComplete
        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          // Fallback: navigate directly with arguments
          Navigator.pushNamed(context, '/complete', arguments: args);
        }
      }
    });
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains unchanged...
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 150), // spacing from top to image

          // Image overlayed with Analyzing... text na animated amazing
          SizedBox(
            height: 360, // adjust height if needed
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
                      color: Color(0xFF5244F3),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //Message box
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

          const SizedBox(height: 210), //  gap

          //Supporting note sa baba
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