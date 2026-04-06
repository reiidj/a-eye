/*
 * Program Title: api_service.dart
 *
 * Programmers:
 *   Albonia, Jade Lorenz
 *   Villegas, Jedidiah
 *   Velante, Kamilah Kaye
 *   Rivera, Rei Djemf M.
 *
 * Where the program fits in the general system design:
 *   This module is located in `lib/services/` and acts as the networking bridge
 *   between the Flutter Client (Frontend) and the Python FastAPI Server (Backend)
 *   hosted on Hugging Face Spaces. It abstracts all HTTP complexity, handling
 *   multipart file uploads, content-type negotiation, and the parsing of JSON
 *   responses into strongly-typed Dart objects for the UI to consume.
 *
 * Date Written: October 2025
 * Date Revised: November 2025
 *
 * Purpose:
 *   To provide a centralized, robust interface for all network operations,
 *   ensuring images are correctly encoded for transmission and server responses
 *   are safely validated before being passed to the application layer.
 *
 * Data Structures, Algorithms, and Control:
 *   Data Structures:
 *     * MultipartRequest: Specialized HTTP request type for uploading binary files.
 *     * Map<String, dynamic>: Generic structure for holding parsed JSON data.
 *
 *   Algorithms:
 *     * MIME Type Detection: Uses `lookupMimeType` to automatically determine
 *       if the file is JPEG/PNG/etc. before upload.
 *     * Type Safecasting (_toDouble): A polymorphic helper algorithm that ensures
 *       numeric values from the API (which might be int, double, or string) are
 *       correctly converted to Dart `doubles` to prevent runtime crashes.
 *
 *   Control:
 *     * Asynchronous I/O: All network calls use `Future`/`await` to prevent
 *       blocking the main UI thread.
 *     * Exception Handling: Try/Catch blocks wrap all network activities to
 *       handle timeouts, DNS errors, or server 500s gracefully.
 */


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

/// Class: ApiService
/// Purpose: Singleton-like service class containing all backend endpoint definitions.
class ApiService {
  // -- CONSTANT IDENTIFIERS --
  // The root URL for the hosted AI inference engine
  static const String _baseUrl = "https://reiidj-a-eye-cataract-detection.hf.space";

  /// STEP 1: Validates an image before sending it for full analysis.
  /// Returns: Map containing 'isValid' (bool) and 'reason' (String).
  Future<Map<String, dynamic>> validateImage(String filePath) async {
    try {
      // -- DATA STRUCTURE: URI --
      final uri = Uri.parse("$_baseUrl/validate-image/");

      // -- ALGORITHM: MULTIPART ENCODING --
      // Construct a request that mimics a standard HTML form file upload
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        // Content-Type header is critical for FastAPI to recognize the file
        contentType: MediaType.parse(lookupMimeType(filePath) ?? 'application/octet-stream'),
      ));

      // Send bytes and await stream response
      final response = await http.Response.fromStream(await request.send());

      // -- ALGORITHM: JSON DECODING --
      final decodedBody = json.decode(response.body);

      return decodedBody;

    } catch (e) {
      // -- CONTROL: ERROR HANDLING --
      print('[ApiService] Validate Error: $e');
      return {'isValid': false, 'reason': 'Connection or parsing error: $e'};
    }
  }

  /// STEP 2: Analyzes the image and gets the detailed explanation.
  /// Returns: Map containing classification, confidence, and visualization data.
  Future<Map<String, dynamic>> classifyAndExplainImage(String filePath) async {
    try {
      final uri = Uri.parse("$_baseUrl/analyze-and-explain/");
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType.parse(lookupMimeType(filePath) ?? 'application/octet-stream'),
      ));

      // Execute Network Request
      final response = await http.Response.fromStream(await request.send());

      // Log the raw response for debugging
      print('[ApiService] Response Status: ${response.statusCode}');
      print('[ApiService] Response Body: ${response.body}');

      // -- CONTROL: STATUS CHECK --
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Log the decoded response
        print('[ApiService] Decoded Response: $decoded');

        // Safe extraction with null checks and proper type handling
        // Using `_toDouble` ensures stability even if backend changes number formats
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
      // Re-throw the exception so the UI can handle it (e.g. Show Error Page)
      throw Exception('Failed to analyze image: $e');
    }
  }

  /// Helper method to safely convert any value to double.
  /// Algorithm: Polymorphic Type Checking to handle int, double, and String inputs.
  double? _toDouble(dynamic value) {
    if (value == null) {
      print('[ApiService] Warning: Received null value for numeric field');
      return null;
    }

    // Direct numeric types
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    // Parse strings (e.g. "0.98")
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