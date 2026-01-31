import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload product image
  Future<String?> uploadProductImage({
    required Uint8List imageBytes,
    required String productId,
    required String farmerId,
  }) async {
    try {
      final String fileName = 'products/$farmerId/$productId.jpg';
      final Reference ref = _storage.ref().child(fileName);

      // Upload image
      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=31536000', // Cache for 1 year
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ [Storage Service] Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ [Storage Service] Upload error: $e');
      return null;
    }
  }

  /// Upload generic image
  Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String path,
  }) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'max-age=31536000',
        ),
      );
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('❌ [Storage Service] Upload error: $e');
      return null;
    }
  }

  /// Delete product image
  Future<bool> deleteProductImage({
    required String productId,
    required String farmerId,
  }) async {
    try {
      final String fileName = 'products/$farmerId/$productId.jpg';
      final Reference ref = _storage.ref().child(fileName);

      await ref.delete();
      debugPrint('✅ [Storage Service] Image deleted: $fileName');
      return true;
    } catch (e) {
      debugPrint('❌ [Storage Service] Delete error: $e');
      return false;
    }
  }

  /// Upload image from file picker
  Future<Uint8List?> pickAndGetImageBytes(ImageSource source) async {
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
        debugPrint(
          '✅ [Storage Service] Image picked: ${imageBytes.length} bytes',
        );
        return imageBytes;
      }
      return null;
    } catch (e) {
      debugPrint('❌ [Storage Service] Pick image error: $e');
      if (kIsWeb) {
        debugPrint(
          '   Web platform: Make sure file picker is working correctly',
        );
      }
      return null;
    }
  }
}
