import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:image_picker/image_picker.dart';
import '../../services/ai_service.dart';
import '../../services/medicine_service.dart';
import '../../services/disease_service.dart';
import '../../services/session_service.dart';
import '../../models/medicine_model.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final AIService _aiService = AIService();
  final MedicineService _medicineService = MedicineService();
  final DiseaseService _diseaseService = DiseaseService();
  final SessionService _sessionService = SessionService();
  Uint8List? _selectedImageBytes;
  bool _isAnalyzing = false;
  DiseaseDetectionResult? _detectionResult;
  List<MedicineModel> _recommendations = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🖼️ [Disease Detection] Screen initialized');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = imageBytes;
          _detectionResult = null;
          _recommendations = [];
        });
      }
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isAnalyzing = true;
      _detectionResult = null;
      _recommendations = [];
    });

    try {
      final result = await _aiService.detectPlantDisease(_selectedImageBytes!);
      final recommendations = await _medicineService.getSuggestionsForDisease(
        result.diseaseName,
      );

      setState(() {
        _detectionResult = result;
        _recommendations = recommendations;
        _isAnalyzing = false;
      });

      // Save to Firebase
      final user = _sessionService.user;
      if (user != null) {
        final imageBase64 = base64Encode(_selectedImageBytes!);
        await _diseaseService.saveDetection(
          userId: user.id,
          diseaseName: result.diseaseName,
          confidence: result.confidence,
          imageBase64: imageBase64,
        );
      }
    } catch (e) {
      debugPrint('❌ Analysis error: $e');
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Disease Detection',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&q=80&w=1920', // Leaf/Plant closeup
        gradient: AppConstants.primaryGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePickerCard(),
                if (_detectionResult != null) ...[
                  const SizedBox(height: 24),
                  _buildDetectionResult(_detectionResult!),
                  const SizedBox(height: 24),
                  if (_recommendations.isNotEmpty)
                    _buildRecommendationsSection(),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Capture or upload an image of your plant',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              _selectedImageBytes == null
                  ? Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              size: 64,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Pick image to start',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          _selectedImageBytes!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              if (_selectedImageBytes != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedImageBytes = null;
                      _detectionResult = null;
                      _recommendations = [];
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  onPressed: kIsWeb
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: Icons.camera_alt_rounded,
                  label: kIsWeb ? 'Camera N/A' : 'Camera',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionBtn(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                ),
              ),
            ],
          ),
          if (_selectedImageBytes != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      )
                    : const Icon(Icons.psychology_rounded),
                label: Text(
                  _isAnalyzing ? 'ANALYZING...' : 'ANALYZE DISEASE',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(AppConstants.primaryColorValue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionResult(DiseaseDetectionResult result) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'AI ANALYSIS',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Text(
                  '${(result.confidence).toStringAsFixed(1)}% Match',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            result.diseaseName,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.description,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          _buildTreatmentInfo(result.treatment),
        ],
      ),
    );
  }

  Widget _buildTreatmentInfo(String treatment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_services_rounded,
                color: Colors.greenAccent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggested treatment',
                style: GoogleFonts.inter(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            treatment,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Recommended Products',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendations.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final med = _recommendations[index];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 20),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 110,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.medication_liquid_rounded,
                            size: 48,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${med.price}',
                              style: GoogleFonts.outfit(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.store_rounded,
                                  size: 14,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    med.providerName,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Colors.white54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
