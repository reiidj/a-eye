/*
 * Program Title: A-Eye: Cataract Maturity Classification Tool
 *
 * Programmers:
 * Albonia, Jade Lorenz
 * Villegas, Jedidiah
 * Velante, Kamilah Kaye
 * Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 * This module serves as the entry point of the Onboarding Flow located in
 * `lib/screens/onboarding/`. It is the very first screen the user encounters
 * upon launching the application. Its primary role is to establish the
 * application's branding and initiate the user journey by routing the user
 * to the profile creation sequence (NameInputPage) via a gesture interaction.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 * To present a visually engaging welcome screen that introduces the app's
 * purpose ("Cataract Maturity Classification") and provides a slide-to-unlock
 * mechanism to prevent accidental navigation initiation.
 *
 * Data Structures, Algorithms, and Control:
 * - Data Structures:
 * * VoidCallback (onNext): A function pointer used to delegate the
 * navigation logic to the parent controller/router.
 * - Algorithms:
 * * Responsive Layout Calculation: Uses `MediaQuery` to dynamically scale
 * font sizes and padding based on the device's screen width/height.
 * * Gradient Shader Generation: Applies a linear gradient mask over text
 * pixels for visual hierarchy.
 * - Control:
 * * Gesture Detection: The `GradientSlideToAct` widget captures drag
 * gestures and triggers the `onNext` callback only upon completion.
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_slide_to_act/gradient_slide_to_act.dart';

/// Class: LandingPage
/// Purpose: Stateless widget representing the introductory splash screen.
class LandingPage extends StatelessWidget {
  // -- INPUT PARAMETERS --
  // Callback to trigger navigation to the Name Input screen
  final VoidCallback onNext;

  const LandingPage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    // -- ALGORITHM: RESPONSIVE SCALING --
    // Get screen dimensions to calculate relative sizes for fonts/padding
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // -- CONSTANT IDENTIFIERS --
    // Primary branding color used for text highlights and gradients
    const baseColor = Color(0xFF5244F3);

    return Scaffold(
      backgroundColor: Colors.black,
      // Use Stack to layer the background image behind the text and slider
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -- UI COMPONENT: BACKGROUND IMAGE --
          const Image(
            image: AssetImage('assets/images/Eye Sprite Page 1.png'),
            fit: BoxFit.contain,
            alignment: Alignment(0.0, -1),
          ),

          // -- UI COMPONENT: GRADIENT OVERLAY --
          // Darkens the bottom of the image to ensure text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 0.8, 1.0],
              ),
            ),
          ),

          // -- UI COMPONENT: TITLE TEXT --
          // Left-aligned and vertically adjusted overlay text
          Align(
            alignment: const Alignment(-1.0, 0.45),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Algorithm: Shader Mask for Gradient Text
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        baseColor,
                        Color.lerp(baseColor, Colors.white, 0.4)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Text(
                      'A-EYE:',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        // Responsive font size based on screen width
                        fontSize: screenWidth * 0.18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // RichText allows mixing different styles/colors in one line
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: GoogleFonts.urbanist(
                        // Responsive font size
                        fontSize: screenWidth * 0.15,
                      ),
                      children: const [
                        TextSpan(
                          text: 'cataract ',
                          style: TextStyle(color: baseColor),
                        ),
                        TextSpan(
                          text: 'maturity ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'classification',
                          style: TextStyle(color: baseColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -- UI COMPONENT: INTERACTIVE SLIDER --
          // Positioned absolutely at the bottom of the screen
          Positioned(
            left: screenWidth * 0.05,
            right: screenWidth * 0.1,
            bottom: screenHeight * 0.06,
            child: GradientSlideToAct(
              height: screenHeight * 0.065,
              text: 'Swipe right to start',
              textStyle: GoogleFonts.urbanist(
                fontSize: screenWidth * 0.05,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
              backgroundColor: const Color(0xff080D2B),
              // -- CONTROL: EVENT HANDLER --
              // Triggers the navigation callback when slide completes
              onSubmit: onNext,

              dragableIconBackgroundColor: Colors.white,
              dragableIcon: Icons.double_arrow,

              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff484EC6),
                    Color(0xff5244F3),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}