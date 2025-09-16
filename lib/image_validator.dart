import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

img.Image _convolution(img.Image src, List<List<int>> kernel) {
  final int kernelWidth = kernel[0].length;
  final int kernelHeight = kernel.length;
  final int kernelCenterX = kernelWidth ~/ 2;
  final int kernelCenterY = kernelHeight ~/ 2;

  final dst = img.Image(width: src.width, height: src.height, numChannels: 1);

  for (int y = 0; y < src.height; ++y) {
    for (int x = 0; x < src.width; ++x) {
      double r = 0.0;
      for (int ky = 0; ky < kernelHeight; ++ky) {
        for (int kx = 0; kx < kernelWidth; ++kx) {
          final int pixelX = x + (kx - kernelCenterX);
          final int pixelY = y + (ky - kernelCenterY);

          if (pixelX >= 0 && pixelX < src.width && pixelY >= 0 && pixelY < src.height) {
            final p = src.getPixel(pixelX, pixelY);
            r += p.r * kernel[ky][kx];
          }
        }
      }
      dst.setPixelR(x, y, r.clamp(0, 255).toInt()); 
    }
  }
  return dst;
}

img.Image laplacian(img.Image src) {
  const kernel = [
    [0, 1, 0],
    [1, -4, 1],
    [0, 1, 0]
  ];
  return _convolution(src, kernel);
}

class Rect {
  final int left, top, width, height;
  Rect(this.left, this.top, this.width, this.height);
}

class CataractAnalysisResult {
  final bool isValid;
  final bool isCataract;
  final String reason;
  CataractAnalysisResult(this.isValid, this.isCataract, this.reason);
}

class ImageValidator {
  // Function to check if the image is blurry
  static bool isBlurry(img.Image image, {double threshold = 60.0}) {
    final gray = img.grayscale(image);
    final laplacianImage = laplacian(gray);

    double mean = 0.0;
    double variance = 0.0;
    int count = 0;

    for (final p in laplacianImage) {
      mean += p.r;
      count++;
    }
    mean /= count;

    for (final p in laplacianImage) {
      variance += (p.r - mean) * (p.r - mean);
    }
    variance /= count;

    return variance < threshold;
  }

  // Step 2: Eye detection 
  static Rect? detectEye(img.Image image) {
    final gray = img.grayscale(image);

    int bestX = 0, bestY = 0, bestW = 0, bestH = 0, maxScore = 0;
    for (int y = 0; y < gray.height - 50; y += 10) {
      for (int x = 0; x < gray.width - 50; x += 10) {
        int score = 0;
        for (int dy = 0; dy < 50; dy++) {
          for (int dx = 0; dx < 50; dx++) {
            int px = (gray.getPixel(x + dx, y + dy).r).toInt();
            if (px < 60) score++;
          }
        }
        if (score > maxScore) {
          maxScore = score;
          bestX = x;
          bestY = y;
          bestW = 50;
          bestH = 50;
        }
      }
    }
    if (maxScore > 500) {
      return Rect(bestX, bestY, bestW, bestH);
    }
    return null;
  }

  // Step 3: Pupil detection
  static Rect? detectPupil(img.Image eyeRegion) {
    int bestX = 0, bestY = 0, bestR = 0;
    double minAvg = 255.0;
    for (int r = 10; r < min(eyeRegion.width, eyeRegion.height) ~/ 2; r += 5) {
      for (int cy = r; cy < eyeRegion.height - r; cy += 5) {
        for (int cx = r; cx < eyeRegion.width - r; cx += 5) {
          double sum = 0.0;
          int count = 0;
          for (int y = -r; y <= r; y++) {
            for (int x = -r; x <= r; x++) {
              if (x * x + y * y <= r * r) {
                int px = (eyeRegion.getPixel(cx + x, cy + y).r).toInt();
                sum += px;
                count++;
              }
            }
          }
          double avg = count > 0 ? sum / count : 255.0;
          if (avg < minAvg) {
            minAvg = avg;
            bestX = cx;
            bestY = cy;
            bestR = r;
          }
        }
      }
    }
    if (minAvg < 80) {
      return Rect(bestX - bestR, bestY - bestR, bestR * 2, bestR * 2);
    }
    return null;
  }

  // Step 4: Cataract feature analysis 
  static Map<String, double> analyzeCataractFeatures(img.Image pupilRegion) {
    List<int> pixels = [];
    for (int y = 0; y < pupilRegion.height; y++) {
      for (int x = 0; x < pupilRegion.width; x++) {
        pixels.add(pupilRegion.getPixel(x, y).r.toInt());
      }
    }
    double avgIntensity = pixels.isEmpty ? 0 : pixels.reduce((a, b) => a + b) / pixels.length;
    double stdDev = pixels.isEmpty
        ? 0
        : sqrt(pixels.map((v) => pow(v - avgIntensity, 2)).reduce((a, b) => a + b) / pixels.length);
    double opacityRatio = pixels.isEmpty
        ? 0
        : pixels.where((v) => v > 190).length / pixels.length;
    return {
      'intensity': avgIntensity,
      'texture': stdDev,
      'opacity_ratio': opacityRatio,
    };
  }

  // Step 5: Cataract classification
  static CataractAnalysisResult classifyCataract(Map<String, double> features) {
    if (features.isEmpty) {
      return CataractAnalysisResult(false, false, "Analysis failed: Could not extract features.");
    }
    double score = 0;
    List<String> reasons = [];
    double intensity = features['intensity'] ?? 0;
    double texture = features['texture'] ?? 0;
    double opacity = features['opacity_ratio'] ?? 0;

    if (intensity > 100) {
      score += (intensity - 100) / 20.0;
      reasons.add("High Intensity (${intensity.toStringAsFixed(1)})");
    }
    if (texture > 20) {
      score += (texture - 20) / 10.0;
      reasons.add("High Texture (${texture.toStringAsFixed(1)})");
    }
    if (opacity > 0.1) {
      score += opacity * 15;
      reasons.add("High Opacity (${opacity.toStringAsFixed(2)})");
    }
    bool isCataract = score >= 1.5;
    String reason = '''
  Score: ${score.toStringAsFixed(2)}
  Features: Intensity=${intensity.toStringAsFixed(2)}, Texture=${texture.toStringAsFixed(2)}, Opacity=${opacity.toStringAsFixed(2)}
  Indicators: ${reasons.join(', ')}
  '''; 
    return CataractAnalysisResult(true, isCataract, reason);
  }

  static Future<CataractAnalysisResult> validateImageForCataract(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return CataractAnalysisResult(false, false, "File does not exist.");
    }
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      return CataractAnalysisResult(false, false, "Could not decode image.");
    }
    if (isBlurry(image)) {
      return CataractAnalysisResult(false, false, "Image is blurry.");
    }
    final eyeRect = detectEye(image);
    if (eyeRect == null) {
      return CataractAnalysisResult(false, false, "No eye found.");
    }
    final eyeRegion = img.copyCrop(
      image,
      x: eyeRect.left,
      y: eyeRect.top,
      width: eyeRect.width,
      height: eyeRect.height,
    );
    final pupilRect = detectPupil(eyeRegion);
    if (pupilRect == null) {
      return CataractAnalysisResult(false, false, "No pupil found.");
    }
    final pupilRegion = img.copyCrop(
      eyeRegion,
      x: pupilRect.left,
      y: pupilRect.top,
      width: pupilRect.width,
      height: pupilRect.height,
    );
    final features = analyzeCataractFeatures(pupilRegion);
    final result = classifyCataract(features);
    return result;
  }

  static Future<bool> isImageValid(String imagePath) async {
    final result = await validateImageForCataract(imagePath);
    return result.isValid && result.isCataract;
  }
}