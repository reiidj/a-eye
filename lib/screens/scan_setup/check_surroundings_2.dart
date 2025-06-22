import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckSurroundings2 extends StatelessWidget {
  final VoidCallback onNext;

  const CheckSurroundings2({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Surroundings 2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Bottom button
          // Bottom button positioned
          Positioned(
            bottom: 20, // Distance from bottom, adjust as needed
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5244F3),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: Image.asset(
                              'assets/images/eye_scan_sprite.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Start Scan",
                            style: GoogleFonts.urbanist(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
