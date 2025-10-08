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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? _selectedGender;
  String? _selectedAgeGroup;

  bool isLoading = true;
  bool isSaving = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();

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

  Future<void> _loadUserData() async {
    if (currentUser == null) {
      setState(() => isLoading = false);
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
          emailController.text = userData['email'] ?? currentUser!.email ?? '';
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

  Future<void> _saveUserData() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save, no user is logged in.')),
      );
      return;
    }

    if (nameController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedAgeGroup == null ||
        emailController.text.trim().isEmpty) {
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
        'email': emailController.text.trim(),
      };

      await _firestoreService.addUser(currentUser!.uid, updatedData);

      setState(() => isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
      );

      // Reload the data to reflect the changes on the page
      await _loadUserData();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      height: screenWidth * 0.525,
                      width: screenWidth * 0.525,
                      child: Image.asset(
                        'assets/images/AEYE Logo P6.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.04,
                        screenHeight * 0.025,
                        screenWidth * 0.04,
                        screenHeight * 0.025,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131A21),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "User Information",
                              style: GoogleFonts.urbanist(
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          const Divider(color: Colors.white30, thickness: 1),
                          _buildInputRow("Name", nameController, screenWidth,
                              isRequired: true, maxLength: 15),
                          const Divider(color: Colors.white30, thickness: 1),
                          _buildDropdownRow("Gender", _selectedGender, genderOptions,
                                  (val) => setState(() => _selectedGender = val), screenWidth,
                              isRequired: true),
                          const Divider(color: Colors.white30, thickness: 1),
                          _buildDropdownRow("Age", _selectedAgeGroup, ageGroupOptions,
                                  (val) => setState(() => _selectedAgeGroup = val), screenWidth,
                              isRequired: true),
                          const Divider(color: Colors.white30, thickness: 1),
                          _buildInputRow("Email", emailController, screenWidth,
                              inputType: TextInputType.emailAddress, isRequired: true),
                          const Divider(color: Colors.white30, thickness: 1),
                          SizedBox(height: screenHeight * 0.04),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: isSaving ? null : _saveUserData,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isSaving
                                        ? Colors.grey
                                        : const Color(0xFF5244F3),
                                    width: 2,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.08,
                                    vertical: screenHeight * 0.02,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32)),
                                ),
                                child: isSaving
                                    ? SizedBox(
                                  height: screenWidth * 0.05,
                                  width: screenWidth * 0.05,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : Text(
                                  "Save My Data",
                                  style: GoogleFonts.urbanist(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
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

  Widget _buildDropdownRow(
      String label,
      String? selectedValue,
      List<String> items,
      ValueChanged<String?> onChanged,
      double screenWidth, {
        bool isRequired = false,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.urbanist(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5244F3),
                    ),
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03),
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
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: screenWidth * 0.04,
                ),
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: screenWidth * 0.06,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.urbanist(
                      fontSize: screenWidth * 0.04,
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
      TextEditingController controller,
      double screenWidth, {
        TextInputType inputType = TextInputType.text,
        bool isRequired = false,
        int? maxLength,
      }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.urbanist(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5244F3),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                if (isRequired)
                  Text(
                    ' *',
                    style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03),
                  ),
                if (label.toLowerCase() == 'email')
                  Tooltip(
                    message: "Your email is requested to send you future copies of your health report.",
                    textStyle: GoogleFonts.urbanist(
                      color: Colors.black,
                      fontSize: screenWidth * 0.03,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white.withOpacity(0.8),
                        size: screenWidth * 0.04,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
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
                fontSize: screenWidth * 0.04,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: _getHintText(label),
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: screenWidth * 0.04,
                ),
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
        return 'Enter your email';
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