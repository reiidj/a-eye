/*
 * Program Title: profile_page.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is part of the User Management subsystem. It provides a
 *   CRUD (Create/Read/Update) interface for the user's profile data stored
 *   in Cloud Firestore. It allows users to review and modify their personal
 *   details (Name, Gender, Age, Email) ensuring the metadata attached to
 *   future scans remains accurate. It interacts directly with the
 *   `FirestoreService` and `FirebaseAuth` for identity verification.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To allow users to view their current registered information and update
 *   missing or incorrect fields, specifically capturing an email address
 *   for report delivery.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * TextEditingController: Manages mutable state for text input fields.
 *     * Map<String, dynamic>: Structures data for Firestore document transmission.
 *
 *   Algorithms:
 *     * Asynchronous Data Fetching: Retrieves user documents on initialization
 *       to pre-fill the form.
 *     * Input Validation: Checks for empty strings and null dropdowns before
 *       permitting a database write operation.
 *
 *   Control:
 *     * State Management: Uses `isLoading` and `isSaving` booleans to toggle
 *       between form UI and progress indicators.
 *     * Exception Handling: Catches Firebase errors during read/write operations
 *       and displays feedback via SnackBars.
 */


import 'package:a_eye/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Class: ProfilePage
/// Purpose: Stateful widget for viewing and editing user profile details.
class ProfilePage extends StatefulWidget {
  // -- INPUT PARAMETERS --
  final VoidCallback onNext;

  const ProfilePage({super.key, required this.onNext});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // -- LOCAL STATE --
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? _selectedGender;
  String? _selectedAgeGroup;

  // State flags for UI feedback
  bool isLoading = true; // Toggles initial data fetch spinner
  bool isSaving = false; // Toggles save button spinner

  // -- SERVICES --
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();

  // Dropdown Data Sources
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

  /*
   * Function: _loadUserData
   * Purpose: Fetches existing profile data from Firestore to populate fields.
   */
  Future<void> _loadUserData() async {
    // Validation: Ensure auth state is valid
    if (currentUser == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in.')),
      );
      return;
    }

    try {
      // -- ALGORITHM: READ OPERATION --
      final userDoc = await _firestoreService.getUser(currentUser!.uid);

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        // Update UI state with fetched data
        setState(() {
          nameController.text = userData['name'] ?? '';
          _selectedGender = userData['gender'];
          _selectedAgeGroup = userData['ageGroup'];
          // Fallback to Auth email if Firestore email is missing
          emailController.text = userData['email'] ?? currentUser!.email ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      // Error Handling: Network or Permission errors
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data: $e')),
      );
    }
  }

  /*
   * Function: _saveUserData
   * Purpose: Validates inputs and commits changes to Firestore.
   */
  Future<void> _saveUserData() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save, no user is logged in.')),
      );
      return;
    }

    // -- CONTROL: INPUT VALIDATION --
    // Ensure no required fields are left empty
    if (nameController.text.trim().isEmpty ||
        _selectedGender == null ||
        _selectedAgeGroup == null ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    // Lock UI
    setState(() => isSaving = true);

    try {
      // Prepare payload
      final updatedData = {
        'name': nameController.text.trim(),
        'gender': _selectedGender,
        'ageGroup': _selectedAgeGroup,
        'email': emailController.text.trim(),
      };

      // -- ALGORITHM: WRITE OPERATION --
      // Update or Create the document for the current UID
      await _firestoreService.addUser(currentUser!.uid, updatedData);

      setState(() => isSaving = false);

      // Success Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
      );

      // Logic: Refresh data and navigate back to Welcome screen
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

  // -- CONTROL: MEMORY MANAGEMENT --
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
      // Allow keyboard overlay
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // -- UI COMPONENT: BACKGROUND --
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
          // -- UI COMPONENT: MAIN FORM --
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
                    // Logo
                    SizedBox(
                      height: screenWidth * 0.525,
                      width: screenWidth * 0.525,
                      child: Image.asset(
                        'assets/images/AEYE Logo P6.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Form Container
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

                          // -- UI COMPONENTS: INPUT ROWS --
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

                          // -- UI COMPONENT: SUBMIT BUTTON --
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

          // Loading Overlay
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

  /*
   * Function: _buildDropdownRow
   * Purpose: Helper widget to construct standardized dropdown fields.
   */
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

  /*
   * Function: _buildInputRow
   * Purpose: Helper widget to construct standardized text input fields with optional info icon.
   */
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
                // Info Icon logic for Email field explanation
                if (label.toLowerCase() == 'email')
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.8),
                      size: screenWidth * 0.05,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    // The onPressed callback shows a dialog
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFF131A21),
                            title: Text(
                              "Why We Ask for Your Email",
                              style: GoogleFonts.urbanist(color: Colors.white),
                            ),
                            content: Text(
                              "Your email is requested to send you future copies of your health report.",
                              style: GoogleFonts.urbanist(color: Colors.white70),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  "OK",
                                  style: GoogleFonts.urbanist(color: const Color(0xFF5244F3)),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Closes the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
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