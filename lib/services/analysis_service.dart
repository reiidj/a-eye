import 'dart:typed_data';
import 'package:a_eye/services/firestore_service.dart';
import 'package:a_eye/services/pytorch_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';

// A simple class to hold the analysis result
class AnalysisResult {
  final String classification;
  final double probability;

  AnalysisResult({required this.classification, required this.probability});
}

class AnalysisService {
  final FirestoreService _firestoreService = FirestoreService();

  // This is the main method that will be called from the UI
  Future<AnalysisResult> analyzeImageAndSave({
    required Uint8List imageBytes,
    String imagePath = '',
  }) async {
    // 1. Run the model to get the prediction
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    final resizedImage = img.copyResize(image, width: 256, height: 256);
    final normalizedList = resizedImage.getBytes(order: img.ChannelOrder.rgb).map((b) => b / 255.0).toList();
    final prediction = await PyTorchService.runModel(normalizedList, [1, 3, 256, 256]);

    // 2. Determine the classification
    final classification = prediction > 0.5 ? "Mature Cataract" : "Immature Cataract";

    // 3. Save the result to Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final scanData = {
        'result': classification,
        'confidence': prediction,
        'timestamp': Timestamp.now(),
        'imagePath': imagePath, // Note: In a real app, you would upload the image to Firebase Storage first
      };
      await _firestoreService.addScan(user.uid, scanData);
    } else {
      print("Warning: No user signed in. Scan result will not be saved.");
    }

    // 4. Return the result
    return AnalysisResult(classification: classification, probability: prediction);
  }
}