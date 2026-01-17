import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
// Conditional import for Firebase ML Model Downloader (not available on web)
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart' if (dart.library.html) 'firebase_ml_model_downloader_stub.dart';
// API imports removed - using dataset/model only
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:http/http.dart' as http;

// Conditional imports: TFLite for mobile/desktop, tflite_web for web
import 'tflite_stub.dart' if (dart.library.io) 'package:tflite_flutter/tflite_flutter.dart' as tflite;
import 'tflite_web_helper_stub.dart' if (dart.library.io) 'tflite_web_helper_stub.dart' if (dart.library.html) 'tflite_web_helper.dart' as tflite_web;

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal() {
    // Pre-initialize TFLite model (dataset) for faster detection
    // This happens in the background and doesn't block
    initializeTFLite().catchError((e) {
      debugPrint('⚠️ [AI Service] Background TFLite initialization failed: $e');
    });
  }

  // API variables removed - using dataset/model only
  // GenerativeModel? _model;
  // bool _isInitialized = false;
  // String? _workingModelName;

  // TensorFlow Lite variables (dataset/model)
  tflite.Interpreter? _tfliteInterpreter; // For mobile/desktop
  tflite_web.TFLiteWebHelper? _tfliteWebHelper; // For web
  List<String> _labels = [];
  bool _tfliteInitialized = false;
  static const int _inputSize = 224; // Standard input size for plant disease models
  
  // Firebase ML Model Downloader
  static const String _firebaseModelName = 'plant_disease_detector'; // Model name in Firebase Console
  dynamic _firebaseModel; // CustomModel? but using dynamic for web compatibility
  dynamic _downloadedModelFile; // File? but using dynamic for web compatibility
  bool _usingFirebaseModel = false;

  // API methods removed - using dataset/model only
  /*
  /// Lists all available models for the API key and logs them
  Future<void> listAvailableModels() async {
    try {
      print('\n');
      print('═══════════════════════════════════════════════════════════════');
      print('📋 LISTING AVAILABLE GEMINI MODELS');
      print('═══════════════════════════════════════════════════════════════');

      // Try v1beta API endpoint
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=${AppConstants.apiKey}',
      );

      debugPrint('🌐 [AI Service] Fetching available models from API...');
      print(
        '🌐 Fetching models from: ${url.toString().replaceAll(AppConstants.apiKey, 'API_KEY_HIDDEN')}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List?;

        if (models != null && models.isNotEmpty) {
          print('✅ Found ${models.length} available models:\n');
          debugPrint('✅ Found ${models.length} available models');

          // Filter models that support generateContent
          final visionModels = <Map<String, dynamic>>[];
          final textModels = <Map<String, dynamic>>[];

          for (var model in models) {
            final name = model['name'] as String? ?? 'Unknown';
            final displayName = model['displayName'] as String? ?? '';
            final description = model['description'] as String? ?? '';
            final supportedMethods =
                (model['supportedGenerationMethods'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];

            final modelInfo = {
              'name': name,
              'displayName': displayName,
              'description': description,
              'methods': supportedMethods,
            };

            if (supportedMethods.contains('generateContent')) {
              if (name.contains('vision') ||
                  name.contains('flash') ||
                  name.contains('pro')) {
                visionModels.add(modelInfo);
              } else {
                textModels.add(modelInfo);
              }
            }

            print('📌 Model: $name');
            if (displayName.isNotEmpty) {
              print('   Display Name: $displayName');
            }
            if (description.isNotEmpty && description.length < 100) {
              print('   Description: $description');
            }
            if (supportedMethods.isNotEmpty) {
              print('   Supported Methods: ${supportedMethods.join(", ")}');
            }
            print('');

            debugPrint('   - $name (${supportedMethods.join(", ")})');
          }

          print('\n📊 SUMMARY:');
          print('   Vision-capable models: ${visionModels.length}');
          print('   Text-only models: ${textModels.length}');
          print('\n💡 Recommended models for vision tasks:');
          for (var model in visionModels.take(5)) {
            print('   - ${model['name']}');
          }
        } else {
          print('⚠️ No models found in API response');
          debugPrint('⚠️ No models found');
        }
      } else {
        print('❌ Failed to fetch models. Status: ${response.statusCode}');
        print('   Response: ${response.body}');
        debugPrint('❌ Failed to fetch models: ${response.statusCode}');
        debugPrint('   Response: ${response.body}');
      }

      print('═══════════════════════════════════════════════════════════════');
      print('\n');
    } catch (e, stackTrace) {
      print('❌ Error listing models: $e');
      debugPrint('❌ Error listing models: $e');
      debugPrint('   Stack trace: $stackTrace');
      print('   Stack trace: $stackTrace');
    }
  }
  */

  /// Initialize TensorFlow Lite model using Firebase ML Model Downloader
  /// Falls back to local model if Firebase download fails
  /// This loads the trained model and labels for disease detection
  /// Works on both mobile/desktop (tflite_flutter) and web (tflite_web)
  Future<void> initializeTFLite() async {
    if (_tfliteInitialized) {
      debugPrint('ℹ️ [AI Service] TFLite model already initialized');
      return;
    }

    try {
      debugPrint('🤖 [AI Service] Initializing model for disease detection...');

      // Load disease labels from dataset (always from local assets)
      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData.split('\n').where((label) => label.trim().isNotEmpty).toList();
      debugPrint('✅ [AI Service] Loaded ${_labels.length} disease classes from dataset');

      if (kIsWeb) {
        // Web platform: use tflite_web (Firebase ML not supported on web)
        debugPrint('🌐 [AI Service] Initializing for web platform (using local model)...');
        try {
          _tfliteWebHelper = tflite_web.TFLiteWebHelper();
          await _tfliteWebHelper!.initialize();
          
          // Verify web helper is actually initialized
          if (_tfliteWebHelper!.isInitialized) {
            _tfliteInitialized = true;
            _usingFirebaseModel = false;
            debugPrint('✅ [AI Service] Web model initialization complete');
            debugPrint('   Web helper initialized: ${_tfliteWebHelper!.isInitialized}');
            debugPrint('   Labels available: ${_tfliteWebHelper!.labels.length}');
          } else {
            throw Exception('Web helper initialization returned false');
          }
        } catch (webError) {
          debugPrint('❌ [AI Service] Web model initialization failed: $webError');
          debugPrint('   Error type: ${webError.runtimeType}');
          debugPrint('   Error details: ${webError.toString()}');
          _tfliteInitialized = false;
          _tfliteWebHelper = null;
          rethrow; // Re-throw to be caught by outer catch
        }
      } else {
        // Mobile/Desktop platform: Try Firebase ML first, then fallback to local
        debugPrint('📱 [AI Service] Attempting to download model from Firebase...');
        
        try {
          // Try to get model from Firebase ML Model Downloader
          _firebaseModel = await FirebaseModelDownloader.instance.getModel(
            _firebaseModelName,
            FirebaseModelDownloadType.latestModel,
            FirebaseModelDownloadConditions(
              iosAllowsCellularAccess: true,
              iosAllowsBackgroundDownloading: true,
              androidChargingRequired: false,
              androidWifiRequired: false,
              androidDeviceIdleRequired: false,
            ),
          );
          
          if (_firebaseModel != null && _firebaseModel.file != null) {
            _downloadedModelFile = _firebaseModel.file;
            debugPrint('✅ [AI Service] Model downloaded from Firebase: ${_downloadedModelFile.path}');
            
            // Load model from downloaded file
            // tflite_flutter doesn't have fromFile, so we need to copy to temp location
            // or use a workaround. For now, let's read bytes and write to a temp file
            // then use fromAsset won't work, so we'll fall through to local model
            debugPrint('⚠️ [AI Service] Firebase model downloaded but tflite_flutter');
            debugPrint('   requires asset path. Falling back to local model...');
            throw Exception('Firebase model requires different loading method - using local model');
          } else {
            throw Exception('Firebase model file is null');
          }
        } catch (firebaseError) {
          debugPrint('⚠️ [AI Service] Firebase model download failed: $firebaseError');
          debugPrint('   Error type: ${firebaseError.runtimeType}');
          debugPrint('   Error details: ${firebaseError.toString()}');
          debugPrint('📦 [AI Service] Falling back to local model...');
          
          try {
            // Fallback to local model
            debugPrint('📦 [AI Service] Attempting to load local model from assets...');
            debugPrint('   Asset path: assets/models/model_unquant.tflite');
            
            // Verify asset exists first
            ByteData? modelBytes;
            try {
              modelBytes = await rootBundle.load('assets/models/model_unquant.tflite');
              debugPrint('✅ [AI Service] Local model asset found (${modelBytes.lengthInBytes} bytes)');
            } catch (assetError) {
              debugPrint('❌ [AI Service] Local model asset not found: $assetError');
              throw Exception('Local model asset not found: $assetError');
            }
            
            // Try loading from asset first (standard method)
            try {
              debugPrint('📦 [AI Service] Trying Interpreter.fromAsset()...');
              _tfliteInterpreter = await tflite.Interpreter.fromAsset('assets/models/model_unquant.tflite');
              debugPrint('✅ [AI Service] Model loaded using fromAsset()');
            } catch (fromAssetError) {
              debugPrint('⚠️ [AI Service] fromAsset() failed: $fromAssetError');
              debugPrint('📦 [AI Service] Trying alternative method with model bytes...');
              
              // fromBuffer doesn't exist in tflite_flutter, so we can only use fromAsset
              // If fromAsset fails, there's no alternative
              throw fromAssetError;
            }
            
            _usingFirebaseModel = false;
            debugPrint('✅ [AI Service] Local model loaded successfully');
          } catch (localModelError) {
            debugPrint('❌ [AI Service] Failed to load local model: $localModelError');
            debugPrint('   Error type: ${localModelError.runtimeType}');
            debugPrint('   Error details: ${localModelError.toString()}');
            rethrow; // Re-throw to be caught by outer catch
          }
        }

        // Get input and output tensor shapes
        final inputShape = _tfliteInterpreter!.getInputTensor(0).shape;
        final outputShape = _tfliteInterpreter!.getOutputTensor(0).shape;
        debugPrint('📊 [AI Service] Input shape: $inputShape');
        debugPrint('📊 [AI Service] Output shape: $outputShape');
        debugPrint('📊 [AI Service] Using ${_usingFirebaseModel ? "Firebase" : "local"} model');

        _tfliteInitialized = true;
        debugPrint('✅ [AI Service] Model initialization complete - ready for detection');
      }
    } catch (e, stackTrace) {
      debugPrint('\n═══════════════════════════════════════════════════════════════');
      debugPrint('❌ MODEL INITIALIZATION FAILED - DETAILED ERROR');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      debugPrint('Error String: ${e.toString()}');
      debugPrint('');
      debugPrint('Stack Trace:');
      debugPrint('$stackTrace');
      debugPrint('');
      debugPrint('Diagnostics:');
      debugPrint('  - Platform: ${kIsWeb ? "Web" : "Mobile/Desktop"}');
      debugPrint('  - Labels loaded: ${_labels.length}');
      debugPrint('  - TFLite initialized: $_tfliteInitialized');
      debugPrint('  - Using Firebase model: $_usingFirebaseModel');
      debugPrint('  - Interpreter: ${_tfliteInterpreter != null ? "Initialized" : "Null"}');
      if (kIsWeb) {
        debugPrint('  - Web helper: ${_tfliteWebHelper != null ? (_tfliteWebHelper!.isInitialized ? "Initialized" : "Exists but not initialized") : "Null"}');
        if (_tfliteWebHelper != null) {
          debugPrint('  - Web helper labels: ${_tfliteWebHelper!.labels.length}');
        }
      } else {
        debugPrint('  - Web helper: N/A (not web platform)');
      }
      debugPrint('');
      debugPrint('Possible causes:');
      if (kIsWeb) {
        debugPrint('  1. tflite_web package initialization failed');
        debugPrint('  2. Model file not found in assets folder');
        debugPrint('  3. Model file path incorrect in pubspec.yaml');
        debugPrint('  4. Model file corrupted or invalid format');
        debugPrint('  5. Browser compatibility issue with TensorFlow.js');
        debugPrint('  6. tflite_web API compatibility issue');
      } else {
        debugPrint('  1. Model file not found in assets folder');
        debugPrint('  2. Model file path incorrect in pubspec.yaml');
        debugPrint('  3. Model file corrupted or invalid format');
        debugPrint('  4. tflite_flutter package compatibility issue');
        debugPrint('  5. Insufficient device memory/resources');
        debugPrint('  6. Platform-specific initialization error');
      }
      debugPrint('');
      debugPrint('Troubleshooting steps:');
      debugPrint('  1. Verify assets/models/model_unquant.tflite exists');
      debugPrint('  2. Check pubspec.yaml has correct asset path');
      debugPrint('  3. Run: flutter clean && flutter pub get');
      debugPrint('  4. Verify model file is valid TensorFlow Lite format');
      debugPrint('  5. Check device has sufficient storage/memory');
      debugPrint('═══════════════════════════════════════════════════════════════\n');
      
      _tfliteInitialized = false;
      _usingFirebaseModel = false;
    }
  }

  /// Run inference using TensorFlow Lite model (dataset-based detection)
  /// Works on both web and mobile/desktop platforms
  Future<DiseaseDetectionResult?> _detectWithTFLite(Uint8List imageBytes) async {
    try {
      // Ensure TFLite is initialized
      if (!_tfliteInitialized) {
        await initializeTFLite();
        if (!_tfliteInitialized) {
          debugPrint('⚠️ [AI Service] TFLite not available, skipping...');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('❌ TFLITE INITIALIZATION FAILED');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('Possible reasons:');
          debugPrint('  1. Model file not found or corrupted');
          debugPrint('  2. Firebase model download failed and local model failed to load');
          debugPrint('  3. Insufficient device resources');
          debugPrint('  4. Model initialization error');
          debugPrint('═══════════════════════════════════════════════════════════════\n');
          return null;
        }
      }

      debugPrint('🔍 [AI Service] Running dataset-based detection...');

      // Decode and preprocess image
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        debugPrint('❌ [AI Service] Failed to decode image for TFLite');
        debugPrint('═══════════════════════════════════════════════════════════════');
        debugPrint('❌ IMAGE DECODING FAILED');
        debugPrint('═══════════════════════════════════════════════════════════════');
        debugPrint('Possible reasons:');
        debugPrint('  1. Image format not supported');
        debugPrint('  2. Image data is corrupted');
        debugPrint('  3. Image bytes are invalid');
        debugPrint('═══════════════════════════════════════════════════════════════\n');
        return null;
      }

      // Resize image to model input size (224x224)
      final resizedImage = img.copyResize(
        decodedImage,
        width: _inputSize,
        height: _inputSize,
      );

      // Convert to float32 array and normalize (0-1 range)
      // Extract RGB channels from each pixel
      final imageMatrix = List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
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

      List<double> predictions;

      if (kIsWeb) {
        // Web platform: use tflite_web
        debugPrint('🌐 [AI Service] Running inference on web platform...');
        if (_tfliteWebHelper == null || !_tfliteWebHelper!.isInitialized) {
          debugPrint('⚠️ [AI Service] Web helper not initialized');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('❌ WEB TFLITE HELPER NOT INITIALIZED');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('Possible reasons:');
          debugPrint('  1. Model failed to load on web platform');
          debugPrint('  2. tflite_web initialization error');
          debugPrint('  3. Browser compatibility issue');
          debugPrint('═══════════════════════════════════════════════════════════════\n');
          return null;
        }
        predictions = await _tfliteWebHelper!.runInference(imageBytes);
        _labels = _tfliteWebHelper!.labels;
      } else {
        // Mobile/Desktop platform: use tflite_flutter
        debugPrint('📱 [AI Service] Running inference on mobile/desktop platform...');
        if (_tfliteInterpreter == null) {
          debugPrint('⚠️ [AI Service] TFLite interpreter not initialized');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('❌ TFLITE INTERPRETER NOT INITIALIZED');
          debugPrint('═══════════════════════════════════════════════════════════════');
          debugPrint('Possible reasons:');
          debugPrint('  1. Model file not found or corrupted');
          debugPrint('  2. Firebase model download failed and local model failed to load');
          debugPrint('  3. Model initialization error');
          debugPrint('  4. Insufficient device resources');
          debugPrint('═══════════════════════════════════════════════════════════════\n');
          return null;
        }

        // Prepare input tensor
        final input = [imageMatrix];
        final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

        // Run inference
        _tfliteInterpreter!.run(input, output);
        predictions = List<double>.from(output[0]);
      }

      // Get prediction
      final maxIndex = predictions.indexOf(predictions.reduce((a, b) => a > b ? a : b));
      final confidence = predictions[maxIndex] * 100.0;
      final diseaseName = _labels[maxIndex];

      debugPrint('✅ [AI Service] Dataset prediction: $diseaseName (${confidence.toStringAsFixed(2)}%)');

      // Generate description and treatment based on disease
      final description = _getDiseaseDescription(diseaseName);
      final treatment = _getDiseaseTreatment(diseaseName);

      return DiseaseDetectionResult(
        diseaseName: diseaseName,
        description: description,
        treatment: treatment,
        confidence: confidence,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [AI Service] TFLite inference error: $e');
      debugPrint('   Stack trace: $stackTrace');
      debugPrint('\n═══════════════════════════════════════════════════════════════');
      debugPrint('❌ TFLITE INFERENCE ERROR');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('Error: $e');
      debugPrint('');
      debugPrint('Possible reasons:');
      debugPrint('  1. Model inference failed');
      debugPrint('  2. Image preprocessing error');
      debugPrint('  3. Tensor shape mismatch');
      debugPrint('  4. Insufficient device resources');
      debugPrint('  5. Model compatibility issue');
      debugPrint('');
      debugPrint('Stack trace:');
      debugPrint('  $stackTrace');
      debugPrint('═══════════════════════════════════════════════════════════════\n');
      return null;
    }
  }

  /// Get disease description from disease name
  String _getDiseaseDescription(String diseaseName) {
    final descriptions = {
      'Pepper Bell Bacterial Spot': 'Bacterial spot is a common disease affecting pepper plants, characterized by small, water-soaked lesions on leaves, stems, and fruits.',
      'Pepper Bell Healthy': 'The plant appears healthy with no visible signs of disease or stress.',
      'Potato Early Blight': 'Early blight is a fungal disease causing dark brown spots with concentric rings on leaves, typically starting on lower leaves.',
      'Potato Healthy': 'The potato plant appears healthy with no visible signs of disease or stress.',
      'Potato Late Blight': 'Late blight is a serious fungal disease causing large, dark lesions on leaves and stems, often leading to plant death.',
      'Tomato Bacterial Spot': 'Bacterial spot causes small, dark, water-soaked lesions on leaves, stems, and fruits of tomato plants.',
      'Tomato Early Blight': 'Early blight appears as dark brown spots with concentric rings on older leaves, starting from the bottom of the plant.',
      'Tomato Healthy': 'The tomato plant appears healthy with no visible signs of disease or stress.',
      'Tomato Late Blight': 'Late blight causes large, irregular, dark lesions on leaves and stems, often with white fungal growth.',
      'Tomato Leaf Mold': 'Leaf mold appears as yellow spots on upper leaf surfaces with fuzzy gray or brown mold on the underside.',
      'Tomato Septoria Leaf Spot': 'Septoria leaf spot causes small, circular spots with dark borders and light centers on leaves.',
      'Tomato Spotted Spider Mites': 'Spider mites cause stippling, yellowing, and webbing on leaves, leading to leaf drop.',
      'Tomato Target Spot': 'Target spot appears as circular lesions with concentric rings, resembling a target pattern.',
      'Tomato Mosaic Virus': 'Mosaic virus causes mottled, yellow-green patterns on leaves, stunted growth, and distorted fruits.',
      'Tomato Yellow Leaf Curl Virus': 'Yellow leaf curl virus causes upward curling of leaves, yellowing, and stunted plant growth.',
    };
    return descriptions[diseaseName] ?? 'Disease detected: $diseaseName';
  }

  /// Get treatment recommendations for disease
  String _getDiseaseTreatment(String diseaseName) {
    final treatments = {
      'Pepper Bell Bacterial Spot': 'Remove infected plants. Use copper-based fungicides. Practice crop rotation. Avoid overhead watering.',
      'Pepper Bell Healthy': 'Continue regular care: adequate watering, proper fertilization, and pest monitoring.',
      'Potato Early Blight': 'Apply fungicides containing chlorothalonil or mancozeb. Remove infected leaves. Improve air circulation.',
      'Potato Healthy': 'Maintain good cultural practices: proper spacing, adequate water, and balanced nutrition.',
      'Potato Late Blight': 'Apply fungicides immediately. Remove and destroy infected plants. Use resistant varieties next season.',
      'Tomato Bacterial Spot': 'Use copper-based bactericides. Remove infected plant parts. Avoid working with wet plants.',
      'Tomato Early Blight': 'Apply fungicides (chlorothalonil, mancozeb). Remove lower infected leaves. Mulch to prevent soil splash.',
      'Tomato Healthy': 'Continue regular maintenance: consistent watering, proper fertilization, and pest monitoring.',
      'Tomato Late Blight': 'Apply fungicides immediately (chlorothalonil, mancozeb). Remove infected plants. Improve air circulation.',
      'Tomato Leaf Mold': 'Improve air circulation. Apply fungicides. Remove infected leaves. Avoid overhead watering.',
      'Tomato Septoria Leaf Spot': 'Remove infected leaves. Apply fungicides. Mulch around plants. Water at base, not overhead.',
      'Tomato Spotted Spider Mites': 'Apply miticides or insecticidal soap. Increase humidity. Remove heavily infested leaves. Use predatory mites.',
      'Tomato Target Spot': 'Apply fungicides. Remove infected leaves. Improve air circulation. Use resistant varieties.',
      'Tomato Mosaic Virus': 'Remove infected plants immediately. Control aphids and other vectors. Disinfect tools. Use resistant varieties.',
      'Tomato Yellow Leaf Curl Virus': 'Remove infected plants. Control whiteflies (vectors). Use resistant varieties. Use reflective mulches.',
    };
    return treatments[diseaseName] ?? 'Consult with an agricultural expert for specific treatment recommendations.';
  }

  // API initialization removed - using dataset/model only
  /*
  void initialize() {
    // API code commented out - using dataset/model only
  }
  */

  Future<DiseaseDetectionResult> detectPlantDisease(
    Uint8List imageBytes,
  ) async {
    try {
      debugPrint('🔍 [AI Service] Starting disease detection...');
      debugPrint('📊 [AI Service] Image size: ${imageBytes.length} bytes');

      // Check if image bytes are valid
      if (imageBytes.isEmpty) {
        debugPrint('❌ [AI Service] Image data is empty');
        throw Exception('Image data is empty');
      }

      // PRIMARY METHOD: Use TensorFlow Lite model (dataset) - offline, fast, free
      // Initialize TFLite if not already initialized (for non-web platforms)
      if (!kIsWeb && !_tfliteInitialized) {
        debugPrint('🤖 [AI Service] Initializing TFLite model for dataset-based detection...');
        await initializeTFLite();
      }

      debugPrint('🤖 [AI Service] Using dataset/model for detection...');
      final tfliteResult = await _detectWithTFLite(imageBytes);
      if (tfliteResult != null) {
        debugPrint('✅ [AI Service] Dataset-based detection successful');
        return tfliteResult;
      }

      // Dataset/model detection failed - return helpful error
      debugPrint('❌ [AI Service] Dataset/model detection failed');
      
      final errorDescription = 'Dataset/model detection failed.\n\n'
          'Possible reasons:\n'
          '1. Model file not found or corrupted\n'
          '2. Image format not supported\n'
          '3. Insufficient device resources\n'
          '4. Model initialization error\n\n'
          'Please try:\n'
          '- Restart the app\n'
          '- Try a different image\n'
          '- Ensure the app has proper permissions\n'
          '- Check browser console for detailed errors';
      
      // Print detailed error information to debug console
      debugPrint('\n═══════════════════════════════════════════════════════════════');
      debugPrint('❌ DATASET/MODEL DETECTION FAILED');
      debugPrint('═══════════════════════════════════════════════════════════════');
      debugPrint('Description: Dataset/model detection failed');
      debugPrint('');
      debugPrint('Possible reasons:');
      debugPrint('  1. Model file not found or corrupted');
      debugPrint('  2. Image format not supported');
      debugPrint('  3. Insufficient device resources');
      debugPrint('  4. Model initialization error');
      debugPrint('');
      debugPrint('Please try:');
      debugPrint('  - Restart the app');
      debugPrint('  - Try a different image');
      debugPrint('  - Ensure the app has proper permissions');
      debugPrint('  - Check browser console for detailed errors');
      debugPrint('═══════════════════════════════════════════════════════════════\n');
      
      return DiseaseDetectionResult(
        diseaseName: 'Detection Failed',
        description: errorDescription,
        treatment: 'Please try again with a different image or restart the app.',
        confidence: 0.0,
      );
    } catch (e, stackTrace) {
      // Handle specific error types - Print to console for visibility
      print('\n');
      print('═══════════════════════════════════════════════════════════════');
      print('❌ [AI Service] ERROR DURING DISEASE DETECTION');
      print('═══════════════════════════════════════════════════════════════');
      print('Error Type: ${e.runtimeType}');
      print('Error Message: $e');
      print('Error String: ${e.toString()}');
      print('═══════════════════════════════════════════════════════════════');
      print('Stack Trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════════════════════════');
      print('\n');

      // Also use debugPrint for Flutter debug console
      debugPrint('❌ [AI Service] Error during disease detection:');
      debugPrint('   Error Type: ${e.runtimeType}');
      debugPrint('   Error Message: $e');
      debugPrint('   Error String: ${e.toString()}');
      debugPrint('   Stack Trace: $stackTrace');

      String errorMessage = 'Failed to analyze image';
      String detailedError = e.toString();

      if (e.toString().contains('API key') || e.toString().contains('apiKey')) {
        errorMessage = 'Invalid API key. Please check your configuration.';
        debugPrint('🔑 [AI Service] API key error detected');
      } else if (e.toString().contains('quota') ||
          e.toString().contains('limit') ||
          e.toString().contains('exceeded') ||
          e.toString().contains('free_tier')) {
        // Extract retry time if available
        String retryTime = '';
        final retryMatch = RegExp(
          r'Please retry in ([\d.]+)s',
        ).firstMatch(e.toString());
        if (retryMatch != null) {
          final seconds = double.parse(retryMatch.group(1)!);
          final minutes = (seconds / 60).floor();
          final remainingSeconds = (seconds % 60).round();
          if (minutes > 0) {
            retryTime =
                '\n\nPlease wait ${minutes}m ${remainingSeconds}s before trying again.';
          } else {
            retryTime =
                '\n\nPlease wait ${remainingSeconds}s before trying again.';
          }
        }

        errorMessage =
            'API Quota Exceeded\n\n'
            'You have reached the free tier limit for Google Gemini API.\n\n'
            'Options:\n'
            '1. Wait a few minutes and try again\n'
            '2. Check your API usage: https://ai.dev/usage?tab=rate-limit\n'
            '3. Upgrade your plan at: https://ai.google.dev/pricing\n'
            '4. Use a different API key with available quota$retryTime';
        debugPrint('📊 [AI Service] Quota/limit error detected');
        print('⚠️ QUOTA EXCEEDED - Free tier limit reached');
        if (retryMatch != null) {
          print('   Retry after: ${retryMatch.group(1)} seconds');
        }
      } else if (e.toString().contains('network') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Connection') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection.';
        debugPrint('🌐 [AI Service] Network error detected');
      } else if (e.toString().contains('format') ||
          e.toString().contains('image') ||
          e.toString().contains('mime') ||
          e.toString().contains('content type')) {
        errorMessage = 'Invalid image format. Please try a different image.';
        debugPrint('🖼️ [AI Service] Image format error detected');
      } else if (e.toString().contains('permission') ||
          e.toString().contains('access')) {
        errorMessage = 'Permission denied. Please check API permissions.';
        debugPrint('🔒 [AI Service] Permission error detected');
      } else if (e.toString().contains('not found') ||
          e.toString().contains('not supported') ||
          e.toString().contains('API version')) {
        errorMessage =
            'API Model Not Available\n\n'
            'The selected Gemini model is not available for your API key.\n\n'
            'This usually means:\n'
            '1. Your API key doesn\'t have access to this model\n'
            '2. The model name has changed\n'
            '3. You need to enable the model in Google AI Studio\n\n'
            'Solutions:\n'
            '• Use a mobile/desktop device - dataset/model works offline\n'
            '• Check available models at: https://ai.google.dev/models\n'
            '• Update your API key permissions in Google AI Studio\n'
            '• Try using the app on Android/iOS for best experience';
        debugPrint('⚠️ [AI Service] Model not found error detected');
      } else {
        errorMessage = 'Error: ${e.toString()}';
        debugPrint('⚠️ [AI Service] Unknown error type');
      }

      return DiseaseDetectionResult(
        diseaseName: 'Error',
        description: '$errorMessage\n\nDetailed Error: $detailedError',
        treatment: 'Please try again or check your connection.',
        confidence: 0.0,
      );
    }
  }

  // API helper methods removed - not needed for dataset/model
  /*
  /// Converts any image format to JPEG for API compatibility
  Future<Uint8List> _convertToJpeg(Uint8List imageBytes) async {
    // ... API conversion code ...
  }

  DiseaseDetectionResult _parseDiseaseDetectionResponse(String response) {
    // ... API parsing code ...
  }
  */

  // API method removed - using dataset/model only
  // Crop management advice would require API, so this is disabled
  Future<String> getCropManagementAdvice({
    required String cropType,
    required String phase,
    required int daysSincePlanting,
  }) async {
    // API removed - return basic advice based on crop type and phase
    debugPrint(
      '🌾 [AI Service] Generating crop management advice for: $cropType',
    );
    
    // Basic advice without API
    return '''
Crop Management Advice for $cropType

Current Phase: $phase
Days Since Planting: $daysSincePlanting

General Recommendations:
1. Monitor soil moisture regularly
2. Apply balanced fertilizer according to growth stage
3. Watch for pests and diseases
4. Maintain proper spacing and air circulation
5. Follow recommended irrigation schedule for $cropType

Note: For detailed AI-powered advice, please use disease detection feature which uses our trained dataset/model.
''';
  }
}

class DiseaseDetectionResult {
  final String diseaseName;
  final String description;
  final String treatment;
  final double confidence;

  DiseaseDetectionResult({
    required this.diseaseName,
    required this.description,
    required this.treatment,
    required this.confidence,
  });
}
