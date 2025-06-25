import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/onboarding/onboarding_wrapper.dart';


late List<CameraDescription> cameras; // Needed globally

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures camera is initialized first
  cameras = await availableCameras(); // Loads device cameras
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingWrapper(),
    );
  }
}
