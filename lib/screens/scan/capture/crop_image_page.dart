import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';

class CropImagePage extends StatefulWidget {
  final String imagePath;
  final String selectedEye;

  const CropImagePage({
    super.key,
    required this.imagePath,
    required this.selectedEye,
  });

  @override
  State<CropImagePage> createState() => CropImagePageState();
}

class CropImagePageState extends State<CropImagePage> {
  final CropController _cropController = CropController();
  late Uint8List _imageData;
  bool _isCropping = false;
  bool _imageReady = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = File(widget.imagePath);
    _imageData = await file.readAsBytes();
    if (mounted) {
      setState(() {
        _imageReady = true;
      });
    }
  }

  void _onCropped(Uint8List croppedData) {
    if (mounted) {
      Navigator.pushNamed(context, '/analyzing', arguments: {
        'imageBytes': croppedData,
        'imagePath': widget.imagePath,
        'selectedEye': widget.selectedEye,
      });
    }
  }

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
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  screenWidth * 0.085,
                  screenHeight * 0.02,
                  screenWidth * 0.085,
                  screenHeight * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Crop Image",
                      style: GoogleFonts.urbanist(
                        color: const Color(0xFF5E7EA6),
                        fontSize: screenWidth * 0.0625,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
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
              ),

              // Cropper with enhanced controls
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
                        aspectRatio: 1,
                        withCircleUi: false,
                        baseColor: Colors.black,
                        maskColor: Colors.black.withOpacity(0.6),
                        radius: 8,
                        initialSize: 1,
                        initialArea: null,
                        cornerDotBuilder: (size, edgeAlignment) => const SizedBox.shrink(),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: CrosshairPainter()),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: screenHeight * 0.45,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF5244F3)),
                        SizedBox(height: 16),
                        Text("Loading image...", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: screenHeight * 0.025),

              // Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
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
                          "Retake Photo",
                          style: GoogleFonts.urbanist(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                  ],
                ),
              ),

              // Analyze Button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.01,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _imageReady && !_isCropping
                        ? () {
                      setState(() => _isCropping = true);
                      _cropController.crop();
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _imageReady && !_isCropping ? const Color(0xFF5244F3) : Colors.grey,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
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
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
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
      ..strokeWidth = 4;

    final Paint dashedPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2;

    const double gap = 15;
    const double armLength = 20;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double start = armLength + gap;
    const double dashWidth = 15;
    const double dashSpace = 10;

    for (double i = start; i < size.width / 2 - 20; i += dashWidth + dashSpace) {
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

    for (double i = start; i < size.height / 2 - 20; i += dashWidth + dashSpace) {
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