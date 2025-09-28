import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:a_eye/database/app_database.dart';

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

  // Current user data
  User? currentUser;

  // Database instance
  late AppDatabase database;

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
    database = AppDatabase();
    _loadUserData();
  }

  /// Load the latest user data from database
  Future<void> _loadUserData() async {
    try {
      setState(() => isLoading = true);

      final user = await database.getLatestUser();

      if (user != null) {
        setState(() {
          currentUser = user;
          nameController.text = user.name;
          _selectedGender = user.gender;
          _selectedAgeGroup = user.ageGroup;
          emailController.text = user.email ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user data found. Please complete onboarding first.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Save updated user data to database
  Future<void> _saveUserData() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gender is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Age group is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => isSaving = true);

      final String name = nameController.text.trim();
      final String gender = _selectedGender!;
      final String ageGroup = _selectedAgeGroup!;
      final String email = emailController.text.trim();

      if (email.isNotEmpty && !_isValidEmail(email)) {
        throw 'Please enter a valid email address';
      }

      if (currentUser != null) {
        final updatedUserCompanion = currentUser!.toCompanion(false).copyWith(
          name: Value(name),
          gender: Value(gender),
          ageGroup: Value(ageGroup),
          email: email.isEmpty ? const Value(null) : Value(email),
        );

        await database.updateUser(updatedUserCompanion);
        final refreshedUser = await database.getUserById(currentUser!.id);
        setState(() => currentUser = refreshedUser);
      } else {
        final newUser = UsersCompanion(
          name: Value(name),
          gender: Value(gender),
          ageGroup: Value(ageGroup),
          email: email.isEmpty ? const Value(null) : Value(email),
          createdAt: Value(DateTime.now()),
        );
        final userId = await database.insertUser(newUser);
        final createdUser = await database.getUserById(userId);
        setState(() => currentUser = createdUser);
      }

      setState(() => isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(
          context,
          '/welcome',
          arguments: {
            'name': name,
            'gender': gender,
            'ageGroup': ageGroup,
            'email': email,
          },
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    database.close();
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

  /// Reusable row builder for text fields
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