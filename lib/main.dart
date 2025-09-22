import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'database/app_database.dart';

// Create a global instance of the database
late AppDatabase database;

void main() async{
  // Initialize the database
  database = AppDatabase();
  WidgetsFlutterBinding.ensureInitialized();

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