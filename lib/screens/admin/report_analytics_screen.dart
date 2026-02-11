import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportAnalyticsScreen extends StatelessWidget {
  const ReportAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Intelligence Hub',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&q=80&w=1920', // Data/Analytics
        gradient: AppConstants.purpleGradient,
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 40),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                children: [
                  _buildReportOption(
                    context,
                    'Commercial Analysis',
                    'Detailed review of network transactions and revenue flows.',
                    Icons.insights_rounded,
                  ),
                  _buildReportOption(
                    context,
                    'Inventory Dynamics',
                    'Strategic overview of stock levels and resource availability.',
                    Icons.inventory_2_rounded,
                  ),
                  _buildReportOption(
                    context,
                    'Ecosystem Activity',
                    'In-depth metrics on user engagement and feature adoption.',
                    Icons.groups_3_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.purpleAccent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.download_rounded,
                color: Colors.white54,
                size: 20,
              ),
              color: const Color(0xff1a0b2e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (val) => _showExportFeedback(context, title, val),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'PDF',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PDF',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Excel',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.table_chart_outlined,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Excel',
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExportFeedback(BuildContext context, String report, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $report ($type)...'),
        backgroundColor: Colors.purpleAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
