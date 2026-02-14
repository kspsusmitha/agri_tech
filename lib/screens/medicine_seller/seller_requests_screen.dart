import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/medicine_request_model.dart';
import '../../services/medicine_request_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'add_medicine_screen.dart';

class SellerRequestsScreen extends StatelessWidget {
  const SellerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Market Demands',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&q=80&w=1920', // Pharmacy/Lab background
        gradient: AppConstants.secondaryGradient,
        child: StreamBuilder<List<MedicineRequestModel>>(
          stream: MedicineRequestService().streamOpenRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final requests = snapshot.data ?? [];

            if (requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 80,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pending requests',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _buildRequestCard(context, request);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, MedicineRequestModel request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.medicineName,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orangeAccent),
                  ),
                  child: Text(
                    'REQUESTED',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: Colors.white60,
                ),
                const SizedBox(width: 4),
                Text(
                  'Requested by: ${request.requesterName}',
                  style: GoogleFonts.inter(color: Colors.white60),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.white60,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(request.createdAt),
                  style: GoogleFonts.inter(color: Colors.white60),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Add Medicine with pre-filled name?
                  // Or just show dialog saying "Go to Inventory to add this?"
                  _showFulfillOptions(context, request);
                },
                icon: const Icon(Icons.add_box_rounded),
                label: const Text('PROVIDE THIS PRODUCT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFulfillOptions(BuildContext context, MedicineRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff1a0b2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Fulfill Request',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'To fulfill this request, please add "${request.medicineName}" to your inventory.\n\nOnce added and approved by Admin, you can mark this request as fulfilled.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('LATER', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddMedicineScreen(initialName: request.medicineName),
                ),
              );
            },
            child: const Text(
              'ADD MEDICINE',
              style: TextStyle(color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}
