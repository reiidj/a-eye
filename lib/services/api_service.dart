import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image/image.dart' as img;

class ApiService {
  static const String _baseUrl = "https://reiidj-a-eye-cataract-detection.hf.space";

  /// Helper that reads local file info (exists, size, dimensions, mime)
  Future<Map<String, dynamic>> _inspectFile(String filePath) async {
    final file = File(filePath);
    final exists = await file.exists();
    if (!exists) {
      return {'ok': false, 'reason': 'File does not exist'};
    }
    final length = await file.length();
    if (length == 0) {
      return {'ok': false, 'reason': 'File is empty'};
    }

    // detect mime
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

    // try to get dimensions safely using package:image
    int? width;
    int? height;
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        width = decoded.width;
        height = decoded.height;
      }
    } catch (_) {
      // decoding failed; leave width/height null
    }

    return {
      'ok': true,
      'file': file,
      'length': length,
      'mime': mimeType,
      'width': width,
      'height': height,
    };
  }

  /// Validate an image before classification
  Future<Map<String, dynamic>> validateImage(String filePath) async {
    try {
      // local inspection
      final info = await _inspectFile(filePath);
      if (info['ok'] != true) {
        return {'isValid': false, 'reason': info['reason'] ?? 'File error'};
      }

      // If dimensions exist, give quick client-side validation message (same limits as API docs)
      final width = info['width'] as int?;
      final height = info['height'] as int?;
      if (width != null && height != null) {
        // API said: must be 200x200 to 5000x5000 with valid aspect ratio
        if (width < 200 || height < 200 || width > 5000 || height > 5000) {
          return {
            'isValid': false,
            'reason': 'Image size is not suitable (must be 200x200 to 5000x5000).'
          };
        }
        // Optionally check aspect ratio rules if you know them; otherwise let server validate exact aspect
      }

      final uri = Uri.parse("$_baseUrl/validate-image/"); // trailing slash required
      print("[ValidateImage] Sending request to: $uri");
      print("[ValidateImage] File path: $filePath");
      print("[ValidateImage] File size (bytes): ${info['length']}");
      print("[ValidateImage] Detected MIME type: ${info['mime']}");
      print("[ValidateImage] Dimensions: ${info['width']} x ${info['height']}");

      final request = http.MultipartRequest('POST', uri);

      // Use filename from the path
      final filename = filePath.split(Platform.pathSeparator).last;

      // Add file. We set contentType to detected mime; this matches curl examples.
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: filename,
        contentType: MediaType.parse(info['mime'] as String),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("[ValidateImage] Status Code: ${response.statusCode}");
      print("[ValidateImage] Response Body: ${response.body}");

      // If 200 -> server returned success structure
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      // For non-200 try parse JSON body with a 'reason' field (FastAPI example)
      try {
        final errorBody = json.decode(response.body);
        if (errorBody is Map && errorBody.containsKey('reason')) {
          return {'isValid': false, 'reason': errorBody['reason']};
        }
      } catch (_) {
        // parse failed — fall through
      }

      // fallback message
      return {
        'isValid': false,
        'reason': 'Server returned ${response.statusCode}: ${response.body}'
      };
    } catch (e, st) {
      print("[ValidateImage] ERROR: $e");
      print(st);
      return {'isValid': false, 'reason': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> classifyImageBytes(Uint8List imageBytes, String fileName, String mimeType) async {
    try {
      final uri = Uri.parse("$_baseUrl/classify-image/");
      final request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Classification failed (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      throw Exception("Connection error: $e");
    }
  }

  /// Classify an image if validation passes
  Future<Map<String, dynamic>> classifyImage(String filePath) async {
    try {
      final info = await _inspectFile(filePath);
      if (info['ok'] != true) {
        return {
          "classification": null,
          "confidence": null,
          "error": info['reason'] ?? 'File error'
        };
      }

      final uri = Uri.parse("$_baseUrl/classify-image/");
      print("[ClassifyImage] Sending request to: $uri");
      print("[ClassifyImage] File path: $filePath");
      print("[ClassifyImage] File size (bytes): ${info['length']}");
      print("[ClassifyImage] Detected MIME type: ${info['mime']}");
      print("[ClassifyImage] Dimensions: ${info['width']} x ${info['height']}");

      final filename = filePath.split(Platform.pathSeparator).last;
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: filename,
        contentType: MediaType.parse(info['mime'] as String),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("[ClassifyImage] Status Code: ${response.statusCode}");
      print("[ClassifyImage] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      // Try parse JSON error body
      try {
        final errorBody = json.decode(response.body);
        if (errorBody is Map && errorBody.containsKey('reason')) {
          return {
            "classification": null,
            "confidence": null,
            "error": errorBody['reason']
          };
        }
      } catch (_) {}

      return {
        "classification": null,
        "confidence": null,
        "error": "Server returned ${response.statusCode}: ${response.body}"
      };
    } catch (e, st) {
      print("[ClassifyImage] ERROR: $e");
      print(st);
      return {
        "classification": null,
        "confidence": null,
        "error": "Connection error: $e"
      };
    }
  }
}
