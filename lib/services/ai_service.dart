import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal() {
    _initializeModel();
  }

  late final GenerativeModel _model;

  void _initializeModel() {
    try {
      _model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash', // Updated to latest stable model
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.4,
        ),
      );
      debugPrint('✅ [AI Service] Vertex AI Model initialized');
    } catch (e) {
      debugPrint('❌ [AI Service] Error initializing model: $e');
    }
  }

  Future<DiseaseDetectionResult> detectPlantDisease(
    Uint8List imageBytes,
  ) async {
    try {
      debugPrint('🔍 [AI Service] Starting disease detection with Gemini...');

      if (imageBytes.isEmpty) {
        throw Exception('Image data is empty');
      }

      final prompt = '''
        Analyze this plant image for diseases or pests.
        Return a JSON object with the following structure:
        {
          "disease_name": "Name of the disease or 'Healthy'",
          "confidence": 95.5,
          "description": "Brief description of the condition.",
          "treatment": "Recommended treatment steps (chemical and biological).",
          "product_keywords": ["keyword1", "keyword2"] 
        }
        
        "product_keywords" should be a list of generic medicine names or types (e.g., "Copper Fungicide", "Neem Oil") that can be used to search for products in a store.
        If the plant is healthy, provide care tips in 'treatment' and leave 'product_keywords' empty.
        If the image is not a plant, return "disease_name": "Not a Plant".
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', imageBytes),
        ]),
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('No response from AI');
      }

      debugPrint('🤖 [AI Service] Raw Response: $responseText');

      final jsonMap = json.decode(responseText) as Map<String, dynamic>;

      return DiseaseDetectionResult(
        diseaseName: jsonMap['disease_name'] ?? 'Unknown',
        description: jsonMap['description'] ?? 'No description available.',
        treatment: jsonMap['treatment'] ?? 'No treatment recommended.',
        confidence: (jsonMap['confidence'] as num?)?.toDouble() ?? 0.0,
        productKeywords: List<String>.from(jsonMap['product_keywords'] ?? []),
      );
    } catch (e) {
      debugPrint('❌ [AI Service] Detection failed: $e');
      return DiseaseDetectionResult(
        diseaseName: 'Error',
        description: 'Failed to analyze the image. Please try again.',
        treatment: e.toString(),
        confidence: 0.0,
        productKeywords: [],
      );
    }
  }

  Future<String> getCropManagementAdvice({
    required String cropType,
    required String phase,
    required int daysSincePlanting,
  }) async {
    debugPrint(
      '🌾 [AI Service] Generating crop management advice for: $cropType',
    );

    // Basic advice without API - could be enhanced with Gemini later
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
''';
  }
}

class DiseaseDetectionResult {
  final String diseaseName;
  final String description;
  final String treatment;
  final double confidence;
  final List<String> productKeywords;

  DiseaseDetectionResult({
    required this.diseaseName,
    required this.description,
    required this.treatment,
    required this.confidence,
    required this.productKeywords,
  });
}
