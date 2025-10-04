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
    final imageWidget = imageFilePath != null
        ? Image.file(
      File(imageFilePath!),
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, size: 80, color: Colors.white30);
      },
    )
        : Image.asset(
      imageAsset ?? 'assets/images/placeholder.png',
      width: 80,
      height: 80,
      fit: BoxFit.cover,
    );

    // FIX: Check if title is "Mature Cataract" specifically (not "Immature")
    final bool isMature = title.toLowerCase().contains('mature') &&
        !title.toLowerCase().contains('immature');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Most Recent",
              style: GoogleFonts.urbanist(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.urbanist(fontSize: 15, color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 4),
                    // FIX: Display title as-is without appending "Cataract"
                    Text(
                      title,
                      style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    if (isMature)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0x26FF6767),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_rounded, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Please consult now with an eye doctor.",
                                  style: GoogleFonts.urbanist(
                                    fontSize: 14,
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