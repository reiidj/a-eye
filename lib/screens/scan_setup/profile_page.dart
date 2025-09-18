import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onNext;

  const ProfilePage({super.key, required this.onNext});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for editable fields
  final TextEditingController nameController =
  TextEditingController(text: "Jameia Francois");

  final TextEditingController ageController =
  TextEditingController(text: "19");

  final TextEditingController genderController =
  TextEditingController(text: "Female");

  final TextEditingController emailController =
  TextEditingController(); // start blank

  final double infoFontSize = 20;

  // "Pass-through" save function
  void onSave() {
    final String name = nameController.text.trim();
    final String age = ageController.text.trim();
    final String gender = genderController.text.trim();
    final String email = emailController.text.trim();

    // TODO: Replace this with real Drift save later
    debugPrint("Saving user data -> Name: $name, Age: $age, Gender: $gender, Email: $email");

    // Navigate back to welcome page, passing updated info
    Navigator.pushReplacementNamed(
      context,
      '/welcome',
      arguments: {
        'name': name,
        'age': age,
        'gender': gender,
        'email': email,
      },
    );
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
                image: AssetImage('assets/images/Background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // User information box
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 150, 24, 24),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF131A21),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: Text(
                          "User Information",
                          style: GoogleFonts.urbanist(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const Divider(color: Colors.white30, thickness: 1),
                    _buildInputRow("Name", nameController),
                    const Divider(color: Colors.white30, thickness: 1),
                    _buildInputRow("Age", ageController),
                    const Divider(color: Colors.white30, thickness: 1),
                    _buildInputRow("Gender", genderController),
                    const Divider(color: Colors.white30, thickness: 1),
                    _buildInputRow("Email", emailController),
                    const Divider(color: Colors.white30, thickness: 1),

                    const SizedBox(height: 32),

                    Center(
                      child: OutlinedButton(
                        onPressed: onSave,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF5244F3), width: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                        ),
                        child: Text(
                          "Save My Data",
                          style: GoogleFonts.urbanist(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Circle logo at the top
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: SizedBox(
                height: 210,
                width: 210,
                child: Image.asset(
                  'assets/images/AEYE Logo P6.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      color: Colors.white30,
                      size: 32,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable row builder
  Widget _buildInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(
                fontSize: infoFontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5244F3),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              style: GoogleFonts.urbanist(
                fontSize: infoFontSize,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: label == "Email" ? "Enter your email" : null,
                hintStyle: const TextStyle(color: Colors.white54),
              ),
              keyboardType: label == "Email"
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              autocorrect: label == "Email" ? false : true,
              enableSuggestions: label == "Email" ? false : true,
            ),
          ),
        ],
      ),
    );
  }
}
