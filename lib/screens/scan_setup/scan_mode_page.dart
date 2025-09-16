import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanModePage extends StatelessWidget {
  final VoidCallback onUpload;
  final VoidCallback onCapture;

  const ScanModePage({
    super.key,
    required this.onUpload,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              Text(
                "Select image input method:",
                textAlign: TextAlign.left,
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontSize: 43,
                ),
              ),
              const SizedBox(height: 70),

              //circle image hero image
              SizedBox(
                height: 300,
                width: 300,
                  child: Image.asset(
                    'assets/images/AEYE Logo P6.png',
                    fit: BoxFit.cover, // Ensure the image covers the container
                    // If the image cannot be loaded, the Container's color will show.
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image, // Fallback icon for broken image
                          color: Colors.white30,
                          size: 32,
                        ),
                      );
                    },
                  ),
              ),
              const SizedBox(height: 70),

              // onUpload scan button
              OutlinedButton(
                onPressed: onUpload,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  "Upload an image from gallery",
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // On capture scan button
              ElevatedButton(
                onPressed: onCapture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5244F3),
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  "Capture using camera",
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}
