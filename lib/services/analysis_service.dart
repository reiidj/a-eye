import 'dart:math';
import 'dart:typed_data';
import 'package:a_eye/database/app_database.dart';
import 'package:a_eye/services/pytorch_service.dart';
import 'package:image/image.dart' as img;
import 'package:drift/drift.dart';

// Back to the simple result class
class AnalysisResult {
  final double probability;
  final String classification;

  AnalysisResult({required this.probability, required this.classification});
}

class AnalysisService {
  /// Takes image bytes, runs the model, SAVES the result, and returns it.
  static Future<AnalysisResult> analyzeImage({
    required Uint8List imageBytes,
    required String imagePath,
    required User? currentUser,
    required AppDatabase database,
  }) async {
    try {
      // 1. Preprocess the image to match the model's training data
      final List<double> imagePixels = preprocessImage(imageBytes);
      final List<int> shape = [1, 3, 256, 256];

      // 2. Run the model with the preprocessed image data
      final double logit = await PyTorchService.runModel(imagePixels, shape);

      // 3. Convert the model's raw output to a probability and classification
      final double probability = 1 / (1 + exp(-logit));

      // ✅ FIXED: Keep classification consistent - use the same format everywhere
      final String classification = probability >= 0.5 ? 'Mature' : 'Immature';

      // 4. Save the result to the database
      if (currentUser != null) {
        final newScan = ScansCompanion(
          userId: Value(currentUser.id),
          timestamp: Value(DateTime.now()),
          imagePath: Value(imagePath),
          result: Value(classification),
          confidence: Value(probability),
        );
        await database.insertScan(newScan);
        print("Success: Scan result saved to the database.");

        // ✅ DEBUG: Print what's being saved
        print("DEBUG - Saved classification: '$classification'");
        print("DEBUG - Saved probability: $probability");
      } else {
        print("Warning: No current user found. Scan result was not saved.");
      }

      return AnalysisResult(
        probability: probability,
        classification: classification,
      );
    } catch (e) {
      print("Error during analysis: $e");
      throw Exception('Failed to analyze image.');
    }
  }

  /// This is the MOST IMPORTANT function for model accuracy.
  /// It prepares the image exactly as the model expects.
  static List<double> preprocessImage(Uint8List bytes) {
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Unable to decode image");

    // Resize the image to 256x256 pixels
    final img.Image resized = img.copyResize(image, width: 256, height: 256);
    final List<double> pixels = [];

    // Normalize pixel values and flatten the list
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        // Normalize each color channel to be between 0.0 and 1.0
        pixels.add(pixel.b / 255.0);
        pixels.add(pixel.g / 255.0);
        pixels.add(pixel.r / 255.0);
      }
    }
    return pixels;
  }
}