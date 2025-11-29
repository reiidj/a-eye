/*
 * Program Title: auth_check_screen.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module serves as the application's "Gatekeeper" or Dispatcher.
 *   It is typically the first widget rendered when the app launches. Its role
 *   is to determine the user's session state (New vs. Returning). It interacts
 *   with `FirebaseAuth` to establish identity (anonymously or securely) and
 *   queries `FirestoreService` to check if the user has completed the
 *   onboarding process, routing them to either the `LandingPage` or `WelcomeScreen`.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a seamless startup experience by automatically logging in users
 *   and directing them to the appropriate screen based on their profile status,
 *   removing the need for a dedicated "Login" screen for anonymous usage.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * User (Firebase): Represents the current authentication session.
 *     * DocumentSnapshot: Represents the user's profile data in the database.
 *
 *   Algorithms:
 *     * Lazy Authentication: Automatically creates an Anonymous account if no
 *       session exists, ensuring every user has a UID for database security rules.
 *     * Profile Verification: Checks for the existence of specific fields (e.g., 'name')
 *       to determine if onboarding was previously completed.
 *
 *   Control:
 *     * FutureBuilder: Manages the UI state (Loading vs. Render) while the
 *       asynchronous auth check performs in the background.
 *     * Conditional Navigation: Uses `Navigator.pushReplacementNamed` to swap
 *       the root view effectively, preventing users from "backing" into the splash screen.
 */


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:a_eye/services/firestore_service.dart';

/// Class: AuthCheckScreen
/// Purpose: Stateless widget that handles initial routing logic.
class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // -- CONTROL: ASYNC UI BUILDER --
    return FutureBuilder<User?>(
      future: _checkAuthAndOnboarding(),
      builder: (context, snapshot) {
        // State 1: Loading (Auth check in progress)
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

        // State 2: Complete (Determine where to go)
        // Algorithm: Schedule navigation for the next frame to avoid
        // "setState() or markNeedsBuild() called during build" errors.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateBasedOnAuth(context, snapshot.data);
        });

        // Show loading spinner while waiting for the navigation callback to fire
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

  /*
   * Function: _checkAuthAndOnboarding
   * Purpose: resolving the current Firebase User, creating one if necessary.
   */
  Future<User?> _checkAuthAndOnboarding() async {
    // -- ALGORITHM: LAZY AUTHENTICATION --
    // Get current user session from disk cache
    User? user = FirebaseAuth.instance.currentUser;

    // If no user (First install or cleared data), sign in anonymously
    if (user == null) {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      user = userCredential.user;
    }

    return user;
  }

  /*
   * Function: _navigateBasedOnAuth
   * Purpose: Checks Firestore for profile completeness and routes the user.
   */
  Future<void> _navigateBasedOnAuth(BuildContext context, User? user) async {
    if (user == null) {
      // Error Handling: Should not happen due to anon auth, but fallback safely
      Navigator.pushReplacementNamed(context, '/landing');
      return;
    }

    try {
      // -- ALGORITHM: PROFILE VERIFICATION --
      // Query database to see if this UID has data
      final userDoc = await FirestoreService().getUser(user.uid);

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Logic: A user is "Onboarded" only if they have a valid Name.
        if (userData.containsKey('name') &&
            userData['name'] != null &&
            userData['name'].toString().isNotEmpty) {

          // Path A: Returning User -> Go to Dashboard
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

      // Path B: New User / Incomplete Profile -> Go to Onboarding
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } catch (e) {
      // -- CONTROL: ERROR HANDLING --
      // If DB fails (offline/permissions), default to Landing to allow retry
      print('Error checking user data: $e');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }
}