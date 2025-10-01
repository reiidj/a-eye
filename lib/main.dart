import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'database/app_database.dart';
import 'dart:developer' as developer;

// Import Firebase Core and the generated options file
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Create a global instance of the database
late AppDatabase database;

void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  // Initialize the local database
  database = AppDatabase();

  // Run the app, providing the database instance to the widget tree
  runApp(
    Provider<AppDatabase>(
      create: (context) => database,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A-Eye',
      theme: ThemeData(
        fontFamily: 'Urbanist',
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: appRoutes, // Map defined in routes.dart
    );
  }
}