import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/ai_service.dart';

class CropManagementScreen extends StatefulWidget {
  const CropManagementScreen({super.key});

  @override
  State<CropManagementScreen> createState() => _CropManagementScreenState();
}

class _CropManagementScreenState extends State<CropManagementScreen> {
  final AIService _aiService = AIService();
  final List<Map<String, dynamic>> _crops = [];

  @override
  void initState() {
    super.initState();
    // Note: AIService initializes dataset/model automatically in background
    // No need to call initialize() - API removed, using dataset/model only
    // Sample data
    _crops.addAll([
      {
        'id': '1',
        'cropType': 'Tomato',
        'plantingDate': DateTime.now().subtract(const Duration(days: 45)),
        'phase': 'Vegetative',
        'description': 'Tomato crop in vegetative stage',
      },
      {
        'id': '2',
        'cropType': 'Wheat',
        'plantingDate': DateTime.now().subtract(const Duration(days: 60)),
        'phase': 'Flowering',
        'description': 'Wheat crop flowering',
      },
      {
        'id': '3',
        'cropType': 'Corn',
        'plantingDate': DateTime.now().subtract(const Duration(days: 75)),
        'phase': 'Fruiting',
        'description': 'Corn crop fruiting',
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCropDialog,
          ),
        ],
      ),
      body: _crops.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.agriculture, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No crops registered yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddCropDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Crop'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _crops.length,
              itemBuilder: (context, index) {
                final crop = _crops[index];
                return _buildCropCard(crop);
              },
            ),
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    final plantingDate = crop['plantingDate'] as DateTime;
    final daysSincePlanting = DateTime.now().difference(plantingDate).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(
            AppConstants.primaryColorValue,
          ).withOpacity(0.1),
          child: const Icon(
            Icons.eco,
            color: Color(AppConstants.primaryColorValue),
          ),
        ),
        title: Text(
          crop['cropType'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${crop['phase']} • $daysSincePlanting days'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Planting Date',
                  DateFormat('MMM d, y').format(plantingDate),
                ),
                _buildInfoRow('Current Phase', crop['phase']),
                _buildInfoRow('Days Since Planting', '$daysSincePlanting days'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Management Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildScheduleItem(
                  'Fertilizer',
                  'Apply NPK fertilizer',
                  'Every 2 weeks',
                ),
                _buildScheduleItem(
                  'Irrigation',
                  'Water deeply',
                  'Every 3 days',
                ),
                _buildScheduleItem('Pesticide', 'Check for pests', 'Weekly'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _getAIAdvice(crop),
                        icon: const Icon(Icons.psychology),
                        label: const Text('Get AI Advice'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updatePhase(crop),
                        icon: const Icon(Icons.update),
                        label: const Text('Update Phase'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    String title,
    String description,
    String frequency,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(AppConstants.primaryColorValue),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  frequency,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCropDialog() {
    final cropTypeController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedPhase = AppConstants.cropPhases[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Crop'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: cropTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Crop Type',
                    hintText: 'e.g., Tomato, Wheat, Corn',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Planting Date'),
                  subtitle: Text(DateFormat('MMM d, y').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedPhase,
                  decoration: const InputDecoration(
                    labelText: 'Current Phase',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.cropPhases.map((phase) {
                    return DropdownMenuItem(value: phase, child: Text(phase));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPhase = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (cropTypeController.text.isNotEmpty) {
                  setState(() {
                    _crops.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'cropType': cropTypeController.text,
                      'plantingDate': selectedDate,
                      'phase': selectedPhase,
                      'description': descriptionController.text,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Crop added successfully')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _getAIAdvice(Map<String, dynamic> crop) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final plantingDate = crop['plantingDate'] as DateTime;
      final daysSincePlanting = DateTime.now().difference(plantingDate).inDays;

      final advice = await _aiService.getCropManagementAdvice(
        cropType: crop['cropType'],
        phase: crop['phase'],
        daysSincePlanting: daysSincePlanting,
      );

      if (mounted) {
        Navigator.pop(context);
        _showAdviceDialog(advice);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting advice: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAdviceDialog(String advice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Crop Management Advice'),
        content: SingleChildScrollView(child: Text(advice)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updatePhase(Map<String, dynamic> crop) {
    final currentIndex = AppConstants.cropPhases.indexOf(crop['phase']);
    if (currentIndex < AppConstants.cropPhases.length - 1) {
      setState(() {
        crop['phase'] = AppConstants.cropPhases[currentIndex + 1];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Phase updated')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crop is already in final phase')),
      );
    }
  }
}
