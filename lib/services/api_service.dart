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

      if (response.statusCode == 200) {
        return json.decode(response.body); // e.g., {"isValid": true, "reason": "..."}
      } else {
        return json.decode(response.body); // e.g., {"isValid": false, "reason": "..."}
      }
    } catch (e) {
      return {'isValid': false, 'reason': 'Connection error: $e'};
    }
  }

  /// STEP 2: Classifies the image and gets the visual explanation.
  /// Call this ONLY after `validateImage` returns `isValid: true`.
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
        return json.decode(response.body);
      } else {
        // Try to return a specific error from the server
        final errorBody = json.decode(response.body);
        return {'error': errorBody['error'] ?? 'Analysis failed.'};
      }
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }
}