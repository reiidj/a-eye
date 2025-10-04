import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadInvalidPage extends StatelessWidget {
  final String imagePath;
  final String reason;
  final VoidCallback? onBack;

  const UploadInvalidPage({
    super.key,
    required this.imagePath,
    required this.reason,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.1149,
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  "Image Review",
                  style: GoogleFonts.urbanist(
                    color: const Color(0xFF5E7EA6),
                    fontSize: screenWidth * 0.0625,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.5095,
                width: double.infinity,
                child: imagePath.isNotEmpty && File(imagePath).existsSync()
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : Container(
                  color: Colors.grey[800],
                  child: const Center(child: Text('No image available')),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.09,
                  vertical: screenHeight * 0.015,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFA20000).withOpacity(0.49),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Text(
                          reason,
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.0425,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.09),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onBack ?? () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Re-upload Image",
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/guide');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5244F3),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Scan Guide",
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}