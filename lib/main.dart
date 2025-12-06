/*
 * Program Title: main.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is the root entry point for the entire Flutter application.
 *   Located at the top level of `lib/`, it is responsible for the initial
 *   bootstrapping sequence. It initializes the Flutter engine bindings,
 *   connects to the Firebase backend using platform-specific options,
 *   establishes an anonymous authentication session to ensure database
 *   write access, sets up global error logging, and mounts the root
 *   `MaterialApp` widget which defines the visual theme and navigation routes.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To successfully launch the application environment, ensuring all cloud
 *   services and core configurations are ready before the UI is rendered.
 *
 * Data Structures, Algorithms, and Control:
 *
 *   Data Structures:
 *     * DefaultFirebaseOptions: A configuration object containing API keys
 *       for Android/iOS/Web.
 *     * FlutterErrorDetails: A structural representation of runtime exceptions
 *       used for logging.
 *
 *   Algorithms:
 *     * Asynchronous Initialization: Uses `await` to pause the app launch
 *       until the Firebase SDK is fully connected.
 *     * Anonymous Authentication: Automatically provisions a user ID (`uid`)
 *       without user input to allow immediate, secure access to Firestore.
 *
 *   Control:
 *     * Global Error Handling: Overrides `FlutterError.onError` to intercept
 *       crashes and log them to the developer console via `dart:developer`.
 *     * Widget Tree Mounting: `runApp` attaches the `MyApp` widget to the screen.
 */

import 'package:flutter/material.dart';
import 'routes.dart';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Sign in anonymously to ensure Firestore access
  await FirebaseAuth.instance.signInAnonymously();

  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runApp(const MyApp());
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

        // --- TICKET 3: GLOBAL UI STANDARDIZATION ---
        // 1. Standardized Primary Buttons (Filled)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5244F3), // Brand Color
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56), // Fixed Height
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Fixed Radius
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
            ),
            elevation: 0,
          ),
        ),

        // 2. Standardized Secondary Buttons (Outlined)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56), // Fixed Height
            side: const BorderSide(color: Color(0xFF5244F3), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Fixed Radius
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
            ),
          ),
        ),

        // 3. Standardized Text Buttons (Ghost)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF5244F3),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Urbanist',
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}