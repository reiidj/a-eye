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

/// Function: main
/// Purpose: The asynchronous entry point for the Dart execution.
void main() async {
  // -- CONTROL: ENGINE BINDING --
  // Required before making any async calls (like Firebase) in main()
  WidgetsFlutterBinding.ensureInitialized();

  // -- ALGORITHM: FIREBASE INIT --
  // Connects the app to the specific Google Cloud project defined in options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // -- ALGORITHM: AUTO-LOGIN --
  // Sign in the user anonymously immediately on launch.
  // This ensures a valid UID exists for Firestore security rules.
  await FirebaseAuth.instance.signInAnonymously();

  // -- CONTROL: GLOBAL ERROR LOGGING --
  // Intercepts framework errors and logs them to the console/debugger
  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Mount the root widget
  runApp(const MyApp());
}

/// Class: MyApp
/// Purpose: The root Widget of the application tree.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Disable the "Debug" sash in the corner
      debugShowCheckedModeBanner: false,
      title: 'A-Eye',

      // -- UI COMPONENT: THEME CONFIGURATION --
      // Sets global styles (Font, Background Color)
      theme: ThemeData(
        fontFamily: 'Urbanist',
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),

      // -- CONTROL: NAVIGATION ROUTING --
      // Defines the starting screen and the map of all available screens
      initialRoute: '/',
      routes: appRoutes, // Map defined in routes.dart
    );
  }
}