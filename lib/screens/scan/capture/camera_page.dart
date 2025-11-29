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
 *   This module is located in `lib/screens/scan/capture/` and is a critical
 *   component of the "Analysis Flow". It interfaces directly with the device
 *   hardware to capture high-resolution images of the user's eye. It handles
 *   raw byte stream management, real-time preview rendering, and initial
 *   image pre-processing (compression and mirroring) before passing the file
 *   to the cropping stage.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a custom camera interface with specific UI guides (crosshairs)
 *   to assist users in capturing centered, focused images of their eyes,
 *   while managing hardware resources and storage optimization.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * CameraController: Managing connection to the device's camera sensor.
 *     * List<CameraDescription>: Storing available lens configurations (front/back).
 *     * XFile/File: Handling temporary storage of captured image data.
 *
 *   Algorithms:
 *     * Image Compression: Uses `FlutterImageCompress` to reduce file size
 *       (quality 85) to optimize upload speed to the API.
 *     * Matrix Transformation: Applies `img.flipHorizontal` if the front
 *       camera is used, ensuring the image matches the user's mirror view.
 *
 *   Control:
 *     * Lifecycle Management: Strictly initializes and disposes the camera
 *       controller to prevent memory leaks or hardware locks.
 *     * Asynchronous Execution: Uses `Future/await` for all hardware I/O
 *       and file system operations.
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

/// Class: CameraPage
/// Purpose: Stateful widget that renders the camera viewfinder and controls.
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // -- LOCAL STATE --
  String _selectedEye = 'Left'; // Tracks metadata for the analysis report
  CameraController? _controller; // Hardware interface
  Future<void>? _initializeControllerFuture;
  bool _cameraInitialized = false;
  String? _errorMessage;
  int _selectedCameraIndex = 0; // Toggles between front (1) and back (0)
  List<CameraDescription> _availableCameras = [];
  bool _isProcessing = false; // Semaphore to prevent double-clicks during capture

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  /*
   * Function: _setupCamera
   * Purpose: Asynchronously fetches available cameras and initializes the first one.
   */
  Future<void> _setupCamera() async {
    try {
      // -- ALGORITHM: HARDWARE DETECTION --
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        if (mounted) setState(() => _errorMessage = 'No cameras available');
        return;
      }
      // Initialize controller with specific resolution preset
      _controller = CameraController(
        _availableCameras[_selectedCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false, // Audio permission not required for static images
      );

      // Control: Wait for hardware initialization before updating UI
      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (mounted) setState(() => _cameraInitialized = true);
      }).catchError((e) {
        if (mounted) setState(() => _errorMessage = 'Failed to initialize camera');
      });
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Camera error: $e');
    }
  }

  // -- CONTROL: RESOURCE MANAGEMENT --
  @override
  void dispose() {
    // Critical: Release camera hardware when leaving the screen
    _controller?.dispose();
    super.dispose();
  }

  /*
   * Function: _takePicture
   * Purpose: Captures frame, processes it (compress/flip), and navigates.
   */
  Future<void> _takePicture() async {
    // Validation: Ensure camera is ready and not currently saving another image
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Capture raw image from sensor
      final XFile image = await _controller!.takePicture();
      final file = File(image.path);

      // -- ALGORITHM: IMAGE COMPRESSION --
      // optimization: Reduce resolution/quality to prevent payload issues with API
      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      // -- ALGORITHM: MIRRORING --
      // Check if front camera was used. If so, flip the image horizontally
      // so the "Left Eye" in the photo matches the "Left Eye" selected in UI.
      if (_availableCameras[_selectedCameraIndex].lensDirection == CameraLensDirection.front) {
        final bytes = await File(compressed!.path).readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final flipped = img.flipHorizontal(decoded);
          final flippedPath = "${file.parent.path}/flipped_${DateTime.now().millisecondsSinceEpoch}.jpg";
          await File(flippedPath).writeAsBytes(img.encodeJpg(flipped, quality: 85));

          // Navigation: Pass processed path to crop screen
          Navigator.pushNamed(
            context,
            '/crop',
            arguments: {
              'imagePath': flippedPath,
              'selectedEye': _selectedEye,
            },
          );
          return;
        }
      }

      // Navigation: Pass standard path if back camera
      Navigator.pushNamed(
        context,
        '/crop',
        arguments: {
          'imagePath': compressed!.path,
          'selectedEye': _selectedEye,
        },
      );
    } catch (e, st) {
      print('[Camera] Capture failed: $e');
      print(st);
      if (mounted) setState(() => _errorMessage = 'Capture failed: $e');
    } finally {
      // Reset processing flag
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _flipCamera() async {
    if (_availableCameras.length < 2) return;
    setState(() {
      // Algorithm: Cycle through camera list index
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
      _cameraInitialized = false;
    });
    await _controller?.dispose(); // Dispose old controller
    await _setupCamera(); // Re-initialize with new index
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: Stack(
        children: [
          Column(
            children: [
              // -- UI COMPONENT: VIEWFINDER --
              SizedBox(
                height: screenHeight * 0.6,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildCameraPreview(),
                    ),
                    // Overlay Guide (Crosshair + Text)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Look at the camera lens',
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: screenWidth,
                                height: screenWidth,
                                child: CustomPaint(painter: CrosshairPainter()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // -- UI COMPONENT: CONTROLS AREA --
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF131A21),
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF5244F3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Flip Camera Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              right: screenWidth * 0.075,
                              bottom: screenHeight * 0.015,
                            ),
                            child: FloatingActionButton(
                              heroTag: 'flip',
                              elevation: 0,
                              highlightElevation: 0,
                              backgroundColor: const Color(0xFF131A21),
                              onPressed: _flipCamera,
                              child: Icon(
                                Icons.cameraswitch_outlined,
                                color: const Color(0xFF5244F3),
                                size: screenWidth * 0.08,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Shutter Button (Visual Design)
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: screenWidth * 0.28,
                          height: screenWidth * 0.28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF131A21),
                            border: Border.all(
                              color: const Color(0xFF5244F3),
                              width: screenWidth * 0.03,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5244F3).withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: const Color(0xFF5244F3).withOpacity(0.2),
                                spreadRadius: 6,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Guide Button
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/guide');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Text(
                          "Capture Guide",
                          style: GoogleFonts.urbanist(
                            color: const Color(0xFF5244F3),
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Loading Overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white)));
    }
    if (!_cameraInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Fix: Ensure Aspect Ratio is preserved to prevent stretching
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize!.height,
            height: _controller!.value.previewSize!.width,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  Widget _eyeButton(String label, double screenWidth) {
    final bool isSelected = _selectedEye == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedEye = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.07,
          vertical: screenWidth * 0.01,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5244F3) : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: label == 'Left' ? const Radius.circular(40) : Radius.zero,
            right: label == 'Right' ? const Radius.circular(40) : Radius.zero,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Class: CrosshairPainter
/// Purpose: Custom Painter to draw the guidance overlay (dashed lines) on the camera.
class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint solidPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;
    final Paint dashedPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6;

    // Calculations for centering the crosshair
    const double gapBeforeDashed = 15;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    const double armLength = 24;
    final double start = armLength + gapBeforeDashed;
    const double dashWidth = 25;
    const double dashSpace = 15;

    // Draw Dashed Lines (Algorithm: Iterative line drawing)
    for (double i = start; i < size.width / 2; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(centerX + i, centerY),
        Offset(centerX + i + dashWidth, centerY),
        dashedPaint,
      );
    }
    for (double i = start; i < size.width / 2; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(centerX - i, centerY),
        Offset(centerX - i - dashWidth, centerY),
        dashedPaint,
      );
    }
    for (double i = start; i < size.height / 2; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(centerX, centerY + i),
        Offset(centerX, centerY + i + dashWidth),
        dashedPaint,
      );
    }
    for (double i = start; i < size.height / 2; i += dashWidth + dashSpace) {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}