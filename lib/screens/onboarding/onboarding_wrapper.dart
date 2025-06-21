import 'package:flutter/material.dart';
import 'package:a_eye/screens/onboarding/landing_page.dart';
import 'package:a_eye/screens/onboarding/name_input_page.dart';
import 'package:a_eye/screens/onboarding/gender_select_page.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _controller = PageController();

  void goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        LandingPage(onNext: () => goToPage(1)),
        NameInputPage(
          onNext: () => goToPage(2),
          onBack: () => goToPage(0),
        ),
        GenderSelectPage(
          onNext: () => goToPage(3),
          onBack: () => goToPage(1),
        ),
        // Add more pages here...
      ],
    );
  }
}
