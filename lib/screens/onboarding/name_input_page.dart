import 'package:flutter/material.dart';

class NameInputPage extends StatelessWidget {
  const NameInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Name Input Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
