// Stub file for non-web platforms where tflite_web is not available
import 'dart:typed_data';

class TFLiteWebHelper {
  bool get isInitialized => false;
  List<String> get labels => [];
  
  Future<void> initialize() async {
    throw UnimplementedError('TFLiteWebHelper not available on non-web platforms');
  }
  
  Future<List<double>> runInference(Uint8List imageBytes) async {
    throw UnimplementedError('TFLiteWebHelper not available on non-web platforms');
  }
}

