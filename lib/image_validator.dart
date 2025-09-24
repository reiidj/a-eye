import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// Lightweight result class
class ValidationResult {
  final bool isValid;
  final bool isCataractPresent;
  final String reason;
  final double confidence;
  final Map<String, double> features;

  ValidationResult({
    required this.isValid,
    this.isCataractPresent = false,
    required this.reason,
    this.confidence = 0.0,
    this.features = const {},
  });
}

// Simple rectangle class
class Rect {
  final int left, top, width, height;
  Rect(this.left, this.top, this.width, this.height);
}

class ImageValidator {
  // Simple thresholds
  static const double _blurThreshold = 50.0;
  static const double _intensityThreshold = 70.0;
  static const double _textureThreshold = 15.0;

  // --- BASIC QUALITY CHECKS ---

  static bool _isImageTooBlurry(img.Image image) {
    // Simple blur detection - sample only center region
    final centerX = image.width ~/ 2;
    final centerY = image.height ~/ 2;
    final sampleSize = min(50, min(image.width, image.height) ~/ 4);

    double variance = 0.0;
    int count = 0;
    List<int> pixels = [];

    // Sample small region in center
    for (int y = centerY - sampleSize ~/ 2; y < centerY + sampleSize ~/ 2; y += 2) {
      for (int x = centerX - sampleSize ~/ 2; x < centerX + sampleSize ~/ 2; x += 2) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          pixels.add(image.getPixel(x, y).r.toInt());
          count++;
        }
      }
    }

    if (pixels.length < 10) return true;

    final mean = pixels.reduce((a, b) => a + b) / pixels.length;
    for (final pixel in pixels) {
      variance += (pixel - mean) * (pixel - mean);
    }
    variance /= pixels.length;

    return variance < _blurThreshold;
  }

  static bool _hasValidImageSize(img.Image image) {
    return image.width >= 100 && image.height >= 100 &&
        image.width <= 4000 && image.height <= 4000;
  }

  // --- SIMPLE FACE/EYE DETECTION ---

  static Future<Rect?> _findFaceOrEye(String imagePath) async {
    // Try ML Kit first (lightweight)
    try {
      final options = FaceDetectorOptions(
        enableLandmarks: false,
        enableContours: false,
        enableClassification: false,
        enableTracking: false,
      );
      final faceDetector = FaceDetector(options: options);
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await faceDetector.processImage(inputImage);
      faceDetector.close();

      if (faces.isNotEmpty) {
        final face = faces.first;
        return Rect(
          face.boundingBox.left.toInt(),
          face.boundingBox.top.toInt(),
          face.boundingBox.width.toInt(),
          face.boundingBox.height.toInt(),
        );
      }
    } catch (e) {
      // ML Kit failed, continue to fallback
    }

    // Simple fallback - assume close-up eye (center region)
    final imageBytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // Return center 60% of image as potential eye region
    final margin = 0.2;
    final left = (image.width * margin).round();
    final top = (image.height * margin).round();
    final width = (image.width * (1 - 2 * margin)).round();
    final height = (image.height * (1 - 2 * margin)).round();

    return Rect(left, top, width, height);
  }

  // --- SIMPLE PUPIL DETECTION ---

  static Rect? _findPupil(img.Image eyeRegion) {
    // Very simple pupil detection - find darkest square region
    int bestX = 0, bestY = 0;
    double minBrightness = 255.0;

    final pupilSize = min(eyeRegion.width, eyeRegion.height) ~/ 6;
    final step = max(5, pupilSize ~/ 4);

    for (int y = 0; y <= eyeRegion.height - pupilSize; y += step) {
      for (int x = 0; x <= eyeRegion.width - pupilSize; x += step) {
        double totalBrightness = 0.0;
        int pixelCount = 0;

        // Sample every 3rd pixel to reduce processing
        for (int dy = 0; dy < pupilSize; dy += 3) {
          for (int dx = 0; dx < pupilSize; dx += 3) {
            if (x + dx < eyeRegion.width && y + dy < eyeRegion.height) {
              totalBrightness += eyeRegion.getPixel(x + dx, y + dy).r.toDouble();
              pixelCount++;
            }
          }
        }

        if (pixelCount > 0) {
          final avgBrightness = totalBrightness / pixelCount;
          if (avgBrightness < minBrightness) {
            minBrightness = avgBrightness;
            bestX = x;
            bestY = y;
          }
        }
      }
    }

    // Only accept if reasonably dark
    if (minBrightness < 100) {
      return Rect(bestX, bestY, pupilSize, pupilSize);
    }

    return null;
  }

  // --- SIMPLE FEATURE ANALYSIS ---

  static Map<String, double> _analyzeBasicFeatures(img.Image pupilRegion) {
    final pixels = <int>[];

    // Sample every 2nd pixel to reduce processing
    for (int y = 0; y < pupilRegion.height; y += 2) {
      for (int x = 0; x < pupilRegion.width; x += 2) {
        pixels.add(pupilRegion.getPixel(x, y).r.toInt());
      }
    }

    if (pixels.isEmpty) return {};

    // Basic statistics
    final avgIntensity = pixels.reduce((a, b) => a + b) / pixels.length;

    double variance = 0.0;
    for (final pixel in pixels) {
      variance += (pixel - avgIntensity) * (pixel - avgIntensity);
    }
    variance /= pixels.length;
    final stdDev = sqrt(variance);

    // Simple opacity check
    final brightPixels = pixels.where((p) => p > 180).length;
    final opacityRatio = brightPixels / pixels.length;

    return {
      'intensity': avgIntensity,
      'texture': stdDev,
      'opacity_ratio': opacityRatio,
    };
  }

  // --- SIMPLE CATARACT CHECK ---

  static bool _hasCataractIndicators(Map<String, double> features) {
    if (features.isEmpty) return false;

    final intensity = features['intensity'] ?? 0;
    final texture = features['texture'] ?? 0;
    final opacity = features['opacity_ratio'] ?? 0;

    // Simple threshold checks
    return intensity > _intensityThreshold ||
        texture > _textureThreshold ||
        opacity > 0.1;
  }

  // --- MAIN VALIDATION FUNCTION ---

  static Future<ValidationResult> validateImageForCataract(String imagePath) async {
    try {
      // 1. Check file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        return ValidationResult(
          isValid: false,
          reason: "Image file not found.",
        );
      }

      // 2. Try to decode image
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return ValidationResult(
          isValid: false,
          reason: "Could not read image file. Please check the image format.",
        );
      }

      // 3. Check image size
      if (!_hasValidImageSize(image)) {
        return ValidationResult(
          isValid: false,
          reason: "Image size is not suitable. Please use an image between 100x100 and 4000x4000 pixels.",
        );
      }

      // 4. Check if too blurry
      if (_isImageTooBlurry(image)) {
        return ValidationResult(
          isValid: false,
          reason: "Image is too blurry. Please take a clearer photo.",
        );
      }

      // 5. Find face or eye region
      final eyeRect = await _findFaceOrEye(imagePath);
      if (eyeRect == null) {
        return ValidationResult(
          isValid: false,
          reason: "Could not detect an eye in the image. Please ensure the eye is clearly visible or not too close.",
        );
      }

      // 6. Extract eye region
      final eyeRegion = img.copyCrop(
        image,
        x: eyeRect.left,
        y: eyeRect.top,
        width: eyeRect.width,
        height: eyeRect.height,
      );

      // 7. Find pupil
      final pupilRect = _findPupil(eyeRegion);
      if (pupilRect == null) {
        return ValidationResult(
          isValid: false,
          reason: "Could not locate the pupil. Please ensure the eye is well-lit and clearly visible.",
        );
      }

      // 8. Extract pupil region
      final pupilRegion = img.copyCrop(
        eyeRegion,
        x: pupilRect.left,
        y: pupilRect.top,
        width: pupilRect.width,
        height: pupilRect.height,
      );

      // 9. Analyze basic features
      final features = _analyzeBasicFeatures(pupilRegion);

      // 10. Check for cataract indicators
      final hasCataract = _hasCataractIndicators(features);

      if (!hasCataract) {
        return ValidationResult(
          isValid: false,
          isCataractPresent: false,
          reason: "The ML model requires eyes with cataract indicators.",
          features: features,
        );
      }

      // Success - image is suitable for ML model
      return ValidationResult(
        isValid: true,
        isCataractPresent: true,
        reason: "✓ Image validation successful. Cataract features detected and ready for ML analysis.",
        confidence: 0.8,
        features: features,
      );

    } catch (e) {
      return ValidationResult(
        isValid: false,
        reason: "An error occurred during validation: ${e.toString()}",
      );
    }
  }

  // --- UTILITY FUNCTIONS ---

  static Future<bool> quickImageCheck(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return false;

      final imageBytes = await file.readAsBytes();
      if (imageBytes.length > 10 * 1024 * 1024) return false; // >10MB

      final image = img.decodeImage(imageBytes);
      return image != null && _hasValidImageSize(image);
    } catch (e) {
      return false;
    }
  }

  // --- ALTERNATIVE METHOD NAME FOR ML MODEL ---

  static Future<ValidationResult> validateImageForMLModel(String imagePath) async {
    return validateImageForCataract(imagePath);
  }
}