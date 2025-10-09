import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
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

      return decodedBody;

    } catch (e) {
      print('[ApiService] Validate Error: $e');
      return {'isValid': false, 'reason': 'Connection or parsing error: $e'};
    }
  }

  /// STEP 2: Analyzes the image and gets the detailed explanation.
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

      // Log the raw response for debugging
      print('[ApiService] Response Status: ${response.statusCode}');
      print('[ApiService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Log the decoded response
        print('[ApiService] Decoded Response: $decoded');

        // FIXED: Safe extraction with null checks and proper type handling
        return {
          'classification': decoded['classification'] ?? 'Unknown',
          'confidence': _toDouble(decoded['confidence']) ?? 0.0,
          'classificationScore': _toDouble(decoded['classificationScore']) ?? 0.0,
          'explanation': decoded['explanation'] ?? 'No explanation available',
          'explained_image_base64': decoded['explained_image_base64'] ?? '',
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

  /// Helper method to safely convert any value to double
  double? _toDouble(dynamic value) {
    if (value == null) {
      print('[ApiService] Warning: Received null value for numeric field');
      return null;
    }

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        print('[ApiService] Warning: Could not parse string "$value" to double');
      }
      return parsed;
    }

    print('[ApiService] Warning: Unknown type ${value.runtimeType} for value: $value');
    return null;
  }
}