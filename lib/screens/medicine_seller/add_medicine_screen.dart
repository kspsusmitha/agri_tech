import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../services/medicine_service.dart';
import '../../services/session_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class AddMedicineScreen extends StatefulWidget {
  final MedicineModel? medicine;
  const AddMedicineScreen({super.key, this.medicine});

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
    _nameController = TextEditingController(text: widget.medicine?.name);
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
      _imageBase64 = widget
          .medicine!
          .imageUrl; // Using imageUrl as base64 for consistency with other modules
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);
      });
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
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _imageBase64 != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(_imageBase64!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Product Image',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          [
                                'Fertilizer',
                                'Pesticide',
                                'Fungicide',
                                'Herbicide',
                                'Growth Booster',
                              ]
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetDiseaseController,
                      decoration: const InputDecoration(
                        labelText: 'Target Disease/Problem',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter target' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Enter price' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Instructions for Use',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter instructions' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.medicine == null
                            ? 'Add to Inventory'
                            : 'Save Changes',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
