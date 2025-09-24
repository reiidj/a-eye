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
    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "How to Use A-Eye",
          style: GoogleFonts.urbanist(
            color: const Color(0xFF5E7EA6),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: const [
          _GuideStep(
            icon: Icons.photo_library_outlined,
            title: "1. Select or Capture an Image",
            description: "On the main screen, choose 'Upload Image' "
                "to select a photo from your gallery or 'Capture Image' "
                "to use your camera. Ensure that there is an eye in the photo, it is"
                "important to not be too close when taking/uploading images.",
          ),

          _GuideStep(
            icon: Icons.crop,
            title: "2. Crop the Image",
            description: "You will be asked to crop the image. "
                "Use the guides to drag, zoom, and position the eye so it fills"
                "the cropping area. A clear, centered image of the eye gives the "
                "best results.",
          ),

          _GuideStep(
            icon: Icons.analytics_outlined,
            title: "3. Analyze the Image",
            description: "Once you confirm the crop, A-Eye's model will analyze "
                "the image to classify the cataract's maturity. This process usually "
                "takes just a few seconds.",
          ),

          _GuideStep(
            icon: Icons.visibility_outlined,
            title: "4. View Your Results",
            description: "A detailed report will be displayed, showing the classification "
                "('Mature' or 'Immature'). Please read the medical disclaimer; this app is not a "
                "substitute for a professional diagnosis.",
          ),

          _GuideStep(
            icon: Icons.history_outlined,
            title: "5. Check Your Profile",
            description: "Your past scans are saved to your profile. You can access your scan "
                "history at any time by tapping the profile icon on the welcome screen.",
          ),
        ],
      ),
    );
  }
}

// Helper widget for styling each step
class _GuideStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuideStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF5244F3), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.urbanist(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}