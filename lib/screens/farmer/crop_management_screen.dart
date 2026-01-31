import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/ai_service.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Crop Management',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: _showAddCropDialog,
          ),
        ],
      ),
      body: GradientBackground(
        colors: AppConstants.primaryGradient,
        child: SafeArea(
          child: _crops.isEmpty
              ? Center(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.agriculture_rounded,
                          size: 80,
                          color: Colors.white30,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No crops registered yet',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddCropDialog,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('ADD YOUR FIRST CROP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(
                              AppConstants.primaryColorValue,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _crops.length,
                  itemBuilder: (context, index) {
                    final crop = _crops[index];
                    return _buildCropCard(crop);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildCropCard(Map<String, dynamic> crop) {
    final plantingDate = crop['plantingDate'] as DateTime;
    final daysSincePlanting = DateTime.now().difference(plantingDate).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white),
            ),
            title: Text(
              crop['cropType'],
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              '${crop['phase']} • $daysSincePlanting days old',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Planting Date',
                      DateFormat('MMM d, y').format(plantingDate),
                    ),
                    _buildInfoRow('Current Phase', crop['phase']),
                    _buildInfoRow(
                      'Harvest Progress',
                      '${(daysSincePlanting / 90 * 100).clamp(0, 100).toInt()}%',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Management Schedule',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildScheduleItem(
                      Icons.opacity_rounded,
                      'Irrigation',
                      'Deep watering required',
                      'Every 3 days',
                    ),
                    _buildScheduleItem(
                      Icons.science_rounded,
                      'Fertilizer',
                      'Apply NPK complex',
                      'Bi-weekly',
                    ),
                    _buildScheduleItem(
                      Icons.bug_report_rounded,
                      'Pest Watch',
                      'Full inspection',
                      'Weekly',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _getAIAdvice(crop),
                            icon: const Icon(
                              Icons.psychology_rounded,
                              size: 20,
                            ),
                            label: Text(
                              'AI ADVICE',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _updatePhase(crop),
                            icon: const Icon(Icons.upgrade_rounded, size: 20),
                            label: Text(
                              'NEXT PHASE',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(
                                AppConstants.primaryColorValue,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
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
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    IconData icon,
    String title,
    String description,
    String frequency,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            frequency,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w500,
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
          backgroundColor: const Color(0xff1a3a2a), // Dark green theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Add New Crop',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(
                  cropTypeController,
                  'Crop Type',
                  'e.g. Tomato',
                ),
                const SizedBox(height: 16),
                _buildDialogDatePicker(context, selectedDate, (date) {
                  setState(() => selectedDate = date);
                }),
                const SizedBox(height: 16),
                _buildDialogDropdown(selectedPhase, (val) {
                  setState(() => selectedPhase = val!);
                }),
                const SizedBox(height: 16),
                _buildDialogField(
                  descriptionController,
                  'Description',
                  'Notes...',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                if (cropTypeController.text.isNotEmpty) {
                  this.setState(() {
                    _crops.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'cropType': cropTypeController.text,
                      'plantingDate': selectedDate,
                      'phase': selectedPhase,
                      'description': descriptionController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('ADD CROP'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildDialogDatePicker(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        title: const Text(
          'Planting Date',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        subtitle: Text(
          DateFormat('MMM d, y').format(selectedDate),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.calendar_today_rounded,
          color: Colors.white70,
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (date != null) onDateSelected(date);
        },
      ),
    );
  }

  Widget _buildDialogDropdown(String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xff1a3a2a),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Current Phase',
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white38),
        ),
      ),
      items: AppConstants.cropPhases.map((phase) {
        return DropdownMenuItem(value: phase, child: Text(phase));
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _getAIAdvice(Map<String, dynamic> crop) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
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
            content: Text('Error: ${e.toString()}'),
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
        backgroundColor: const Color(0xff1a3a2a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'AI Advice',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            advice,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT', style: TextStyle(color: Colors.white)),
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
    }
  }
}
