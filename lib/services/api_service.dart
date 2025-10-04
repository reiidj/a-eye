import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://reiidj-a-eye-cataract-detection.hf.space";

  Future<Map<String, dynamic>> validateImage(Uint8List imageBytes) async {
    try {
      var uri = Uri.parse('$_baseUrl/validate-image/');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'validation_image.jpg',
      ));

      print('Sending request to: $uri');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'isValid': false,
          'reason': 'Server returned ${response.statusCode}: ${response.body}'
        };
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
      return {
        'isValid': false,
        'reason': 'Connection error: $e'
      };
    }
  }

  Future<Map<String, dynamic>> classifyImage(Uint8List imageBytes) async {
    try {
      var uri = Uri.parse('$_baseUrl/classify-image/');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'classification_image.jpg',
      ));

      print('Sending request to: $uri');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Classification failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}