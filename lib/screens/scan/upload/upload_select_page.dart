import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:a_eye/services/api_service.dart';
import 'package:a_eye/screens/scan/upload/upload_invalid_page.dart';

class SelectPage extends StatefulWidget {
  final VoidCallback onNext;

  const SelectPage({super.key, required this.onNext});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  bool _isLoading = false;
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isLoading = true; // Show a loading indicator
      });

      final ApiService apiService = ApiService();
      final validationResult = await apiService.validateImage(image.path);

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (mounted) {
        if (validationResult['isValid'] == true) {
          // Image is valid, proceed to the cropping page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadCropPage(imagePath: image.path),
            ),
          );
        } else {
          // Image is invalid, show the invalid page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadInvalidPage(
                reason: validationResult['reason'],
                imagePath: image.path,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
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
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: OutlinedButton(
                  // 7. Make sure the button calls the new function
                  onPressed: _pickImage,
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