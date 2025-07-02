import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:a_eye/database/app_database.dart';
import 'package:drift/drift.dart' hide Column;

class NameInputPage extends StatefulWidget {
  final void Function(String name) onNext;
  final VoidCallback onBack;
  final String? initialName;
  final AppDatabase database;

  const NameInputPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.database,
    this.initialName,
  });

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _controller.text = widget.initialName!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background glow
          _buildGlowingBackground(),

          // Step bar
          _buildStepBar(),

          // Name question and input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "What's your name?",
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        maxLength: 20,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          counterText: '',
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Buttons
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildGlowingBackground() {
    return Stack(
      children: [
        Positioned(
          top: -500,
          right: -500,
          child: _glowCircle(),
        ),
        Positioned(
          bottom: -500,
          left: -500,
          child: _glowCircle(),
        ),
      ],
    );
  }

  Widget _glowCircle() {
    return Container(
      width: 1000,
      height: 1000,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [const Color(0xFF5244F3).withOpacity(0.6), Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildStepBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            width: 120,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == 0 ? const Color(0xFF5244F3) : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButtons() {
    return Positioned(
      bottom: 40,
      left: 30,
      right: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF5244F3), width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              'Previous',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () async {
              final name = _controller.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter your name"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              // Check for existing user before inserting
              final existingUsers = await widget.database.getAllUsers();
              if (existingUsers.isEmpty) {
                await widget.database.insertUser(UsersCompanion(
                  name: Value(name),
                  gender: const Value('Not set'),
                  ageGroup: const Value('Not set'),
                ));
              } else {
                final user = existingUsers.first;
                await widget.database.updateUserFields(user.id, name: name);
              }

              widget.onNext(name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5244F3),
              padding: const EdgeInsets.symmetric(horizontal: 63, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              'Next',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Insert into Drift
    await widget.database.insertUser(UsersCompanion(
      name: Value(name),
      gender: const Value('Not set'), // temporary/default
      ageGroup: const Value('Not set'), // temporary/default
    ));

    widget.onNext(name);
  }
}