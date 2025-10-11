import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:a_eye/services/firestore_service.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _checkAuthAndOnboarding(),
      builder: (context, snapshot) {
        // Show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF161616),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5244F3),
              ),
            ),
          );
        }

        // Auth check complete, navigate based on result
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateBasedOnAuth(context, snapshot.data);
        });

        return const Scaffold(
          backgroundColor: Color(0xFF161616),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5244F3),
            ),
          ),
        );
      },
    );
  }

  Future<User?> _checkAuthAndOnboarding() async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;

    // If no user, sign in anonymously
    if (user == null) {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      user = userCredential.user;
    }

    return user;
  }

  Future<void> _navigateBasedOnAuth(BuildContext context, User? user) async {
    if (user == null) {
      // Should not happen, but fallback to landing
      Navigator.pushReplacementNamed(context, '/landing');
      return;
    }

    try {
      // Check if user has completed onboarding
      final userDoc = await FirestoreService().getUser(user.uid);

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Check if has required fields
        if (userData.containsKey('name') &&
            userData['name'] != null &&
            userData['name'].toString().isNotEmpty) {
          // User has completed onboarding - go to welcome
          if (context.mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/welcome',
              arguments: {'userName': userData['name']},
            );
          }
          return;
        }
      }

      // User hasn't completed onboarding - go to landing
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } catch (e) {
      print('Error checking user data: $e');
      // On error, go to landing page
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }
}