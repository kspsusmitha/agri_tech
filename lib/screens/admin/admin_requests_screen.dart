import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/medicine_request_model.dart';
import '../../services/medicine_request_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Medicine Requests Log',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1554734867-bf3c00a49371?auto=format&fit=crop&q=80&w=1920', // Office/Admin background
        gradient: AppConstants.purpleGradient, // Using Dark Admin theme
        child: StreamBuilder<List<MedicineRequestModel>>(
          // We might want to see ALL requests, not just open ones?
          // For now, reuse streamOpenRequests or create a new streamAllRequests
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
                      'No active requests',
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
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
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
                  'Req: ${request.requesterName}',
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
            // Admin actions could go here (e.g. delete)
          ],
        ),
      ),
    );
  }
}
