import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultCard extends StatelessWidget {
  final String date;
  final String title;
  final String? imageAsset;
  final String? imageFilePath;
  final bool showLabel;

  const ResultCard({
    super.key,
    required this.date,
    required this.title,
    this.imageAsset,
    this.imageFilePath,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final imageWidget = imageFilePath != null
        ? Image.file(
      File(imageFilePath!),
      width: screenWidth * 0.2,
      height: screenWidth * 0.2,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.broken_image,
          size: screenWidth * 0.2,
          color: Colors.white30,
        );
      },
    )
        : Image.asset(
      imageAsset ?? 'assets/images/placeholder.png',
      width: screenWidth * 0.2,
      height: screenWidth * 0.2,
      fit: BoxFit.cover,
    );

    final bool isMature = title.toLowerCase().contains('mature') &&
        !title.toLowerCase().contains('immature');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.02),
            child: Text(
              "Most Recent",
              style: GoogleFonts.urbanist(
                fontSize: screenWidth * 0.0375,
                color: Colors.white,
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(bottom: screenWidth * 0.03),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: const Color(0xFF242443),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageWidget,
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.urbanist(
                        fontSize: screenWidth * 0.0375,
                        color: Colors.grey[300],
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      title,
                      style: GoogleFonts.urbanist(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isMature)
                      Padding(
                        padding: EdgeInsets.only(top: screenWidth * 0.02),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x26FF6767),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.red,
                                size: screenWidth * 0.05,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Text(
                                  "Please consult now with an eye doctor.",
                                  style: GoogleFonts.urbanist(
                                    fontSize: screenWidth * 0.035,
                                    color: const Color(0xFFDD0000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}