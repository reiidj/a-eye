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

  // Sign in the user anonymously
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
      ),
      initialRoute: '/',
      routes: appRoutes, // Map defined in routes.dart
    );
  }
}