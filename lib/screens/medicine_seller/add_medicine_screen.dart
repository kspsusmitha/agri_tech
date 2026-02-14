import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../services/medicine_service.dart';
import '../../services/session_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../widgets/glass_widgets.dart';
import '../../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMedicineScreen extends StatefulWidget {
  final MedicineModel? medicine;
  final String? initialName;
  const AddMedicineScreen({super.key, this.medicine, this.initialName});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineService = MedicineService();

  late TextEditingController _nameController;
  late TextEditingController _targetDiseaseController;
  late TextEditingController _instructionsController;
  late TextEditingController _priceController;
  String _category = 'Fertilizer';
  String? _imageBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.medicine?.name ?? widget.initialName,
    );
    _targetDiseaseController = TextEditingController(
      text: widget.medicine?.targetDisease,
    );
    _instructionsController = TextEditingController(
      text: widget.medicine?.instructions,
    );
    _priceController = TextEditingController(
      text: widget.medicine?.price.toString(),
    );
    if (widget.medicine != null) {
      _category = widget.medicine!.category;
      _imageBase64 = widget.medicine!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final sellerId = SessionService().user?.id ?? 'guest';
    final medicine = MedicineModel(
      id: widget.medicine?.id ?? 'MED-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      category: _category,
      targetDisease: _targetDiseaseController.text,
      instructions: _instructionsController.text,
      providerName: SessionService().user?.name ?? 'Seller',
      providerUrl: 'internal',
      price: double.parse(_priceController.text),
      imageUrl: _imageBase64,
      sellerId: sellerId,
      createdAt: widget.medicine?.createdAt ?? DateTime.now(),
      status: widget.medicine?.status ?? 'pending',
    );

    try {
      if (widget.medicine == null) {
        await _medicineService.addMedicine(medicine);
      } else {
        await _medicineService.updateMedicine(medicine);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Medicine ${widget.medicine == null ? "added" : "updated"} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.medicine == null ? 'Add Medicine' : 'Edit Medicine',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?auto=format&fit=crop&q=80&w=1920', // Lab/Chemistry
        gradient: AppConstants.purpleGradient,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  kToolbarHeight + 20,
                  16,
                  16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: _imageBase64 != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          base64Decode(_imageBase64!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 40,
                                            color: Colors.white54,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tap to add image',
                                            style: GoogleFonts.inter(
                                              color: Colors.white54,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildGlassTextField(
                              controller: _nameController,
                              label: 'Medicine Name',
                              icon: Icons.medication_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassDropdown(),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              controller: _targetDiseaseController,
                              label: 'Target Disease/Problem',
                              icon: Icons.bug_report_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              controller: _priceController,
                              label: 'Price (₹)',
                              icon: Icons.currency_rupee_rounded,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              controller: _instructionsController,
                              label: 'Instructions for Use',
                              icon: Icons.description_rounded,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purpleAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                widget.medicine == null
                                    ? 'ADD TO INVENTORY'
                                    : 'SAVE CHANGES',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white60, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purpleAccent),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildGlassDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      dropdownColor: const Color(0xff2d1a4e), // Dark purple for dropdown
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: const Icon(
          Icons.category_rounded,
          color: Colors.white60,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        'Fertilizer',
        'Pesticide',
        'Fungicide',
        'Herbicide',
        'Growth Booster',
      ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }
}
