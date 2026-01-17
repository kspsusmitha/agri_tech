import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String _selectedFilter = 'Pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints Management'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // Placeholder
              itemBuilder: (context, index) {
                return _buildComplaintCard(
                  id: 'COMP-${100 + index}',
                  title: 'Complaint ${index + 1}',
                  description:
                      'This is a sample complaint description. User is reporting an issue with product quality or delivery.',
                  userName: 'User ${index + 1}',
                  userRole: index % 2 == 0
                      ? AppConstants.roleFarmer
                      : AppConstants.roleBuyer,
                  status: _selectedFilter.toLowerCase(),
                  date: DateTime.now().subtract(Duration(days: index)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Pending', label: Text('Pending')),
                ButtonSegment(value: 'Resolved', label: Text('Resolved')),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedFilter = newSelection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard({
    required String id,
    required String title,
    required String description,
    required String userName,
    required String userRole,
    required String status,
    required DateTime date,
  }) {
    Color roleColor = userRole == AppConstants.roleFarmer
        ? Colors.green
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == 'resolved'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: status == 'resolved' ? Colors.green : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    userRole.toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showResolutionDialog(context, id, title);
                  },
                  child: const Text('Resolve Complaint'),
                ),
              ),
            ],
            if (status == 'resolved') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Resolution: Issue has been addressed and resolved.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showResolutionDialog(
    BuildContext context,
    String complaintId,
    String title,
  ) {
    final resolutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complaint: $title'),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution Details',
                hintText: 'Enter how you resolved this complaint...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complaint resolved successfully'),
                ),
              );
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}

