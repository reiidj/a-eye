import 'dart:math';
import 'dart:typed_data';
import 'package:a_eye/database/app_database.dart';
import 'package:a_eye/services/pytorch_service.dart';
import 'package:image/image.dart' as img;
import 'package:drift/drift.dart';

class AnalysisResult {
  final double probability;
  final String classification;

  AnalysisResult({
    required this.probability,
    required this.classification,
  });
}

class AnalysisService {
  /// FIXED: Removed redundant validation since it's already done in SelectPage
  /// Focus on accurate preprocessing to match Python model
  static Future<AnalysisResult> analyzeImage({
    required Uint8List imageBytes,
    required String imagePath,
    required User? currentUser,
    required AppDatabase database,
  }) async {
    try {
      print("DEBUG: Starting analysis with image size: ${imageBytes.length} bytes");

      // 1. Enhanced preprocessing that matches Python training exactly
      final List<double> imagePixels = preprocessImageEnhanced(imageBytes);
      final List<int> shape = [1, 3, 256, 256]; // NCHW format

      print("DEBUG: Preprocessed ${imagePixels.length} pixels for model input");

      // 2. Run the model with properly preprocessed data
      final double logit = await PyTorchService.runModel(imagePixels, shape);
      print("DEBUG: Model returned logit: $logit");

      // 3. Convert logit to probability (sigmoid function)
      final double probability = 1 / (1 + exp(-logit));
      print("DEBUG: Converted to probability: $probability");

      // 4. Apply same threshold as Python code (0.5)
      final String classification = probability >= 0.5 ? 'Mature' : 'Immature';
      print("DEBUG: Final classification: '$classification'");

      // 5. Save to database
      if (currentUser != null) {
        final newScan = ScansCompanion(
          userId: Value(currentUser.id),
          timestamp: Value(DateTime.now()),
          imagePath: Value(imagePath),
          result: Value(classification),
          confidence: Value(probability),
        );
        await database.insertScan(newScan);
        print("SUCCESS: Scan saved - Classification: '$classification', Confidence: ${(probability * 100).toStringAsFixed(1)}%");
      }

      return AnalysisResult(
        probability: probability,
        classification: classification,
      );

    } catch (e) {
      print("ERROR in analysis pipeline: $e");
      throw Exception('Analysis failed: $e');
    }
  }

  /// CRITICAL: Preprocessing that matches your Python Colab exactly
  static List<double> preprocessImageEnhanced(Uint8List bytes) {
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception("Cannot decode image");

    print("DEBUG: Original image size: ${image.width}x${image.height}");

    // Step 1: Resize to exact model input size (256x256)
    final img.Image resized = img.copyResize(
        image,
        width: 256,
        height: 256,
        interpolation: img.Interpolation.linear
    );

    print("DEBUG: Resized to: ${resized.width}x${resized.height}");

    // Step 2: Apply the EXACT normalization from your Python get_transforms()
    // Check your Python code - these might need adjustment based on your training
    final List<double> imagenetMean = [0.485, 0.456, 0.406]; // RGB order
    final List<double> imagenetStd = [0.229, 0.224, 0.225];   // RGB order

    final List<double> pixels = [];

    // Step 3: Process in CHW format (Channels, Height, Width) - PyTorch standard
    // This matches the tensor format your model expects

    // RED channel first
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        final double normalized = (pixel.r / 255.0 - imagenetMean[0]) / imagenetStd[0];
        pixels.add(normalized);
      }
    }

    // GREEN channel
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        final double normalized = (pixel.g / 255.0 - imagenetMean[1]) / imagenetStd[1];
        pixels.add(normalized);
      }
    }

    // BLUE channel
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        final double normalized = (pixel.b / 255.0 - imagenetMean[2]) / imagenetStd[2];
        pixels.add(normalized);
      }
    }

    // Validation
    if (pixels.length != 3 * 256 * 256) {
      throw Exception("Wrong tensor size: ${pixels.length}, expected: ${3 * 256 * 256}");
    }

    final double minVal = pixels.reduce(min);
    final double maxVal = pixels.reduce(max);
    print("DEBUG: Pixel range: $minVal to $maxVal (ImageNet norm should be ~-2.5 to 2.5)");

    return pixels;
  }
}