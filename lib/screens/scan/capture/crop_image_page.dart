import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';

class CropPage extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const CropPage({
    super.key,
    required this.imagePath,
    this.onNext,
    this.onBack,
  });

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
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
    setState(() {
      _imageReady = true;
    });
  }

  void _onCropped(Uint8List croppedData) async {
    final tempPath =
        '${Directory.systemTemp.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png';
    final croppedFile = await File(tempPath).writeAsBytes(croppedData);

    // REMOVED HIVE LOGIC: Path is passed via arguments below.
    // final box = Hive.box('scanResultsBox');
    // await box.put('latestImagePath', croppedFile.path);

    if (mounted) {
      Navigator.pushNamed(context, '/analyzing', arguments: {
        'imagePath': croppedFile.path,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains unchanged...
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF131A21),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(34, 40, 34, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Crop Image",
                  style: GoogleFonts.urbanist(
                    color: const Color(0xFF5E7EA6),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          color: Colors.white),
                      Expanded(
                        child: Text(
                          "Drag, zoom, and position your eye within the guide.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.urbanist(
                              fontSize: 17, color: Colors.white),
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
                    cornerDotBuilder: (size, edgeAlignment) =>
                    const SizedBox.shrink(),
                  ),
                  // Custom crosshair overlay - ignore pointer events
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
          const SizedBox(height: 40),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    side:
                    const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 95, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "Re-Upload Image",
                    style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Analyze Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                  backgroundColor: _imageReady && !_isCropping
                      ? const Color(0xFF5244F3)
                      : Colors.grey,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isCropping)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ... (CrosshairPainter remains the same)
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

    // Draw dashed lines extending from center
    for (double i = start; i < size.width / 2 - 20; i += dashWidth + dashSpace) {
      // Horizontal dashed lines
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
      // Vertical dashed lines
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

    // Draw solid center crosshair
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

    // Draw center circle
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