import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:image_picker/image_picker.dart';
import '../../models/disease_detection_result.dart';
import '../../services/medicine_service.dart';
import '../../services/disease_service.dart';
import '../../services/session_service.dart';
import '../../services/medicine_request_service.dart';
import '../../models/medicine_model.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../screens/buyer/product_detail_screen.dart';
import '../../screens/buyer/buyer_cart_screen.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
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

  Future<void> _showDiseaseSelectionDialog() async {
    setState(() => _isAnalyzing = true);

    try {
      // Fetch known diseases from database
      final diseases = await _medicineService.getKnownDiseases();

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      if (diseases.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No disease records found in database.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show selection dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xff1a0b2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Identify Disease',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: diseases.length,
              itemBuilder: (context, index) {
                final disease = diseases[index];
                return ListTile(
                  title: Text(
                    disease,
                    style: GoogleFonts.inter(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white30,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _processSelectedDisease(disease);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ Error fetching diseases: $e');
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _processSelectedDisease(String diseaseName) async {
    setState(() {
      _isAnalyzing = true;
      _detectionResult = null;
      _recommendations = [];
    });

    try {
      // Simulate detection result
      final result = DiseaseDetectionResult(
        diseaseName: diseaseName,
        description:
            'Identified via manual selection based on database records.',
        treatment:
            'Please consult the recommended products below for treatment options.',
        confidence: 100.0,
        productKeywords: [diseaseName],
      );

      // Fetch recommendations based on the selected disease
      final diseaseRecommendations = await _medicineService
          .getSuggestionsForDisease(result.diseaseName);

      setState(() {
        _detectionResult = result;
        _recommendations = diseaseRecommendations;
        _isAnalyzing = false;
      });

      // Save to Firebase (Optional, but keeps history)
      /* 
      // Auto-save disabled
      final user = _sessionService.user;
      if (user != null && _selectedImageBytes != null) {
        final imageBase64 = base64Encode(_selectedImageBytes!);
        await _diseaseService.saveDetection(
          userId: user.id,
          diseaseName: result.diseaseName,
          confidence: result.confidence,
          imageBase64: imageBase64,
        );
      }
      */
    } catch (e) {
      debugPrint('❌ Assessment error: $e');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuyerCartScreen(),
                ),
              );
            },
          ),
        ],
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
                    _buildRecommendationsSection()
                  else
                    Center(
                      child: Text(
                        'No specific products found for this disease.',
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                    ),
                  const SizedBox(height: 32),
                  _buildRequestMedicineSection(),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
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

  Widget _buildRequestMedicineSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.volunteer_activism_rounded,
            color: Colors.orangeAccent,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            "Can't find what you need?",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Request a specific medicine and we'll notify sellers.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showRequestMedicineDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('REQUEST MEDICINE'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRequestMedicineDialog() async {
    final TextEditingController controller = TextEditingController();

    // Pre-fill with disease name if available, or empty
    if (_detectionResult != null) {
      controller.text = "Medicine for ${_detectionResult!.diseaseName}";
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a0b2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Request Medicine',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the name or type of medicine you are looking for:',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., Neem Oil',
                hintStyle: TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final user = _sessionService.user;
                if (user != null) {
                  try {
                    await MedicineRequestService().createRequest(
                      medicineName: controller.text.trim(),
                      requesterId: user.id,
                      requesterName: user.name,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Request sent to sellers!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error sending request: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to send request: $e')),
                      );
                    }
                  }
                }
              }
            },
            child: const Text(
              'SEND REQUEST',
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
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
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _showDiseaseSelectionDialog,
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
                    : const Icon(Icons.search_rounded),
                label: Text(
                  _isAnalyzing ? 'LOADING...' : 'IDENTIFY DISEASE',
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
          const SizedBox(height: 24),
          _buildTreatmentInfo(result.treatment),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveDetection,
              icon: const Icon(Icons.save_alt_rounded),
              label: Text(
                'SAVE RESULT',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDetection() async {
    final user = _sessionService.user;
    if (user != null &&
        _selectedImageBytes != null &&
        _detectionResult != null) {
      try {
        final imageBase64 = base64Encode(_selectedImageBytes!);
        await _diseaseService.saveDetection(
          userId: user.id,
          diseaseName: _detectionResult!.diseaseName,
          confidence: _detectionResult!.confidence,
          imageBase64: imageBase64,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Detection saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save. Missing user or detection data.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
              return GestureDetector(
                onTap: () {
                  final product = ProductModel.fromMedicine(med);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: Container(
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
                          child: Center(
                            child:
                                med.imageUrl != null && med.imageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: Image.network(
                                      med.imageUrl!,
                                      width: double.infinity,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        debugPrint(
                                          'Error loading image for ${med.name}: $error',
                                        );
                                        return const Icon(
                                          Icons.broken_image_rounded,
                                          size: 48,
                                          color: Colors.white38,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
