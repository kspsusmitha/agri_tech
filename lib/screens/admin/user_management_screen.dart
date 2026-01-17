import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10, // Placeholder
              itemBuilder: (context, index) {
                return _buildUserCard(
                  name: 'User ${index + 1}',
                  email: 'user${index + 1}@example.com',
                  role: index % 3 == 0
                      ? AppConstants.roleAdmin
                      : index % 3 == 1
                          ? AppConstants.roleFarmer
                          : AppConstants.roleBuyer,
                  phone: '+1234567890',
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
                ButtonSegment(value: 'All', label: Text('All')),
                ButtonSegment(value: 'Farmers', label: Text('Farmers')),
                ButtonSegment(value: 'Buyers', label: Text('Buyers')),
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

  Widget _buildUserCard({
    required String name,
    required String email,
    required String role,
    required String phone,
  }) {
    Color roleColor = role == AppConstants.roleAdmin
        ? Colors.red
        : role == AppConstants.roleFarmer
            ? Colors.green
            : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Icon(
            role == AppConstants.roleAdmin
                ? Icons.admin_panel_settings
                : role == AppConstants.roleFarmer
                    ? Icons.eco
                    : Icons.shopping_cart,
            color: roleColor,
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  phone,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('View Details'),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

