import 'dart:io';
import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// REMOVED: import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class SelectPage extends StatefulWidget {
  final VoidCallback onNext;

  const SelectPage({super.key, required this.onNext});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  File? _selectedImage;

  Future<void> _pickAndSaveImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      // Save a copy to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage = await imageFile.copy(
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');

      // REMOVED HIVE LOGIC
      // final scanBox = Hive.box('scanResultsBox');
      // await scanBox.put('latestImagePath', savedImage.path);

      setState(() {
        _selectedImage = savedImage;
      });

      // Navigate and pass image path
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UploadCropPage(
            imagePath: savedImage.path,
            onNext: () => Navigator.pushNamed(context, '/analyzing'),
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The build method remains unchanged...
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Surroundings 1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Bottom button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: OutlinedButton(
                  onPressed: _pickAndSaveImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5244F3), width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    "Upload Image",
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}