/*
 * Program Title: A-Eye: Cataract Maturity Classification Tool
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is a pivotal step in the "Analysis Flow", positioned between
 *   image acquisition (Camera/Upload) and the AI Analysis. It allows the user
 *   to manually isolate the region of interest (the pupil) from the raw photo.
 *   It acts as a quality gatekeeper, normalizing image resolution and
 *   performing a preliminary API validation check to ensure the cropped
 *   image is suitable for the deep learning model before proceeding.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide an interactive interface for cropping and centering the eye image,
 *   optimizing the file size for network transmission, and handling initial
 *   server-side validation responses.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * Uint8List (_imageData): Holds the binary data of the image in memory
 *       for manipulation without constant file I/O.
 *     * CropController: Manages the state and coordinate system of the crop rect.
 *
 *   Algorithms:
 *     * Image Normalization: Downscales images larger than 2048x2048 using
 *       `img.copyResize` to prevent memory overflows and reduce latency.
 *     * JPEG Encoding: Re-encodes the processed bitmap with 92% quality.
 *     * Input Validation: Rejects crops smaller than 50x50 pixels.
 *
 *   Control:
 *     * Asynchronous State: Manages loading (`_loadImage`) and processing
 *       (`_onCropped`) states to update the UI.
 *     * Navigation Logic: Conditionally routes to `/analyzing` on success or
 *       `/invalid` if the API rejects the image quality.
 */


import 'dart:io';
import 'dart:typed_data';
import 'package:a_eye/services/api_service.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;

/// Class: CropImagePage
/// Purpose: Stateful widget for the image cropping and validation stage.
class CropImagePage extends StatefulWidget {
  // -- INPUT PARAMETERS --
  // The file path passed from CameraPage or UploadPage
  final String imagePath;

  const CropImagePage({
    super.key,
    required this.imagePath,
  });

  @override
  State<CropImagePage> createState() => CropImagePageState();
}

class CropImagePageState extends State<CropImagePage> {
  // -- LOCAL STATE --
  final CropController _cropController = CropController();
  late Uint8List _imageData; // Raw bytes for the cropper widget
  bool _isCropping = false; // UI Lock during processing
  bool _imageReady = false; // Loading state indicator

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /*
   * Function: _loadImage
   * Purpose: Reads the file, normalizes resolution, and updates state.
   */
  Future<void> _loadImage() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();

      // -- ALGORITHM: NORMALIZATION --
      // Decode to check dimensions. Large images cause crashes on older phones.
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        img.Image normalized = decoded;

        // Check if resizing is necessary (Max dimension: 2048px)
        if (normalized.width > 2048 || normalized.height > 2048) {
          normalized = img.copyResize(
            normalized,
            width: normalized.width > normalized.height ? 2048 : null,
            height: normalized.height > normalized.width ? 2048 : null,
          );
        }

        // Re-encode to Uint8List for the view
        _imageData = Uint8List.fromList(img.encodeJpg(normalized, quality: 92));
      } else {
        _imageData = bytes; // Fallback if decoding fails but bytes exist
      }

      if (mounted) {
        setState(() => _imageReady = true);
      }
    } catch (e) {
      print('Image load error: $e');
      // Fallback Mechanism: Try reading bytes directly without processing
      try {
        final file = File(widget.imagePath);
        _imageData = await file.readAsBytes();
        if (mounted) {
          setState(() => _imageReady = true);
        }
      } catch (fallbackError) {
        print('Fatal image load error: $fallbackError');
        // Error Handling: Exit screen if image is unreadable
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load image')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  /*
   * Function: _onCropped
   * Purpose: Handles the crop result, saves to temp, validates via API,
   * and navigates to the next screen.
   */
  void _onCropped(Uint8List croppedData) async {
    try {
      // Validation: Ensure data exists
      if (croppedData.isEmpty) {
        throw Exception('Cropped image is empty');
      }

      final decoded = img.decodeImage(croppedData);
      if (decoded == null) {
        throw Exception('Failed to decode cropped image');
      }

      // -- ALGORITHM: MINIMUM SIZE CHECK --
      // Prevent users from cropping just a few pixels (useless for AI)
      if (decoded.width < 50 || decoded.height < 50) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Cropped area is too small. Please zoom in more.')),
          );
        }
        setState(() => _isCropping = false);
        return;
      }

      // Prepare data for API
      final jpegBytes =
      Uint8List.fromList(img.encodeJpg(decoded, quality: 92));

      // I/O: Save to temporary cache
      final tempPath =
          '${Directory.systemTemp.path}/cropped_eye_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(tempPath).writeAsBytes(jpegBytes);

      // -- CONTROL: API VALIDATION --
      final apiService = ApiService();
      final validationResult = await apiService.validateImage(tempPath);

      if (!mounted) return;

      // Branching Logic based on API response
      if (validationResult['isValid'] == true) {
        // Success: Proceed to Analysis
        setState(() => _isCropping = false);
        Navigator.pushNamed(
          context,
          '/analyzing',
          arguments: {
            'imageBytes': jpegBytes,
            'imagePath': tempPath,
          },
        );
      } else {
        // Failure: Proceed to Invalid Result Screen
        setState(() => _isCropping = false);

        Navigator.pushReplacementNamed(
          context,
          '/invalid',
          arguments: {
            'imagePath': tempPath,
            // Pass the specific reason (e.g., "Blurry", "Not an Eye")
            'reason': validationResult['reason'] ?? 'Validation failed',
          },
        );
      }
    } catch (e) {
      print('Crop processing error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
        setState(() => _isCropping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: SafeArea(
        // Layout: Fixed Column to prevent scroll conflicts with Crop gestures
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              // -- UI COMPONENT: HEADER --
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Crop Image",
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontSize: screenWidth * 0.0625,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Instruction Bubble
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.015),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            "Drag, zoom, and position your eye within the guide.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                              fontSize: screenWidth * 0.0425,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // -- UI COMPONENT: CROPPER INTERFACE --
              if (_imageReady)
                SizedBox(
                  height: screenHeight * 0.45,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // 3rd Party Widget: Handles Matrix Transformations
                      Crop(
                        image: _imageData,
                        controller: _cropController,
                        onCropped: _onCropped,
                        interactive: true,
                        fixArea: true,
                        aspectRatio: 1, // Enforce Square Crop
                        withCircleUi: false,
                        baseColor: Colors.black,
                        maskColor: Colors.black.withOpacity(0.6),
                        radius: 8,
                        initialSize: 1,
                        initialArea: null,
                        cornerDotBuilder: (size, edgeAlignment) =>
                        const SizedBox.shrink(),
                      ),
                      // Overlay: Crosshair Guide
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: CrosshairPainter()),
                        ),
                      ),
                    ],
                  ),
                )
              else
              // Loading State
                SizedBox(
                  height: screenHeight * 0.45,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF5244F3)),
                        SizedBox(height: 16),
                        Text("Loading image...",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              const Spacer(), // Pushes buttons to the bottom

              // -- UI COMPONENT: ACTION BUTTONS --
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side:
                    const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Retake Photo",
                    style: GoogleFonts.urbanist(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Control: Disable button while processing
                  onPressed: _imageReady && !_isCropping
                      ? () {
                    setState(() => _isCropping = true);
                    _cropController.crop(); // Triggers _onCropped
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _imageReady && !_isCropping
                        ? const Color(0xFF5244F3)
                        : Colors.grey,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isCropping)
                        SizedBox(
                          height: screenWidth * 0.05,
                          width: screenWidth * 0.05,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        SizedBox(
                          height: screenWidth * 0.1,
                          width: screenWidth * 0.0875,
                          child: Image.asset(
                            'assets/images/Eye Scan 2.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      SizedBox(width: screenWidth * 0.03),
                      Flexible(
                        child: Text(
                          _isCropping ? "Processing..." : "Analyze with A-Eye",
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              // Help Link
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cropGuide');
                },
                child: Text(
                  "Crop Guide",
                  style: GoogleFonts.urbanist(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5244F3),
                    decorationColor: const Color(0xFF5244F3),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01)
            ],
          ),
        ),
      ),
    );
  }
}

/// Class: CrosshairPainter
/// Purpose: Custom painter for the crop guide overlay (dashed lines + center dot).
class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint solidPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    final Paint dashedPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2;

    // Grid Calculation
    const double gap = 15;
    const double armLength = 20;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double start = armLength + gap;
    const double dashWidth = 15;
    const double dashSpace = 10;

    // Draw Vertical Dashed Lines
    for (double i = start;
    i < size.width / 2 - 20;
    i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(centerX + i, centerY),
        Offset(centerX + i + dashWidth, centerY),
        dashedPaint,
      );
      canvas.drawLine(
        Offset(centerX - i, centerY),
        Offset(centerX - i - dashWidth, centerY),
        dashedPaint,
      );
    }

    // Draw Horizontal Dashed Lines
    for (double i = start;
    i < size.height / 2 - 20;
    i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(centerX, centerY + i),
        Offset(centerX, centerY + i + dashWidth),
        dashedPaint,
      );
      canvas.drawLine(
        Offset(centerX, centerY - i),
        Offset(centerX, centerY - i - dashWidth),
        dashedPaint,
      );
    }

    // Draw Center Solid Cross
    canvas.drawLine(
      Offset(centerX - armLength, centerY),
      Offset(centerX + armLength, centerY),
      solidPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - armLength),
      Offset(centerX, centerY + armLength),
      solidPaint,
    );

    // Draw Center Dot (Target)
    canvas.drawCircle(
      Offset(centerX, centerY),
      6,
      Paint()
        ..color = const Color(0xFF5244F3)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      Offset(centerX, centerY),
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}