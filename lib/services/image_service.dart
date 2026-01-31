import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImageService {
  /// Convert image bytes to base64 string
  Future<String?> convertImageToBase64(Uint8List imageBytes) async {
    try {
      // Compress image to reduce size (max 800px width, 85% quality)
      final compressedBytes = await _compressImage(imageBytes);
      
      // Convert to base64
      final base64String = base64Encode(compressedBytes);
      
      debugPrint('✅ [Image Service] Image converted to base64: ${base64String.length} chars');
      return base64String;
    } catch (e) {
      debugPrint('❌ [Image Service] Convert to base64 error: $e');
      return null;
    }
  }

  /// Compress image to reduce file size
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('⚠️ [Image Service] Failed to decode image, using original');
        return imageBytes;
      }

      // Resize if too large (max width 800px)
      img.Image resizedImage = image;
      if (image.width > 800) {
        final ratio = 800 / image.width;
        resizedImage = img.copyResize(
          image,
          width: 800,
          height: (image.height * ratio).round(),
        );
      }

      // Encode as JPEG with 85% quality
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: 85),
      );

      debugPrint('✅ [Image Service] Image compressed: ${imageBytes.length} → ${compressedBytes.length} bytes');
      return compressedBytes;
    } catch (e) {
      debugPrint('❌ [Image Service] Compress error: $e, using original');
      return imageBytes;
    }
  }

  /// Convert base64 string back to image bytes
  Uint8List? base64ToImageBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('❌ [Image Service] Base64 decode error: $e');
      return null;
    }
  }

  /// Pick image from camera or gallery and return as base64
  Future<String?> pickAndConvertToBase64(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // On web, camera is not supported, so force gallery
      final ImageSource actualSource = kIsWeb ? ImageSource.gallery : source;
      
      final XFile? image = await picker.pickImage(
        source: actualSource,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        debugPrint('✅ [Image Service] Image picked: ${imageBytes.length} bytes');
        
        // Convert to base64
        return await convertImageToBase64(imageBytes);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [Image Service] Pick image error: $e');
      if (kIsWeb) {
        debugPrint('   Web platform: Make sure file picker is working correctly');
      }
      return null;
    }
  }

  /// Get image bytes from picker (for preview)
  Future<Uint8List?> pickImageBytes(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // On web, camera is not supported, so force gallery
      final ImageSource actualSource = kIsWeb ? ImageSource.gallery : source;
      
      final XFile? image = await picker.pickImage(
        source: actualSource,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        return imageBytes;
      }
      return null;
    } catch (e) {
      debugPrint('❌ [Image Service] Pick image bytes error: $e');
      return null;
    }
  }
}
