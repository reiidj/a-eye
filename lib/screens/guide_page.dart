import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuidePage extends StatelessWidget {
  final VoidCallback onNext;

  const GuidePage({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A21),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.06),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "How to Use A-Eye",
          style: GoogleFonts.urbanist(
            color: const Color(0xFF5E7EA6),
            fontSize: screenWidth * 0.0625,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        children: [
          _GuideStep(
            screenWidth: screenWidth,
            icon: Icons.photo_library_outlined,
            title: "1. Select or Capture an Image",
            description: "On the main screen, choose 'Upload Image' "
                "to select a photo from your gallery or 'Capture Image' "
                "to use your camera.",
            tips: [
              "Ensure the eye is clearly visible in the photo",
              "Keep a moderate distance - not too close (at least 6-8 inches away)",
              "The entire eye should fit in the frame with some space around it",
            ],
          ),
          _GuideStep(
            screenWidth: screenWidth,
            icon: Icons.wb_sunny_outlined,
            title: "2. Lighting is Critical",
            description: "Good lighting makes all the difference for accurate results.",
            tips: [
              "Use natural daylight whenever possible - stand near a window",
              "Avoid direct harsh sunlight that causes glare or shadows",
              "If indoors, use bright overhead lighting",
              "Avoid dim lighting, backlighting, or yellow/warm lights",
              "The eye should be evenly lit with no dark shadows",
            ],
          ),
          _GuideStep(
            screenWidth: screenWidth,
            icon: Icons.center_focus_strong,
            title: "3. Image Quality Matters",
            description: "A clear, focused image helps the AI analyze accurately.",
            tips: [
              "Hold your device steady or use a tripod to avoid blur",
              "Make sure the camera focuses on the eye (tap to focus if needed)",
              "Avoid motion blur - stay still for a moment while capturing",
              "Clean your camera lens before taking the photo",
              "Use the back camera for better quality (not selfie mode)",
            ],
          ),
          _GuideStep(
            screenWidth: screenWidth,
            icon: Icons.visibility_outlined,
            title: "4. Eye Positioning",
            description: "Proper eye positioning ensures the best scan results.",
            tips: [
              "Keep the eye fully open - no squinting or partially closed",
              "Look directly at the camera lens",
              "Remove glasses or contact lenses before scanning",
              "Center the eye in the middle of the frame",
              "The pupil and iris should be clearly visible",
            ],
          ),
          _GuideStep(
            screenWidth: screenWidth,
            icon: Icons.crop,
            title: "5. Crop the Image Carefully",
            description: "You'll be asked to crop the image after capture. "
                "Use the guides to position the eye properly.",
            tips: [
              "Drag and zoom so the eye fills most of the cropping area",
              "Align the crosshair with the center of the pupil",
              "Minimize background - focus only on the eye",
              "Make sure the entire iris is within the crop boundary",
            ],
          ),
          _GuideStep(
            screenWidth: screenWidth,
            icon: Icons.analytics_outlined,
            title: "6. Analyze the Image",
            description: "Once you confirm the crop, A-Eye's AI model will analyze "
                "the image to classify the cataract's maturity. This process usually "
                "takes just a few seconds.",
            tips: [],
          ),
          _GuideStep(
            screenWidth: screenWidth,
            icon: Icons.assessment_outlined,
            title: "7. View Your Results",
            description: "A detailed report will be displayed, showing the classification "
                "('Mature' or 'Immature').",
            tips: [
              "Read the medical disclaimer carefully",
              "This app is NOT a substitute for professional diagnosis",
              "Always consult a licensed ophthalmologist for medical advice",
              "Save your report for reference during doctor visits",
            ],
          ),
          _GuideStep(
            screenWidth: screenWidth,
            icon: Icons.history_outlined,
            title: "8. Check Your Scan History",
            description: "Your past scans are saved to your profile. You can access your scan "
                "history at any time by tapping the profile icon on the welcome screen.",
            tips: [],
          ),
          SizedBox(height: screenHeight * 0.02),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFF242443),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFE69146),
                      size: screenWidth * 0.06,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        "Common Reasons for Invalid Images",
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.045,
                          color: const Color(0xFFE69146),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildInvalidReason("Poor lighting or shadows", screenWidth),
                _buildInvalidReason("Blurry or out-of-focus image", screenWidth),
                _buildInvalidReason("Eye not fully visible or partially closed", screenWidth),
                _buildInvalidReason("Too close or too far from camera", screenWidth),
                _buildInvalidReason("Glasses or contacts still on", screenWidth),
                _buildInvalidReason("Eye not centered in frame", screenWidth),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  Widget _buildInvalidReason(String text, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "✗ ",
            style: TextStyle(
              color: Colors.red,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.urbanist(
                fontSize: screenWidth * 0.0375,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final double screenWidth;
  final IconData icon;
  final String title;
  final String description;
  final List<String> tips;

  const _GuideStep({
    required this.screenWidth,
    required this.icon,
    required this.title,
    required this.description,
    this.tips = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.06),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF5244F3),
            size: screenWidth * 0.08,
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  description,
                  style: GoogleFonts.urbanist(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: screenWidth * 0.04,
                    height: 1.4,
                  ),
                ),
                if (tips.isNotEmpty) ...[
                  SizedBox(height: screenWidth * 0.02),
                  ...tips.map((tip) => Padding(
                    padding: EdgeInsets.only(
                      bottom: screenWidth * 0.015,
                      left: screenWidth * 0.02,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• ",
                          style: TextStyle(
                            color: const Color(0xFF5244F3),
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: GoogleFonts.urbanist(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: screenWidth * 0.0375,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}