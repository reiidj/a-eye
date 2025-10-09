import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String _selectedEye = 'Left';
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _cameraInitialized = false;
  String? _errorMessage;
  int _selectedCameraIndex = 0;
  List<CameraDescription> _availableCameras = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isEmpty) {
        if (mounted) setState(() => _errorMessage = 'No cameras available');
        return;
      }
      _controller = CameraController(
        _availableCameras[_selectedCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final XFile image = await _controller!.takePicture();
      final file = File(image.path);

      final compressed = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (_availableCameras[_selectedCameraIndex].lensDirection == CameraLensDirection.front) {
        final bytes = await File(compressed!.path).readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final flipped = img.flipHorizontal(decoded);
          final flippedPath = "${file.parent.path}/flipped_${DateTime.now().millisecondsSinceEpoch}.jpg";
          await File(flippedPath).writeAsBytes(img.encodeJpg(flipped, quality: 85));
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
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _flipCamera() async {
    if (_availableCameras.length < 2) return;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _availableCameras.length;
      _cameraInitialized = false;
    });
    await _controller?.dispose();
    await _setupCamera();
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
              SizedBox(
                height: screenHeight * 0.6,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _buildCameraPreview(),
                    ),
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

class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint solidPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;
    final Paint dashedPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6;
    const double gapBeforeDashed = 15;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    const double armLength = 24;
    final double start = armLength + gapBeforeDashed;
    const double dashWidth = 25;
    const double dashSpace = 15;
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