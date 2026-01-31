import 'package:flutter/material.dart';
import '../../services/disease_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DiseaseMonitoringScreen extends StatefulWidget {
  const DiseaseMonitoringScreen({super.key});

  @override
  State<DiseaseMonitoringScreen> createState() =>
      _DiseaseMonitoringScreenState();
}

class _DiseaseMonitoringScreenState extends State<DiseaseMonitoringScreen> {
  final DiseaseService _diseaseService = DiseaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Disease Monitoring',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        colors: AppConstants.purpleGradient,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _diseaseService.streamAllDetections(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white24),
                    );
                  }
                  final detections = snapshot.data ?? [];
                  if (detections.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: detections.length,
                    itemBuilder: (context, index) {
                      final detection = detections[index];
                      return _buildDetectionCard(detection);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 80,
            color: Colors.white10,
          ),
          const SizedBox(height: 20),
          Text(
            'No disease detections found',
            style: GoogleFonts.inter(color: Colors.white30, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionCard(Map<String, dynamic> detection) {
    final date = detection['timestamp'] as DateTime;
    final imageBytes = base64Decode(detection['imageBase64']);
    final status = detection['status'] ?? 'pending';
    final confidence = (detection['confidence'] as double);

    Color statusColor = status == 'verified'
        ? Colors.greenAccent
        : status == 'flagged'
        ? Colors.orangeAccent
        : Colors.lightBlueAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    imageBytes,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detection['diseaseName'],
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Confidence: ${confidence.toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          color: confidence > 80
                              ? Colors.greenAccent
                              : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM d, y • h:mm a').format(date),
                        style: GoogleFonts.inter(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(status, statusColor),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _diseaseService.updateDetectionStatus(
                      detection['id'],
                      'verified',
                    ),
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                    ),
                    label: const Text('VERIFY'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.withOpacity(0.15),
                      foregroundColor: Colors.greenAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _diseaseService.updateDetectionStatus(
                      detection['id'],
                      'flagged',
                    ),
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('FLAG'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orangeAccent,
                      side: const BorderSide(color: Colors.orangeAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildStatusIndicator(String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == 'verified'
            ? Icons.verified_user_rounded
            : status == 'flagged'
            ? Icons.report_problem_rounded
            : Icons.pending_rounded,
        color: color,
        size: 20,
      ),
    );
  }
}
