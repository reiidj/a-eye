import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes.dart'; // Your routes file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures all bindings are initialized
  await Hive.initFlutter(); // Initializes Hive for Flutter

  // Open boxes
  await Hive.openBox('userBox'); // For storing user info
  await Hive.openBox('scanResultsBox'); // For storing scan results

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: appRoutes, // using the map from routes.dart
    );
  }
}
