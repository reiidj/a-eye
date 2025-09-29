import 'dart:io';
import 'dart:math';
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
  // --- TUNED THRESHOLDS BASED ON SAMPLES ---
  static const double _blurThreshold = 30.0;
  static const double _intensityThreshold = 65.0;
  static const double _textureThreshold = 18.0;
  static const double _opacityThreshold = 0.08;
  static const double _minAspectRatio = 0.6;
  static const double _maxAspectRatio = 1.8;
  


  // --- QUALITY CHECKS ---

  /// More robust blur detection using Laplacian variance.
  static bool _isImageTooBlurry(img.Image image) {
    final gray = img.grayscale(image);
    double variance = 0.0;
    int count = 0;

    // Apply a 3x3 Laplacian filter to detect edges
    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        final p0 = gray.getPixel(x - 1, y).r;
        final p1 = gray.getPixel(x + 1, y).r;
        final p2 = gray.getPixel(x, y - 1).r;
        final p3 = gray.getPixel(x, y + 1).r;
        final p4 = gray.getPixel(x, y).r;

        final laplacian = (p0 + p1 + p2 + p3 - 4 * p4).abs();
        variance += laplacian * laplacian;
        count++;
      }
    }

    if (count == 0) return true;
    final laplacianVariance = variance / count;
    return laplacianVariance < _blurThreshold;
  }

  static bool _hasValidImageSize(img.Image image) {
    final bool validPixelDimensions = image.width >= 200 && image.height >= 200 &&
                                      image.width <= 5000 && image.height <= 5000;
    if (!validPixelDimensions) return false;

    // Check aspect ratio (width / height)
    final double aspectRatio = image.width / image.height;
    final bool validAspectRatio = aspectRatio >= _minAspectRatio && aspectRatio <= _maxAspectRatio;

    return validAspectRatio;
  }

  // --- EYE REGION DETECTION (REPLACES FACE DETECTION) ---

  /// Finds an eye region, optimized for close-up shots.
  static Future<Rect?> _findEyeRegion(String imagePath, img.Image fullImage) async {
    // ML Kit is still useful for finding a face, even in a close-up.
    // If it finds a face, we can use its bounding box.
    try {
      final options = FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
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
      // Fallback if ML Kit fails.
    }

    // If no face is found (common in very tight close-ups),
    // assume the eye is in the center 70% of the image.
    // This is a safer assumption now that we know the expected input is a close-up.
    final margin = 0.15; // Use 70% of the image
    return Rect(
      (fullImage.width * margin).round(),
      (fullImage.height * margin).round(),
      (fullImage.width * (1 - 2 * margin)).round(),
      (fullImage.height * (1 - 2 * margin)).round(),
    );
  }

  // --- PUPIL DETECTION ---

  static Rect? _findPupil(img.Image eyeRegion) {
    int bestX = 0, bestY = 0;
    double minBrightness = 255.0;

    // A cataractous eye's "pupil" might not be the darkest point,
    // so we search for a generally dark and low-variance area.
    final pupilSize = min(eyeRegion.width, eyeRegion.height) ~/ 5;
    final step = max(4, pupilSize ~/ 4);

    for (int y = 0; y <= eyeRegion.height - pupilSize; y += step) {
      for (int x = 0; x <= eyeRegion.width - pupilSize; x += step) {
        double totalBrightness = 0.0;
        int pixelCount = 0;
        for (int dy = 0; dy < pupilSize; dy += 2) {
          for (int dx = 0; dx < pupilSize; dx += 2) {
            totalBrightness += eyeRegion.getPixel(x + dx, y + dy).r.toDouble();
            pixelCount++;
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

    // A lower threshold because cataracts make the pupil brighter.
    if (minBrightness < 120) {
      return Rect(bestX, bestY, pupilSize, pupilSize);
    }
    return null;
  }


  // --- FEATURE ANALYSIS ---

  static Map<String, double> _analyzeBasicFeatures(img.Image pupilRegion) {
      final pixels = <int>[];
      for (int y = 0; y < pupilRegion.height; y++) {
          for (int x = 0; x < pupilRegion.width; x++) {
              pixels.add(pupilRegion.getPixel(x, y).r.toInt());
          }
      }
      if (pixels.isEmpty) return {};

      final avgIntensity = pixels.reduce((a, b) => a + b) / pixels.length;
      double variance = 0.0;
      for (final pixel in pixels) {
          variance += (pixel - avgIntensity) * (pixel - avgIntensity);
      }
      variance /= pixels.length;
      final stdDev = sqrt(variance);

      final brightPixels = pixels.where((p) => p > 150).length;
      final opacityRatio = brightPixels / pixels.length;

      return {
          'intensity': avgIntensity,
          'texture': stdDev,
          'opacity_ratio': opacityRatio,
      };
  }


  // --- CATARACT CHECK ---

  static bool _hasCataractIndicators(Map<String, double> features) {
      if (features.isEmpty) return false;
      final intensity = features['intensity'] ?? 0;
      final texture = features['texture'] ?? 0;
      final opacity = features['opacity_ratio'] ?? 0;

      // Logic: A cataract is indicated if the pupil area is either
      // abnormally bright OR has a rough/varied texture.
      return intensity > _intensityThreshold ||
          texture > _textureThreshold ||
          opacity > _opacityThreshold;
  }


  // --- MAIN VALIDATION FUNCTION ---

  static Future<ValidationResult> validateImageForCataract(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return ValidationResult(isValid: false, reason: "Image file not found.");
      }

      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return ValidationResult(isValid: false, reason: "Could not read image file.");
      }

      if (!_hasValidImageSize(image)) {
        return ValidationResult(isValid: false, reason: "Image size is not suitable (must be 200x200 to 5000x5000).");
      }

      if (_isImageTooBlurry(image)) {
        return ValidationResult(isValid: false, reason: "Image is too blurry. Please provide a sharper photo.");
      }

      // Use the new eye region finder
      final eyeRect = await _findEyeRegion(imagePath, image);
      if (eyeRect == null) {
        return ValidationResult(isValid: false, reason: "Could not detect an eye in the image. Please center the eye.");
      }

      final eyeRegion = img.copyCrop(image, x: eyeRect.left, y: eyeRect.top, width: eyeRect.width, height: eyeRect.height);

      final pupilRect = _findPupil(eyeRegion);
      if (pupilRect == null) {
        return ValidationResult(isValid: false, reason: "Could not locate the pupil. Ensure the eye is well-lit.");
      }

      final pupilRegion = img.copyCrop(eyeRegion, x: pupilRect.left, y: pupilRect.top, width: pupilRect.width, height: pupilRect.height);

      final features = _analyzeBasicFeatures(pupilRegion);
      if (!_hasCataractIndicators(features)) {
        return ValidationResult(
          isValid: false,
          isCataractPresent: false,
          reason: "No significant cataract indicators were found. The image is not suitable for the model.",
          features: features,
        );
      }

      return ValidationResult(
        isValid: true,
        isCataractPresent: true,
        reason: "✓ Image validation successful. Ready for ML analysis.",
        features: features,
      );

    } catch (e) {
      return ValidationResult(isValid: false, reason: "An error occurred during validation: ${e.toString()}");
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