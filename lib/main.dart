import 'package:flutter/material.dart';
import 'package:a_eye/database/app_database.dart';
import 'package:a_eye/routes/app_router.dart'; // this is my app router

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final database = AppDatabase();
    final users = await database.getAllUsers();

    final String initialRoute = users.isNotEmpty ? '/welcomeWithResult' : '/';
    final User? currentUser = users.isNotEmpty ? users.first : null;

    runApp(MyApp(
      database: database,
      initialRoute: initialRoute,
      currentUser: currentUser,
    ));
  } catch (e) {
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final String initialRoute;
  final User? currentUser;

  const MyApp({
    super.key,
    required this.database,
    required this.initialRoute,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A-Eye',
      navigatorKey: AppRouter.navigatorKey,
      theme: ThemeData(
        fontFamily: 'Urbanist',
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) => AppRouter.generateRoute(
        settings,
        database: database,
        currentUser: currentUser,
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                'Failed to initialize database',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Please restart the app',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}