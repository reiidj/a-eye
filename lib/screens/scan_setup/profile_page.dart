import 'package:a_eye/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Nullable strings to hold dropdown values
  String? _selectedGender;
  String? _selectedAgeGroup;

  final double infoFontSize = 20;

  // State management
  bool isLoading = true;
  bool isSaving = false;

  // Get current user from Firebase Auth
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();

  // Options for dropdowns
  final List<String> genderOptions = ["Male", "Female", "Other"];
  final List<String> ageGroupOptions = [
    "Under 20",
    "20 - 40",
    "40 - 60",
    "Above 60"
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from Firestore
  Future<void> _loadUserData() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
      // Show an error if no user is logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in.')),
      );
      return;
    }

    try {
      final userDoc = await _firestoreService.getUser(currentUser!.uid);

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = userData['name'] ?? '';
          _selectedGender = userData['gender'];
          _selectedAgeGroup = userData['ageGroup'];
          emailController.text = currentUser!.email ?? (userData['email'] ?? '');
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data: $e')),
      );
    }
  }

  /// Save updated user data to Firestore
  Future<void> _saveUserData() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save, no user is logged in.')),
      );
      return;
    }

    // Basic validation
    if (nameController.text.trim().isEmpty || _selectedGender == null || _selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final updatedData = {
        'name': nameController.text.trim(),
        'gender': _selectedGender,
        'ageGroup': _selectedAgeGroup,
        'email': emailController.text.trim(), // Saving email if you want
      };

      // We use the same 'addUser' method which also works for updating/overwriting data.
      await _firestoreService.addUser(currentUser!.uid, updatedData);

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
      );

      // Navigate back to welcome screen
      Navigator.pushReplacementNamed(context, '/welcome');

    } catch (e) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
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
          if (!isLoading)
            SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(24, 150, 24, 24),
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131A21),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            _buildInputRow("Name", nameController,
                                isRequired: true, maxLength: 15),
                            const Divider(color: Colors.white30, thickness: 1),
                            _buildDropdownRow("Gender", _selectedGender, genderOptions,
                                    (val) => setState(() => _selectedGender = val), isRequired: true),
                            const Divider(color: Colors.white30, thickness: 1),
                            _buildDropdownRow("Age", _selectedAgeGroup, ageGroupOptions,
                                    (val) => setState(() => _selectedAgeGroup = val), isRequired: true),
                            const Divider(color: Colors.white30, thickness: 1),
                            _buildInputRow("Email", emailController,
                                inputType: TextInputType.emailAddress),
                            const Divider(color: Colors.white30, thickness: 1),
                            const SizedBox(height: 32),
                            Center(
                              child: OutlinedButton(
                                onPressed: isSaving ? null : _saveUserData,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isSaving
                                        ? Colors.grey
                                        : const Color(0xFF5244F3),
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 35, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5244F3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Helper Widgets (No backend logic, copied from old design) ---

  Widget _buildDropdownRow(
      String label,
      String? selectedValue,
      List<String> items,
      ValueChanged<String?> onChanged, {
        bool isRequired = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: infoFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5244F3),
                  ),
                ),
                if (isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              dropdownColor: const Color(0xFF131A21),
              underline: Container(),
              hint: Text(
                _getHintText(label),
                style: const TextStyle(color: Colors.white54),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.urbanist(
                      fontSize: infoFontSize,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(
      String label,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        bool isRequired = false,
        int? maxLength,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(
                    fontSize: infoFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5244F3),
                  ),
                ),
                if (isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              maxLength: maxLength,
              style: GoogleFonts.urbanist(
                fontSize: infoFontSize,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: _getHintText(label),
                hintStyle: const TextStyle(color: Colors.white54),
                counterText: "",
              ),
              keyboardType: inputType,
              autocorrect: label != "Email",
              enableSuggestions: label != "Email",
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText(String label) {
    switch (label.toLowerCase()) {
      case 'email':
        return 'Enter your email (optional)';
      case 'age':
        return 'Select your age group';
      case 'name':
        return 'Enter your name';
      case 'gender':
        return 'Select your gender';
      default:
        return 'Enter $label';
    }
  }
}