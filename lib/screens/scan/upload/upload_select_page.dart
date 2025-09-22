import 'dart:io';
import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:a_eye/image_validator.dart';

class SelectPage extends StatefulWidget {
  final VoidCallback onNext;

  const SelectPage({super.key, required this.onNext});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  // We no longer need the _selectedImage state variable
  // File? _selectedImage;

  // 2. Renamed the function for clarity
  Future<void> _pickAndProcessImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return; // User cancelled the action

    final File imageFile = File(pickedFile.path);

    // 3. Show a loading indicator (optional but good for UX)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // 4. Call the validator
    final ValidationResult validationResult =
    await ImageValidator.validateImageForCataract(imageFile.path);

    // 5. Dismiss the loading indicator
    if (mounted) Navigator.pop(context);
    if (!mounted) return;

    // 6. Navigate based on the validation result
    if (validationResult.isValid) {
      // If valid, navigate to the crop page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UploadCropPage(
            imagePath: imageFile.path,
            onNext: () => Navigator.pushNamed(
              context,
              '/analyzing',
              arguments: {'imagePath': imageFile.path},
            ),
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      // If invalid, navigate to the dedicated invalid page for uploads
      Navigator.pushNamed(
        context,
        '/uploadInvalid',
        arguments: {
          'imagePath': imageFile.path,
          'reason': validationResult.reason,
        },
      );
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
                  onPressed: _pickAndProcessImage,
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