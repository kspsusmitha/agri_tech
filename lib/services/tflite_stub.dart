// Stub file for web platform where TFLite is not available
// This prevents import errors on web
import 'dart:typed_data';

class Interpreter {
  // Stub class - methods will never be called on web due to kIsWeb checks
  static Future<dynamic> fromAsset(String path) async {
    throw UnimplementedError('TFLite not available on web');
  }
  
  static Future<dynamic> fromFile(dynamic file) async {
    throw UnimplementedError('TFLite not available on web');
  }
  
  static dynamic fromBuffer(Uint8List buffer) {
    throw UnimplementedError('TFLite not available on web');
  }
  
  dynamic getInputTensor(int index) {
    throw UnimplementedError('TFLite not available on web');
  }
  
  dynamic getOutputTensor(int index) {
    throw UnimplementedError('TFLite not available on web');
  }
  
  void run(List input, List output) {
    throw UnimplementedError('TFLite not available on web');
  }
}

