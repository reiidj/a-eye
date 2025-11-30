/*
 * Program Title: user_data_page.dart
 *
 * Programmers:
 * Albonia, Jade Lorenz
 * Villegas, Jedidiah
 * Velante, Kamilah Kaye
 * Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 * This module replaces the fragmented onboarding screens (Name, Gender, Age).
 * It acts as the unified data controller for the Onboarding Flow. It aggregates
 * the user's name, email, gender, and age group in a single form, then interfaces
 * with the `FirestoreService` to commit the full user profile to the cloud database
 * before transitioning the user to the `WelcomeScreen`.
 *
 * Date Written: November 2025
 *
 * Purpose:
 * To provide a unified graphical interface for users to enter their profile details,
 * validate this input, and securely transmit the complete user profile
 * to the backend database while managing UI states (loading, success, error).
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:a_eye/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  // -- LOCAL VARIABLES --
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender;
  String? _selectedAgeGroup;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _ageGroups = ['Under 20', '20 - 40', '40 - 60', 'Above 60'];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /*
   * Function: _handleSubmit
   * Purpose: Validates input, aggregates data, and saves to Firestore.
   * Returns: Future<void> (Asynchronous operation)
   */
  Future<void> _handleSubmit() async {
    // -- CONTROL: INPUT VALIDATION --
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null || _selectedAgeGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // -- CONTROL: UI FEEDBACK --
    setState(() => _isLoading = true);

    try {
      // -- CONTROL: AUTHENTICATION CHECK --
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No user logged in");

      // -- ALGORITHM: DATA PERSISTENCE --
      final firestoreService = FirestoreService();
      // Fetch the next sequential ID
      final int newLocalId = await firestoreService.getNextLocalId();

      // -- DATA STRUCTURE: MAP --
      // Aggregating all user data into a single object
      final Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _selectedGender,
        'ageGroup': _selectedAgeGroup,
        'authUid': user.uid,
        'localId': newLocalId,
        'lastUpdated': Timestamp.now(),
      };

      // Write to database
      await firestoreService.addUser(user.uid, userData);

      // -- CONTROL: NAVIGATION --
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
              (route) => false,
          arguments: {'userName': _nameController.text.trim()},
        );
      }
    } catch (e) {
      // -- CONTROL: ERROR HANDLING --
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper widget for TextFields with consistent styling
  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: type,
          style: GoogleFonts.urbanist(color: Colors.white), // Consistent Font
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            if (type == TextInputType.emailAddress && !value.contains('@')) {
              return 'Invalid email';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "Enter your $label", // Added hint text
            hintStyle: GoogleFonts.urbanist(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), // Matches reference radius
              borderSide: BorderSide.none,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  // Helper widget for Dropdowns with consistent styling
  Widget _buildDropdown(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14), // Matches reference radius
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF161616),
              hint: Text("Select $label",
                  style: GoogleFonts.urbanist(color: Colors.grey.shade600)),
              style: GoogleFonts.urbanist(color: Colors.white), // Consistent Font
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Accessing device dimensions for responsive layout calculations
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // -- UI COMPONENT: BACKGROUND GRADIENTS (Exact Reference Values) --
          Positioned(
            top: -500,
            right: -500,
            child: Container(
              width: 1000,
              height: 1000,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5244F3).withOpacity(0.6),
                    Colors.transparent
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -500,
            left: -500,
            child: Container(
              width: 1000,
              height: 1000,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5244F3).withOpacity(0.6),
                    Colors.transparent
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // -- MAIN CONTENT AREA --
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // Ensure content fills at least the visible height
                      // This ensures it "fits the screen entirely" on large screens
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08, // Responsive side padding
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Spacer
                              SizedBox(height: screenHeight * 0.04),

                              // Header Section
                              Text(
                                "Tell us about yourself",
                                style: GoogleFonts.urbanist(
                                  fontSize: screenWidth * 0.09, // Responsive font
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "This helps us personalize your experience.",
                                style: GoogleFonts.urbanist(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.04),

                              // Form Fields
                              _buildTextField("Full Name", _nameController),
                              SizedBox(height: screenHeight * 0.025),
                              _buildTextField("Email Address", _emailController,
                                  type: TextInputType.emailAddress),
                              SizedBox(height: screenHeight * 0.025),
                              _buildDropdown("Gender", _genders, _selectedGender,
                                      (v) => setState(() => _selectedGender = v)),
                              SizedBox(height: screenHeight * 0.025),
                              _buildDropdown("Age Group", _ageGroups, _selectedAgeGroup,
                                      (v) => setState(() => _selectedAgeGroup = v)),

                              SizedBox(height: screenHeight * 0.05),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5244F3),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 18), // Fixed comfortable height
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                      : Text(
                                    "Continue",
                                    style: GoogleFonts.urbanist(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              // Bottom Spacer to prevent keyboard overlap issues
                              // and ensure bottom padding exists when scrolling
                              SizedBox(height: screenHeight * 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}