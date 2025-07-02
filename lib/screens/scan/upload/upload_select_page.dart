import 'dart:io';
import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:a_eye/database/app_database.dart';

class SelectPage extends StatefulWidget {
  final AppDatabase database;
  final void Function(String imagePath) onNext;

  const SelectPage({
    super.key,
    required this.onNext,
    required this.database,
  });

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  File? _selectedImage;

  Future<void> _pickAndSaveImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      // Save a copy to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage = await imageFile.copy(
        '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
      );

      setState(() {
        _selectedImage = savedImage;
      });

      try {
        // Get current user
        final users = await widget.database.getAllUsers();
        if (users.isEmpty) {
          throw Exception("No user found");
        }
        final user = users.first;

        // Insert scan result with placeholder result
        await widget.database.insertScan(
          ScanResultsCompanion(
            userId: Value(user.id),
            imagePath: Value(savedImage.path),
            result: const Value("Pending"),
            timestamp: Value(DateTime.now()),
          ),
        );

        // Use onNext callback and pass the imagePath
        widget.onNext(savedImage.path);
      } catch (e) {
        debugPrint("Failed to save scan: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save scan. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
