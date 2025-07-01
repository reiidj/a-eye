class AppRoutes {
  // Onboarding routes
  static const String landing = '/';
  static const String nameInput = '/name';
  static const String genderSelect = '/gender';
  static const String ageSelect = '/age';

  // Welcome routes
  static const String welcome = '/welcome';
  static const String welcomeWithResult = '/welcomeWithResult';

  // Scan setup routes
  static const String scanMode = '/scanMode';
  static const String checkSurroundings1 = '/check1';
  static const String checkSurroundings2 = '/check2';
  static const String disclaimer = '/disclaimer';

  // Camera and processing routes
  static const String camera = '/camera';
  static const String processImage = '/processImage';
  static const String cropImage = '/crop';
  static const String invalidImage = '/invalid';

  // Analysis routes
  static const String analyzing = '/analyzing';
  static const String analysisComplete = '/complete';
  static const String resultMature = '/mature';
  static const String resultImmature = '/immature';

  // Upload routes
  static const String uploadSelect = '/uploadSelect';
  static const String uploadCrop = '/uploadCrop';
  static const String uploadInvalid = '/uploadInvalid';

  // Utility method to get all routes
  static List<String> get allRoutes => [
    landing,
    nameInput,
    genderSelect,
    ageSelect,
    welcome,
    welcomeWithResult,
    scanMode,
    checkSurroundings1,
    checkSurroundings2,
    disclaimer,
    camera,
    processImage,
    cropImage,
    invalidImage,
    analyzing,
    analysisComplete,
    resultMature,
    resultImmature,
    uploadSelect,
    uploadCrop,
    uploadInvalid,
  ];
}