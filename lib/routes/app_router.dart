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
            initialName: currentUser?.name, // Pass existing name if available
          ),
        );

    // Gender Select Page
      case '/gender':
        final userName = settings.arguments as String;
        return _buildRoute(
          GenderSelectPage(
            database: database, // Add database parameter
            onNext: (gender) => AppRouter.navigateToAge(userName, gender, database),
            onBack: () => AppRouter.navigateBack(),
            initialGender: currentUser?.gender, // Pass existing gender if available
          ),
        );

    // Age Select Page
      case '/age':
        final args = settings.arguments as Map<String, dynamic>;
        final userName = args['name'] as String;
        final gender = args['gender'] as String;
        return _buildRoute(
          AgeSelectPage(
            database: database, // Add database parameter
            onNext: (ageGroup) => AppRouter.completeOnboarding(
              userName,
              gender,
              ageGroup,
              database,
            ),
            onBack: (ageGroup) => AppRouter.navigateBack(),
            initialAgeGroup: currentUser?.ageGroup, // Pass existing age group if available
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
            onNext: () => AppRouter.navigateTo('/analyzing'),
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
        return _buildRoute(
          AnalyzingPage(
            onComplete: () => AppRouter.navigateTo('/complete'),
          ),
        );

      case '/complete':
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['name'] ?? currentUser?.name ?? 'Guest';
        return _buildRoute(
          AnalyzedPage(
            onComplete: () => AppRouter.navigateToResult(userName),
          ),
        );

      case '/mature':
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['name'] ?? 'Guest';
        return _buildRoute(
          MaturePage(
            onNext: () => AppRouter.navigateToWelcomeWithResult(userName),
          ),
        );

      case '/immature':
        final args = settings.arguments as Map<String, dynamic>?;
        final userName = args?['name'] ?? 'Guest';
        return _buildRoute(
          ImmaturePage(
            onNext: () => AppRouter.navigateToWelcomeWithResult(userName),
          ),
        );

    // Upload Flow
      case '/uploadSelect':
        return _buildRoute(
          SelectPage(
            onNext: () => AppRouter.navigateRandomUpload(),
          ),
        );

      case '/uploadCrop':
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          UploadCropPage(
            imagePath: args['imagePath'],
            onNext: args['onNext'],
            onBack: args['onBack'],
          ),
        );

      case '/uploadInvalid':
        return _buildRoute(
          uploadInvalidPage(
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

  static void navigateToResult(String userName) {
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    if (random == 0) {
      navigatorKey.currentState?.pushNamed('/mature', arguments: {'name': userName});
    } else {
      navigatorKey.currentState?.pushNamed('/immature', arguments: {'name': userName});
    }
  }

  static void navigateToWelcomeWithResult(String userName) {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => WelcomeScreenWithResult(
          userName: userName,
          onNext: () => navigatorKey.currentState?.pushNamed('/scanMode'),
        ),
      ),
          (route) => false,
    );
  }

  static void navigateRandomUpload() {
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    if (random == 0) {
      navigatorKey.currentState?.pushNamed('/uploadInvalid');
    } else {
      navigatorKey.currentState?.pushNamed('/uploadCrop', arguments: {
        'imagePath': '', // You might need to pass actual image path
        'onNext': () => AppRouter.navigateTo('/analyzing'),
        'onBack': () => AppRouter.navigateBack(),
      });
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