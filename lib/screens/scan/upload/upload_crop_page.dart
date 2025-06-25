import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:hive/hive.dart';
import 'dart:typed_data';

class UploadCropPage extends StatefulWidget {
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
    _imageData = (await file.readAsBytes()) as Uint8List;
    setState(() {
      _imageReady = true;
    });
  }

  void _onCropped(Uint8List croppedData) async {
    final tempPath = '${Directory.systemTemp.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png';
    final croppedFile = await File(tempPath).writeAsBytes(croppedData as List<int>);

    // Save to Hive
    final box = Hive.box('scanResultsBox');
    await box.put('latestImagePath', croppedFile.path);

    if (mounted) {
      Navigator.pushNamed(context, '/analyzing', arguments: {
        'imagePath': croppedFile.path,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      const Icon(Icons.remove_red_eye_outlined, color: Colors.white),
                      Expanded(
                        child: Text(
                          "Please align your eye with the guide.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.urbanist(fontSize: 17, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Cropper
          if (_imageReady)
            SizedBox(
              height: screenHeight * 0.45,
              width: double.infinity,
              child: Stack(
                children: [
                  Crop(
                    image: _imageData,
                    controller: _cropController,
                    aspectRatio: 1,
                    onCropped: _onCropped,
                    interactive: true,
                    baseColor: Colors.black,
                    maskColor: Colors.black.withOpacity(0.6),
                    cornerDotBuilder: (size, edgeAlignment) => const DotControl(),
                  ),
                  Positioned.fill(child: CustomPaint(painter: CrosshairPainter())),
                ],
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          const SizedBox(height: 60),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 95, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "Re-Upload Image",
                    style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Analyze Button (Disabled until crop is complete)
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: SizedBox(
              width: 337,
              child: ElevatedButton(
                onPressed: _imageReady && !_isCropping
                    ? () {
                  setState(() => _isCropping = true);
                  _cropController.crop();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5244F3),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                      "Analyze with A-Eye",
                      style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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

class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint solidPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6;

    final Paint dashedPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6;

    const double gap = 15;
    const double armLength = 24;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double start = armLength + gap;
    const double dashWidth = 20;
    const double dashSpace = 15;

    for (double i = start; i < size.width / 2; i += dashWidth + dashSpace) {
      canvas.drawLine(Offset(centerX + i, centerY), Offset(centerX + i + dashWidth, centerY), dashedPaint);
      canvas.drawLine(Offset(centerX - i, centerY), Offset(centerX - i - dashWidth, centerY), dashedPaint);
    }

    for (double i = start; i < size.height / 2; i += dashWidth + dashSpace) {
      canvas.drawLine(Offset(centerX, centerY + i), Offset(centerX, centerY + i + dashWidth), dashedPaint);
      canvas.drawLine(Offset(centerX, centerY - i), Offset(centerX, centerY - i - dashWidth), dashedPaint);
    }

    canvas.drawLine(Offset(centerX - armLength, centerY), Offset(centerX + armLength, centerY), solidPaint);
    canvas.drawLine(Offset(centerX, centerY - armLength), Offset(centerX, centerY + armLength), solidPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DotControl extends StatelessWidget {
  const DotControl({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    );
  }
}
