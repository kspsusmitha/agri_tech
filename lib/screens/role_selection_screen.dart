import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/glass_widgets.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&q=80&w=1920',
        gradient: AppConstants.primaryGradient,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Animated Logo Area
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Farm Tech',
                style: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Empowering Agriculture with AI',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 60),

              // Role Cards with Glassmorphism
              _buildGlassRoleCard(
                context,
                title: 'Administrator',
                icon: Icons.admin_panel_settings_rounded,
                description: 'Full system oversight & management',
                gradient: AppConstants.oceanGradient,
                onTap: () => _navigateToLogin(context, 'admin'),
              ),
              const SizedBox(height: 20),
              _buildGlassRoleCard(
                context,
                title: 'Farmer',
                icon: Icons.eco_rounded,
                description: 'Crop management & disease insights',
                gradient: AppConstants.primaryGradient,
                onTap: () => _showFarmerOptions(context),
              ),
              const SizedBox(height: 20),
              _buildGlassRoleCard(
                context,
                title: 'Direct Buyer',
                icon: Icons.shopping_basket_rounded,
                description: 'Purchase fresh produce directly',
                gradient: AppConstants.sunsetGradient,
                onTap: () => _showBuyerOptions(context),
              ),
              const SizedBox(height: 20),
              _buildGlassRoleCard(
                context,
                title: 'Medicine Seller',
                icon: Icons.medical_services_rounded,
                description: 'Commercial supplier marketplace',
                gradient: AppConstants.purpleGradient,
                onTap: () => _showMedicineSellerOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassRoleCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      borderRadius: 24,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(selectedRole: role)),
    );
  }

  void _showFarmerOptions(BuildContext context) {
    _showGlassOptions(
      context,
      title: 'Farmer Access',
      role: 'farmer',
      gradient: AppConstants.primaryGradient,
    );
  }

  void _showBuyerOptions(BuildContext context) {
    _showGlassOptions(
      context,
      title: 'Buyer Access',
      role: 'buyer',
      gradient: AppConstants.sunsetGradient,
    );
  }

  void _showMedicineSellerOptions(BuildContext context) {
    _showGlassOptions(
      context,
      title: 'Seller Access',
      role: 'medicine_seller',
      gradient: AppConstants.purpleGradient,
    );
  }

  void _showGlassOptions(
    BuildContext context, {
    required String title,
    required String role,
    required List<Color> gradient,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: 30,
        color: Colors.black54,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              _buildOptionButton(
                context,
                'Login to Account',
                Icons.login_rounded,
                gradient,
                () {
                  Navigator.pop(context);
                  _navigateToLogin(context, role);
                },
              ),
              const SizedBox(height: 16),
              _buildOptionButton(
                context,
                'Register New User',
                Icons.person_add_rounded,
                [Colors.white24, Colors.white10],
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RegistrationScreen(selectedRole: role),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String text,
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
