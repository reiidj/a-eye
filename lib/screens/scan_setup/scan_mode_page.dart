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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.075,
              vertical: screenHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Text(
                  "Select image input method:",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: screenWidth * 0.105,
                  ),
                ),
                SizedBox(height: screenHeight * 0.07),

                // Circle image hero image
                SizedBox(
                  height: screenWidth * 0.75,
                  width: screenWidth * 0.75,
                  child: Image.asset(
                    'assets/images/AEYE Logo P6.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white30,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.07),

                // onUpload scan button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onUpload,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.085,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Upload an image from gallery",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),

                // On capture scan button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5244F3),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.17,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Capture using camera",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
