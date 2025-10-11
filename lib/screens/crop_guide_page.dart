import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropGuidePage extends StatelessWidget {
  const CropGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A21),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Crop Guide",
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            _buildGuideSection(
              context,
              title: "Good Crop",
              description:
              "Ensure the eye is centered and fills the entire frame. The eyelids should be open, and the pupil clearly visible.",
              imagePath:
              'assets/images/Good_Crop.png',
              isGoodExample: true,
            ),
            SizedBox(height: screenHeight * 0.04),
            _buildGuideSection(
              context,
              title: "Bad Crop",
              description:
              "Avoid cropping too far out or cutting off parts of the eye. Make sure there are no obstructions like hair or reflections.",
              imagePath:
              'assets/images/Bad_Crop.jpg',
              isGoodExample: false,
            ),
            SizedBox(height: screenHeight * 0.05),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5244F3),
                  padding:
                  EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Got it",
                  style: GoogleFonts.urbanist(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection(BuildContext context,
      {required String title,
        required String description,
        required String imagePath,
        required bool isGoodExample}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconColor = isGoodExample ? Colors.green : Colors.red;
    final iconData = isGoodExample ? Icons.check_circle : Icons.cancel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(iconData, color: iconColor, size: screenWidth * 0.08),
            SizedBox(width: screenWidth * 0.03),
            Text(
              title,
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.03),
        Container(
          height: screenWidth * 0.5,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white30),
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_not_supported,
                        color: Colors.white70, size: 50),
                    const SizedBox(height: 8),
                    Text(
                      'Add image at:\n$imagePath',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        Text(
          description,
          style: GoogleFonts.urbanist(
            color: Colors.white70,
            fontSize: screenWidth * 0.04,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}