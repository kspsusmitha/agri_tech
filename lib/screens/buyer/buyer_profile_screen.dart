import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/session_service.dart';

import '../../widgets/glass_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import '../role_selection_screen.dart';
import 'buyer_orders_screen.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final SessionService _sessionService = SessionService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _user = _sessionService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    // If used inside IndexedStack, we might need a Scaffold or just content.
    // Dashboard provides the background, so we just return the content.
    // However, if we want a separate scrolling view, we can use a Column/ListView.

    // Note: The Dashboard handles the background.

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: kToolbarHeight + 40, bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      gradient: LinearGradient(
                        colors: [Colors.white24, Colors.white10],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _user?.name.isNotEmpty == true
                            ? _user!.name[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.name ?? 'Guest User',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _user?.email ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildProfileTile(
                      icon: Icons.receipt_long_rounded,
                      title: 'My Orders',
                      subtitle: 'Track your purchases',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BuyerOrdersScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildProfileTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Update your information',
                      onTap: () {
                        // TODO: Implement Edit Profile
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildProfileTile(
                      icon: Icons.location_on_outlined,
                      title: 'Shipping Address',
                      subtitle: _user?.address ?? 'Add address',
                      onTap: () {
                        // TODO: Implement Address Management
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProfileTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                isDestructive: true,
                onTap: () => _showLogoutDialog(context),
                asGlassCard: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool asGlassCard = false,
  }) {
    final tileContent = ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.redAccent.withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: onTap,
    );

    if (asGlassCard) {
      return GlassContainer(
        borderRadius: 24,
        padding: EdgeInsets.zero,
        child: tileContent,
      );
    }

    return tileContent;
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.1), height: 1, indent: 60);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff1a3a2a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Logout', style: GoogleFonts.outfit(color: Colors.white)),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _sessionService.clearUser();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
