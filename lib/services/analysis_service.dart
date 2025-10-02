import 'dart:math';
import 'dart:typed_data';
import 'package:a_eye/database/app_database.dart';
import 'package:a_eye/services/pytorch_service.dart';
import 'package:image/image.dart' as img;
import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisResult {
  final double probability;
  final String classification;

  AnalysisResult({
    required this.probability,
    required this.classification,
  });
}

class AnalysisService {
  static Future<AnalysisResult> analyzeImage({
    required Uint8List imageBytes,
    required String imagePath,
    required User? currentUser,
    required AppDatabase database,
  }) async {
    try {
      // ... (preprocessing and model logic remains the same) ...
      final List<double> imagePixels = preprocessImageEnhanced(imageBytes);
      final List<int> shape = [1, 3, 256, 256];
      final double logit = await PyTorchService.runModel(imagePixels, shape);
      final double probability = 1 / (1 + exp(-logit));
      final String classification = probability >= 0.5 ? 'Mature' : 'Immature';
      
      final double estimatedOpacityExtent = Random().nextDouble();
      final double estimatedOpacityDensity = Random().nextDouble();

      if (currentUser != null) {
        // --- 1. Save to LOCAL database (Drift) ---
        final newScan = ScansCompanion(
          userId: Value(currentUser.id),
          timestamp: Value(DateTime.now()),
          imagePath: Value(imagePath),
          result: Value(classification),
          confidence: Value(probability),
          estimatedOpacityExtent: Value(estimatedOpacityExtent),
          estimatedOpacityDensity: Value(estimatedOpacityDensity),
        );
        await database.insertScan(newScan);
        print("SUCCESS: Scan saved to local DB.");

        // --- 2. Save to FIREBASE FIRESTORE ---

        // --- START: ADD THESE LINES FOR DEBUGGING ---
        final Map<String, dynamic> scanDataForFirebase = {
          'userId': currentUser.id,
          'timestamp': Timestamp.now(),
          'imagePath': imagePath,
          'result': classification,
          'confidence': probability,
          'estimatedOpacityExtent': estimatedOpacityExtent,
          'estimatedOpacityDensity': estimatedOpacityDensity,
        };

        print("DEBUG: Sending this data to Firestore: $scanDataForFirebase");
        // --- END: ADD THESE LINES FOR DEBUGGING ---

        await FirebaseFirestore.instance.collection('scans').add(scanDataForFirebase); // <-- Make sure this line uses the new map
        print("SUCCESS: Scan saved to Firebase Firestore.");
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

  // ... (preprocessImageEnhanced function remains the same) ...
  static List<double> preprocessImageEnhanced(Uint8List bytes) {
    // ... no changes here
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