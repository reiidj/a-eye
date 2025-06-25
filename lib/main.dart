import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes.dart'; // Route definitions

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with Flutter support
  await Hive.initFlutter();

  // Open Hive boxes (add error handling if desired)
  await Future.wait([
    Hive.openBox('userBox'),
    Hive.openBox('scanResultsBox'),
  ]);

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
