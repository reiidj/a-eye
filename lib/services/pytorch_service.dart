import 'package:flutter/services.dart';

class PyTorchService {
  static const _channel = MethodChannel('com.example.a_eye/pytorch');

  /// Runs the model. Expects a flattened float list and the shape [1,3,256,256]
  static Future<double> runModel(List<double> input, List<int> shape) async {
    try {
      final result = await _channel.invokeMethod('runInference', {
        'input': input,
        'shape': shape,
      });
      return (result as num).toDouble();
    } on PlatformException catch (e) {
      print("Error running model: ${e.message}");
      // Throw an exception so the UI can handle the error state
      throw Exception('Failed to run model inference: ${e.message}');
    }
  }
}