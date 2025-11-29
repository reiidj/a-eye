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
 *   This module is located in `lib/screens/scan/upload/` and handles the
 *   cropping stage specifically for the "Upload Flow" (Gallery selection).
 *   Similar to the camera crop screen, it normalizes the image resolution,
 *   provides a manual crop interface, and performs API validation.
 *   Uniquely, upon validation failure, it routes to `UploadInvalidPage`,
 *   ensuring the user returns to the gallery selection context rather than
 *   the camera viewfinder.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To allow users to refine images selected from their device storage,
 *   ensuring the pupil is centered and the image quality meets the API
 *   requirements before proceeding to analysis.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * Uint8List (_imageData): Stores the binary image data for the cropper.
 *     * CropController: Manages crop area coordinates and actions.
 *
 *   Algorithms:
 *     * Image Resizing: Downscales high-resolution gallery images to a max
 *       of 2048px to prevent memory crashes on the texture rendering engine.
 *     * API Validation: Sends the cropped segment to the backend to check
 *       for blur, brightness, and eye detection.
 *
 *   Control:
 *     * Conditional Navigation: Routes to `/analyzing` if valid, or pushes
 *       `UploadInvalidPage` onto the stack if invalid.
 *     * Asynchronous Loading: Handles file I/O and decoding off the UI thread.
 */


import 'dart:io';
import 'dart:typed_data';
import 'package:a_eye/screens/scan/upload/upload_invalid_page.dart';
import 'package:a_eye/services/api_service.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;

/// Class: UploadCropPage
/// Purpose: Stateful widget for cropping images sourced from device storage.
class UploadCropPage extends StatefulWidget {
  // -- INPUT PARAMETERS --
  final String imagePath;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const UploadCropPage({
    super.key,
    required this.imagePath,
    this.onNext,
    this.onBack,
  });

  @override
  State<UploadCropPage> createState() => _UploadCropPageState();
}

class _UploadCropPageState extends State<UploadCropPage> {
  // -- LOCAL STATE --
  final CropController _cropController = CropController();
  late Uint8List _imageData;
  bool _isCropping = false; // UI Lock
  bool _imageReady = false; // Loading Indicator State

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  /*
   * Function: _loadImage
   * Purpose: Reads the file, normalizes resolution for performance, and updates state.
   */
  Future<void> _loadImage() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();

      // -- ALGORITHM: NORMALIZATION --
      // Gallery images can be huge (12MP+). We decode and resize to max 2048px.
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        img.Image normalized = decoded;

        if (normalized.width > 2048 || normalized.height > 2048) {
          normalized = img.copyResize(
            normalized,
            width: normalized.width > normalized.height ? 2048 : null,
            height: normalized.height > normalized.width ? 2048 : null,
          );
        }

        // Re-encode to JPEG for the widget display
        _imageData = Uint8List.fromList(img.encodeJpg(normalized, quality: 92));
      } else {
        _imageData = bytes; // Fallback
      }

      if (mounted) {
        setState(() => _imageReady = true);
      }
    } catch (e) {
      print(' Image load error: $e');
      // Fallback: Try reading raw bytes if processing fails
      try {
        final file = File(widget.imagePath);
        _imageData = await file.readAsBytes();
        if (mounted) {
          setState(() => _imageReady = true);
        }
      } catch (fallbackError) {
        print(' Fatal image load error: $fallbackError');
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
   * Purpose: Handles crop completion, temp saving, API validation, and routing.
   */
  void _onCropped(Uint8List croppedData) async {
    try {
      if (croppedData.isEmpty) {
        throw Exception('Cropped image is empty');
      }

      final decoded = img.decodeImage(croppedData);
      if (decoded == null) {
        throw Exception('Failed to decode cropped image');
      }

      // -- CONTROL: SIZE CHECK --
      // Prevent analysis of thumbnails or accidental tiny crops
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

      // Encode final crop
      final jpegBytes =
      Uint8List.fromList(img.encodeJpg(decoded, quality: 92));

      // Save to temporary cache for API upload
      final tempPath =
          '${Directory.systemTemp.path}/cropped_eye_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(tempPath).writeAsBytes(jpegBytes);

      // -- ALGORITHM: API VALIDATION --
      final ApiService apiService = ApiService();
      final validationResult = await apiService.validateImage(tempPath);

      if (!mounted) return;

      // -- CONTROL: BRANCHING LOGIC --
      if (validationResult['isValid'] == true) {
        // Success: Navigate to Analyzing Page
        setState(() => _isCropping = false);
        Navigator.pushNamed(
            context,
            '/analyzing',
            arguments: {
              'imageBytes': jpegBytes,
              'imagePath': tempPath,
            }
        );
      } else {
        // Failure: Navigate to specific Upload Invalid Page
        setState(() => _isCropping = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadInvalidPage(
              imagePath: tempPath,
              reason: validationResult['reason'] ?? 'Validation failed',
              onBack: () {
                Navigator.pop(context); // Close invalid page
                Navigator.pop(context); // Close crop page, return to select page
              },
            ),
          ),
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
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Instruction Bubble
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.remove_red_eye_outlined,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Drag, zoom, and position your eye within the guide.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.urbanist(
                                fontSize: screenWidth * 0.04, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // -- UI COMPONENT: CROPPER WIDGET --
              if (_imageReady)
                SizedBox(
                  height: screenHeight * 0.45,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Crop(
                        image: _imageData,
                        controller: _cropController,
                        onCropped: _onCropped,
                        interactive: true,
                        fixArea: true,
                        aspectRatio: 1, // Force Square Crop
                        withCircleUi: false,
                        baseColor: Colors.black,
                        maskColor: Colors.black.withOpacity(0.6),
                        radius: 8,
                        initialSize: 1,
                        initialArea: null,
                        cornerDotBuilder: (size, edgeAlignment) =>
                        const SizedBox.shrink(),
                      ),
                      // Overlay: Crosshair Painter
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: CrosshairPainter(),
                          ),
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
                        CircularProgressIndicator(
                          color: Color(0xFF5244F3),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading image...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // -- UI COMPONENT: RE-UPLOAD BUTTON --
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Return to gallery selection
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "Re-Upload Image",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.urbanist(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // -- UI COMPONENT: ANALYZE BUTTON --
              // Wrapped button in SizedBox to enforce full width
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Control: Disable button while processing crop/validation
                  onPressed: _imageReady && !_isCropping
                      ? () {
                    setState(() => _isCropping = true);
                    _cropController.crop();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _imageReady && !_isCropping
                        ? const Color(0xFF5244F3)
                        : Colors.grey,
                    padding:
                    EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isCropping)
                        const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      else
                        SizedBox(
                          height: 40,
                          width: 35,
                          child: Image.asset(
                            'assets/images/Eye Scan 2.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        _isCropping ? "Processing..." : "Analyze with A-Eye",
                        style: GoogleFonts.urbanist(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
/// Purpose: Custom painter for the visual guide overlay (grid lines + center dot).
class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint solidPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    final Paint dashedPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2;

    // Grid Calculations
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

    // Draw Center Cross
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

    // Draw Center Dot (Blue fill, White stroke)
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