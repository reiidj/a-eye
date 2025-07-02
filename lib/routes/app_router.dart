import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:a_eye/database/app_database.dart';

// Onboarding imports
import 'package:a_eye/screens/onboarding/landing_page.dart';
import 'package:a_eye/screens/onboarding/name_input_page.dart';
import 'package:a_eye/screens/onboarding/gender_select_page.dart';
import 'package:a_eye/screens/onboarding/age_select_page.dart';

// Welcome screens
import 'package:a_eye/screens/welcome_screen.dart';
import 'package:a_eye/screens/welcome_screen_with_result.dart';

// Scan setup
import 'package:a_eye/screens/scan_setup/scan_mode_page.dart';
import 'package:a_eye/screens/scan_setup/check_surroundings_1.dart';
import 'package:a_eye/screens/scan_setup/check_surroundings_2.dart';
import 'package:a_eye/screens/scan_setup/disclaimer_page.dart';

// Scan screens
import 'package:a_eye/screens/scan/capture/camera_page.dart';
import 'package:a_eye/screens/scan/analyzing_page.dart';
import 'package:a_eye/screens/scan/analysis_complete_page.dart';
import 'package:a_eye/screens/scan/result_immature_page.dart';
import 'package:a_eye/screens/scan/result_mature_page.dart';
import 'package:a_eye/screens/scan/capture/crop_image_page.dart';
import 'package:a_eye/screens/scan/capture/invalid_image_page.dart';

// Upload screens
import 'package:a_eye/screens/scan/upload/upload_crop_page.dart';
import 'package:a_eye/screens/scan/upload/upload_select_page.dart';
import 'package:a_eye/screens/scan/upload/upload_invalid_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings, {
        required AppDatabase database,
        User? currentUser,
      }) {
    switch (settings.name) {
    // Landing Page
      case '/':
        return _buildRoute(
          LandingPage(
            onNext: () => AppRouter.navigateToName(database),
          ),
        );

    // Name Input Page
      case '/name':
        return _buildRoute(
          NameInputPage(
            database: database,
            onNext: (name) => AppRouter.navigateToGender(name, database),
            onBack: () => AppRouter.navigateTo('/'),
            initialName: currentUser?.name,
          ),
        );

    // Gender Select Page
      case '/gender':
        final userName = settings.arguments as String;
        return _buildRoute(
          GenderSelectPage(
            database: database,
            onNext: (gender) => AppRouter.navigateToAge(userName, gender, database),
            onBack: () => AppRouter.navigateBack(),
            initialGender: currentUser?.gender,
          ),
        );

    // Age Select Page
      case '/age':
        final args = settings.arguments as Map<String, dynamic>;
        final userName = args['name'] as String;
        final gender = args['gender'] as String;
        return _buildRoute(
          AgeSelectPage(
            database: database,
            onNext: (ageGroup) => AppRouter.completeOnboarding(
              userName,
              gender,
              ageGroup,
              database,
            ),
            onBack: (ageGroup) => AppRouter.navigateBack(),
            initialAgeGroup: currentUser?.ageGroup,
          ),
        );

    // Welcome Screen (new user)
      case '/welcome':
        final args = settings.arguments as Map<String, dynamic>;
        final user = args['user'] as User;
        return _buildRoute(
          WelcomeScreen(
            user: user,
            onNext: () => AppRouter.navigateTo('/scanMode'),
          ),
        );

    // Welcome Screen (returning user)
      case '/welcomeWithResult':
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['name'] ?? currentUser?.name ?? 'Guest';
        return _buildRoute(
          WelcomeScreenWithResult(
            database: database,
            userName: userName,
            onNext: () => AppRouter.navigateTo('/scanMode'),
          ),
        );

    // Scan Setup Flow
      case '/scanMode':
        return _buildRoute(
          ScanModePage(
            onUpload: () => AppRouter.navigateTo('/uploadSelect'),
            onCapture: () => AppRouter.navigateTo('/check1'),
          ),
        );

      case '/check1':
        return _buildRoute(
          CheckSurroundings1(
            onNext: () => AppRouter.navigateTo('/check2'),
          ),
        );

      case '/check2':
        return _buildRoute(
          CheckSurroundings2(
            onNext: () => AppRouter.navigateTo('/disclaimer'),
          ),
        );

      case '/disclaimer':
        return _buildRoute(
          DisclaimerPage(
            onNext: () => AppRouter.navigateTo('/camera'),
          ),
        );

    // Camera and Image Processing
      case '/camera':
        return _buildRoute(const CameraPage());

      case '/processImage':
        return _buildRoute(_buildImageProcessor(settings));

      case '/crop':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          CropPage(
            imagePath: args['imagePath'],
            onNext: () => AppRouter.navigateTo('/analyzing', {
              'database': database,
              'userId': currentUser?.id,
              'name': currentUser?.name ?? 'Guest',
              'imagePath': args['imagePath'],
            }),
            onBack: () => AppRouter.navigateBackToCamera(),
          ),
        );

      case '/invalid':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          InvalidPage(
            imagePath: args['imagePath'],
            onBack: () => AppRouter.navigateBackToCamera(),
          ),
        );

    // Analysis Flow
      case '/analyzing':
        final args = settings.arguments as Map<String, dynamic>?;
        final analyzeDatabase = args?['database'] ?? database;
        final userId = args?['userId'] ?? currentUser?.id;
        final userName = args?['name'] ?? currentUser?.name ?? 'Guest';
        final imagePath = args?['imagePath'];

        return _buildRoute(
          AnalyzingPage(
            onComplete: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (AppRouter.navigatorKey.currentState?.mounted ?? false) {
                  AppRouter.navigateTo('/complete', {
                    'database': analyzeDatabase,
                    'userId': userId,
                    'name': userName,
                    'imagePath': imagePath,
                  });
                }
              });
            },
          ),
        );

      case '/complete':
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['name'] ?? currentUser?.name ?? 'Guest';
        final completeDatabase = args?['database'] ?? database;
        final userId = args?['userId'] ?? currentUser?.id;
        final imagePath = args?['imagePath'];

        return _buildRoute(
          AnalyzedPage(
            onComplete: () => AppRouter.navigateToResult(userName, {
              'database': completeDatabase,
              'userId': userId,
              'imagePath': imagePath,
            }),
            database: completeDatabase,
            userId: userId,
          ),
        );

      case '/mature':
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['name'] ?? 'Guest';
        final matureDatabase = args?['database'] ?? database;
        final userId = args?['userId'];
        final imagePath = args?['imagePath'];

        return _buildRoute(
          MaturePage(
            onNext: () async {
              // Save scan result before navigating
              await _saveScanResult(matureDatabase, userId, imagePath, 'mature');
              AppRouter.navigateToWelcomeWithResult(userName);
            },
          ),
        );

      case '/immature':
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['name'] ?? 'Guest';
        final immatureDatabase = args?['database'] ?? database;
        final userId = args?['userId'];
        final imagePath = args?['imagePath'];

        return MaterialPageRoute(
          builder: (context) => ImmaturePage(
            onNext: () async {
              // Save scan result before navigating
              await _saveScanResult(immatureDatabase, userId, imagePath, 'immature');
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcomeWithResult',
                    (_) => false,
                arguments: {'name': userName},
              );
            },
            database: immatureDatabase,
            userId: userId,
          ),
        );

    // Upload Flow
      case '/uploadSelect':
        return _buildRoute(
          SelectPage(
            database: database,
            onNext: (imagePath) => AppRouter.navigateRandomUpload(imagePath),
          ),
        );

      case '/uploadCrop':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          UploadCropPage(
            database: database,
            imagePath: args['imagePath'],
            onNext: () => AppRouter.navigateTo('/analyzing', {
              'database': database,
              'userId': currentUser?.id,
              'name': currentUser?.name ?? 'Guest',
              'imagePath': args['imagePath'],
            }),
            onBack: args['onBack'] ?? () => AppRouter.navigateBack(),
          ),
        );

      case '/uploadInvalid':
        return _buildRoute(
          UploadInvalidPage(
            database: database,
            onBack: () => AppRouter.navigateBack(),
          ),
        );

      default:
        return _buildErrorRoute();
    }
  }

  // Static navigator key to access navigator from anywhere
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Helper methods for navigation using the global navigator key
  static void navigateToName(AppDatabase database) {
    navigatorKey.currentState?.pushReplacementNamed('/name');
  }

  static void navigateToGender(String name, AppDatabase database) {
    navigatorKey.currentState?.pushNamed('/gender', arguments: name);
  }

  static void navigateToAge(String name, String gender, AppDatabase database) {
    navigatorKey.currentState?.pushNamed('/age', arguments: {'name': name, 'gender': gender});
  }

  static Future<void> completeOnboarding(
      String name,
      String gender,
      String ageGroup,
      AppDatabase database,
      ) async {
    try {
      // Update existing user or create new one
      final users = await database.getAllUsers();

      if (users.isNotEmpty) {
        // Update existing user
        final existingUser = users.first;
        await database.updateUser(existingUser.copyWith(
          name: name,
          gender: gender,
          ageGroup: ageGroup,
        ));

        // Get updated user
        final updatedUsers = await database.getAllUsers();
        final user = updatedUsers.first;

        navigatorKey.currentState?.pushNamed('/welcome', arguments: {'user': user});
      } else {
        // Create new user (this shouldn't happen in normal flow since name input creates user)
        await database.insertUser(UsersCompanion(
          name: Value(name),
          gender: Value(gender),
          ageGroup: Value(ageGroup),
        ));

        // Get the saved user
        final newUsers = await database.getAllUsers();
        final user = newUsers.firstWhere((u) => u.name == name);

        navigatorKey.currentState?.pushNamed('/welcome', arguments: {'user': user});
      }
    } catch (e) {
      // Handle error - maybe show a snackbar or error dialog
      debugPrint('Error saving user data: $e');
    }
  }

  static void navigateTo(String route, [Object? arguments]) {
    navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  static void navigateBack() {
    navigatorKey.currentState?.pop();
  }

  static void navigateBackToCamera() {
    navigatorKey.currentState?.popUntil(ModalRoute.withName('/camera'));
  }

  static void navigateToResult(String userName, [Map<String, dynamic>? additionalArgs]) {
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    final args = {
      'name': userName,
      ...?additionalArgs,
    };

    if (random == 0) {
      navigatorKey.currentState?.pushNamed('/mature', arguments: args);
    } else {
      navigatorKey.currentState?.pushNamed('/immature', arguments: args);
    }
  }

  static void navigateToWelcomeWithResult(String userName) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/welcomeWithResult',
          (route) => false,
      arguments: {
        'name': userName,
      },
    );
  }

  static void navigateRandomUpload(String imagePath) {
    final random = DateTime.now().millisecondsSinceEpoch % 2;

    if (random == 0) {
      navigatorKey.currentState?.pushNamed('/uploadInvalid', arguments: {
        'imagePath': imagePath,
      });
    } else {
      navigatorKey.currentState?.pushNamed('/uploadCrop', arguments: {
        'imagePath': imagePath,
        'onNext': () => AppRouter.navigateTo('/analyzing'),
        'onBack': () => AppRouter.navigateBack(),
      });
    }
  }

  // Method to save scan results to database
  static Future<void> _saveScanResult(
      AppDatabase? database,
      int? userId,
      String? imagePath,
      String result
      ) async {
    if (database != null && userId != null && imagePath != null) {
      try {
        await database.insertScan(ScanResultsCompanion(
          userId: Value(userId),
          imagePath: Value(imagePath),
          result: Value(result),
          timestamp: Value(DateTime.now()),
        ));
        debugPrint('Scan result saved: $result for user $userId');
      } catch (e) {
        debugPrint('Error saving scan result: $e');
      }
    } else {
      debugPrint('Cannot save scan result: missing database ($database), userId ($userId), or imagePath ($imagePath)');
    }
  }

  // Helper methods for building routes
  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }

  static Widget _buildImageProcessor(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final String imagePath = args?['imagePath'] ?? '';
    final String selectedEye = args?['selectedEye'] ?? 'Left';

    // Return a widget that handles the navigation logic
    return ImageProcessorWidget(
      imagePath: imagePath,
      selectedEye: selectedEye,
    );
  }

  static MaterialPageRoute _buildErrorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            '404 - Page not found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

// Widget to handle image processing navigation
class ImageProcessorWidget extends StatefulWidget {
  final String imagePath;
  final String selectedEye;

  const ImageProcessorWidget({
    Key? key,
    required this.imagePath,
    required this.selectedEye,
  }) : super(key: key);

  @override
  State<ImageProcessorWidget> createState() => _ImageProcessorWidgetState();
}

class _ImageProcessorWidgetState extends State<ImageProcessorWidget> {
  @override
  void initState() {
    super.initState();
    _processImage();
  }

  void _processImage() {
    // Random logic for image processing
    final random = DateTime.now().millisecondsSinceEpoch % 2;

    // Navigate after the widget is built using AppRouter methods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (random == 0) {
          AppRouter.navigatorKey.currentState?.pushReplacementNamed(
            '/crop',
            arguments: {
              'imagePath': widget.imagePath,
              'selectedEye': widget.selectedEye
            },
          );
        } else {
          AppRouter.navigatorKey.currentState?.pushReplacementNamed(
            '/invalid',
            arguments: {
              'imagePath': widget.imagePath,
              'selectedEye': widget.selectedEye
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return loading screen
    return const Scaffold(
      backgroundColor: Color(0xFF131A21),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF5244F3)),
      ),
    );
  }
}