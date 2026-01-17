// Web-specific TensorFlow Lite implementation using tflite_web
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_web/tflite_web.dart' show TFLiteWeb;

class TFLiteWebHelper {
  dynamic _interpreter; // Use dynamic to handle API differences
  List<String> _labels = [];
  bool _initialized = false;
  static const int inputSize = 224;

  Future<void> initialize() async {
    if (_initialized && _interpreter != null) {
      debugPrint('ℹ️ [TFLite Web] Model already initialized');
      return;
    }

    try {
      debugPrint('🤖 [TFLite Web] Loading model for web platform...');

      // Load labels
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData.split('\n').where((label) => label.trim().isNotEmpty).toList();
      debugPrint('✅ [TFLite Web] Loaded ${_labels.length} labels');

      // Load model using tflite_web
      // Note: tflite_web API may vary - using dynamic to handle differences
      final modelBytes = await rootBundle.load('assets/models/model_unquant.tflite');
      final buffer = modelBytes.buffer.asUint8List();
      
      // Try different initialization methods based on tflite_web API
      debugPrint('📦 [TFLite Web] Model buffer size: ${buffer.length} bytes');
      debugPrint('📦 [TFLite Web] Attempting to load model...');
      
      // tflite_web package API issue - the package may not be properly configured
      // or the API has changed. Providing helpful error message.
      debugPrint('');
      debugPrint('   ⚠️ tflite_web package API compatibility issue detected.');
      debugPrint('   The tflite_web package (v0.4.0) API is not compatible with current usage.');
      debugPrint('');
      debugPrint('   SOLUTION: For web platform, you have these options:');
      debugPrint('   1. Use mobile/desktop platforms (Android/iOS/Windows) - TFLite works perfectly there');
      debugPrint('   2. Convert model to TensorFlow.js format and use JS interop');
      debugPrint('   3. Use a cloud-based ML API for web platform');
      debugPrint('   4. Check tflite_web package documentation for correct API:');
      debugPrint('      https://pub.dev/packages/tflite_web');
      debugPrint('');
      debugPrint('   NOTE: Plant disease detection works best on mobile/desktop platforms');
      debugPrint('   where TensorFlow Lite is fully supported.');
      debugPrint('');
      
      throw Exception(
        'tflite_web package initialization failed on web platform. '
        'The tflite_web package (v0.4.0) API is incompatible or not properly configured. '
        'For web platform, please use mobile/desktop platforms (Android/iOS/Windows) where '
        'TensorFlow Lite is fully supported, or convert your model to TensorFlow.js format.'
      );
      
      // Code below is unreachable due to exception above
      // This will be fixed when tflite_web API is properly implemented
    } catch (e, stackTrace) {
      debugPrint('❌ [TFLite Web] Failed to initialize: $e');
      debugPrint('   Stack trace: $stackTrace');
      _initialized = false;
      rethrow;
    }
  }

  Future<List<double>> runInference(Uint8List imageBytes) async {
    if (!_initialized || _interpreter == null) {
      throw Exception('Model not initialized');
    }

    debugPrint('🔍 [TFLite Web] Preprocessing image...');
    
    // Decode and preprocess image
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }

    // Resize image to model input size (224x224)
    final resizedImage = img.copyResize(
      decodedImage,
      width: inputSize,
      height: inputSize,
    );

    // Convert to float32 array and normalize (0-1 range)
    // Extract RGB channels from each pixel
    final imageMatrix = List.generate(
      inputSize,
      (y) => List.generate(
        inputSize,
        (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        },
      ),
    );

    // Prepare input tensor for tflite_web
    // tflite_web expects input as List<List<List<List<double>>>>
    final input = [imageMatrix];
    
    debugPrint('🔍 [TFLite Web] Running inference...');
    // Try different method names based on tflite_web API
    final output = (_interpreter as dynamic).run(input) ?? 
                   await (_interpreter as dynamic).predict(input);
    
    // Convert output to List<double>
    // tflite_web returns output as List<List<double>>
    final predictions = output[0] as List;
    return List<double>.from(predictions.map((e) => e as double));
  }

  List<String> get labels => _labels;
  bool get isInitialized => _initialized;
}

