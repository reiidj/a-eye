import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  // UPDATED: Using the new base URL you provided
  static const String _baseUrl = "https://reiidj-a-eye-cataract-detection.hf.space";

  /// STEP 1: Validates an image before sending it for full analysis.
  Future<Map<String, dynamic>> validateImage(String filePath) async {
    try {
      final uri = Uri.parse("$_baseUrl/validate-image/");
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType.parse(lookupMimeType(filePath) ?? 'application/octet-stream'),
      ));

      final response = await http.Response.fromStream(await request.send());
      final decodedBody = json.decode(response.body);

      // The server response for validation should always be valid JSON
      return decodedBody;

    } catch (e) {
      print('[ApiService] Validate Error: $e');
      return {'isValid': false, 'reason': 'Connection or parsing error: $e'};
    }
  }

  /// STEP 2: Analyzes the image and gets the detailed explanation.
  /// Renamed from classifyAndExplainImage for consistency with analyzing_page.dart
  Future<Map<String, dynamic>> classifyAndExplainImage(String filePath) async {
    try {
      final uri = Uri.parse("$_baseUrl/analyze-and-explain/");
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType.parse(lookupMimeType(filePath) ?? 'application/octet-stream'),
      ));

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // --- KEY CHANGE HERE ---
        // Correctly parse the scores as doubles for the ResultsPage
        return {
          'classification': decoded['classification'],
          'confidence': (decoded['confidence'] as num).toDouble(),
          'classificationScore': (decoded['classificationScore'] as num).toDouble(),
          'explanation': decoded['explanation'],
          'explained_image_base64': decoded['explained_image_base64'],
        };
      } else {
        // If the server returns an error, extract the reason
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Analysis failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('[ApiService] Analyze Error: $e');
      // Re-throw the exception so the UI can handle it
      throw Exception('Failed to analyze image: $e');
    }
  }
}