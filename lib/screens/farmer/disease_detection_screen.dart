import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:image_picker/image_picker.dart';
import '../../services/ai_service.dart';
import '../../utils/constants.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final AIService _aiService = AIService();
  Uint8List? _selectedImageBytes;
  bool _isAnalyzing = false;
  DiseaseDetectionResult? _detectionResult;

  @override
  void initState() {
    super.initState();
    debugPrint('🖼️ [Disease Detection] Screen initialized');
    // Note: We don't initialize API here - it will be initialized only if needed
    // (i.e., if dataset/model fails or on web platform)
    // The dataset/model initializes automatically in the background
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('📷 [Disease Detection] Picking image from: ${source.name}');
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (image != null) {
        debugPrint('✅ [Disease Detection] Image selected: ${image.name}');
        // Read image bytes directly (works on all platforms)
        final Uint8List imageBytes = await image.readAsBytes();
        debugPrint('📊 [Disease Detection] Image loaded: ${imageBytes.length} bytes');
        
        setState(() {
          _selectedImageBytes = imageBytes;
          _detectionResult = null;
        });
        debugPrint('✅ [Disease Detection] Image set in state');
      } else {
        debugPrint('ℹ️ [Disease Detection] Image selection cancelled');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [Disease Detection] Error picking image:');
      debugPrint('   Error: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImageBytes == null) {
      debugPrint('⚠️ [Disease Detection] No image selected for analysis');
      return;
    }

    debugPrint('🔍 [Disease Detection] Starting image analysis...');
    setState(() {
      _isAnalyzing = true;
      _detectionResult = null;
    });

    try {
      debugPrint('📤 [Disease Detection] Calling AI service...');
      final result = await _aiService.detectPlantDisease(_selectedImageBytes!);
      debugPrint('✅ [Disease Detection] Analysis complete:');
      debugPrint('   - Disease: ${result.diseaseName}');
      debugPrint('   - Confidence: ${result.confidence}%');
      debugPrint('   - Has description: ${result.description.isNotEmpty}');
      debugPrint('   - Has treatment: ${result.treatment.isNotEmpty}');
      
      setState(() {
        _detectionResult = result;
        _isAnalyzing = false;
      });
      debugPrint('✅ [Disease Detection] Result displayed in UI');
    } catch (e, stackTrace) {
      debugPrint('❌ [Disease Detection] Error during analysis:');
      debugPrint('   Error: $e');
      debugPrint('   Stack trace: $stackTrace');
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Capture or upload an image of your plant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        _selectedImageBytes == null
                            ? Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        if (_selectedImageBytes != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  debugPrint('🗑️ [Disease Detection] Clearing selected image');
                                  setState(() {
                                    _selectedImageBytes = null;
                                    _detectionResult = null;
                                  });
                                },
                                tooltip: 'Clear image',
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: kIsWeb 
                                ? null 
                                : () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: Text(kIsWeb ? 'Camera (N/A)' : 'Camera'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedImageBytes != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          debugPrint('🔄 [Disease Detection] User wants to change image');
                          _pickImage(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Different Image'),
                      ),
                    ],
                    if (_selectedImageBytes != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeImage,
                          icon: _isAnalyzing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.search),
                          label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Disease'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(AppConstants.primaryColorValue),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_detectionResult != null) ...[
              const SizedBox(height: 24),
              _buildDetectionResult(_detectionResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionResult(DiseaseDetectionResult result) {
    final isHealthy = result.diseaseName.toLowerCase().contains('healthy') ||
        result.diseaseName.toLowerCase().contains('no disease');

    return Card(
      color: isHealthy
          ? Colors.green.withOpacity(0.1)
          : Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy ? Icons.check_circle : Icons.warning,
                  color: isHealthy ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.diseaseName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confidence: ${result.confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Description:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(result.description),
                  const SizedBox(height: 16),
                  const Text(
                    'Treatment:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(result.treatment),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Save detection result
                      debugPrint('💾 [Disease Detection] Saving detection result');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Detection result saved'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save Result'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('🔄 [Disease Detection] User wants to try different image');
                      setState(() {
                        _selectedImageBytes = null;
                        _detectionResult = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Another'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryColorValue),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

