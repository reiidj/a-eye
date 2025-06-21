import 'package:flutter/material.dart';
import 'package:a_eye/screens/onboarding/landing_page.dart'; // Update this path if needed

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(), // This must be a SINGLE page here
    );
  }
}
