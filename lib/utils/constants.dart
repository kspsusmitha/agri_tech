import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String apiKey = 'AIzaSyChcxUCymMoKzf9ckJNJMRgw_oAlTPnYCs';
  // Using gemini-1.5-pro which supports vision (image analysis)
  // Try these models if one doesn't work:
  // - 'gemini-1.5-pro' (recommended for vision)
  // - 'gemini-1.5-flash' (faster, lighter)
  // - 'gemini-pro' (older, text only - won't work for images)
  // - 'gemini-pro-vision' (deprecated, may not work)
  static const String modelName = 'gemini-1.5-pro';

  // App Colors
  static const int primaryColorValue = 0xFF1B5E20; // Deep Green
  static const int secondaryColorValue = 0xFF43A047;
  static const int accentColorValue = 0xFF00C853;

  // Premium Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF1B5E20),
    Color(0xFF43A047),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF81C784),
  ];
  static const List<Color> oceanGradient = [
    Color(0xFF0D47A1),
    Color(0xFF42A5F5),
  ];
  static const List<Color> purpleGradient = [
    Color(0xFF4A148C),
    Color(0xFFAB47BC),
  ];
  static const List<Color> sunsetGradient = [
    Color(0xFFE65100),
    Color(0xFFFFB74D),
  ];
  static const List<Color> deepBlueGradient = [
    Color(0xFF0D1B2A),
    Color(0xFF1B263B),
  ];

  // Glassmorphism Constants
  static const double glassBlur = 10.0;
  static const double glassOpacity = 0.2;
  static const Color glassBorderColor = Color(0x33FFFFFF);

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleFarmer = 'farmer';
  static const String roleBuyer = 'buyer';

  // Crop Phases
  static const List<String> cropPhases = [
    'Planting',
    'Germination',
    'Vegetative',
    'Flowering',
    'Fruiting',
    'Harvesting',
  ];

  // Order Status
  static const String orderPending = 'pending';
  static const String orderApproved = 'approved';
  static const String orderProcessing = 'processing';
  static const String orderShipped = 'shipped';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Product Status
  static const String productPending = 'pending';
  static const String productApproved = 'approved';
  static const String productRejected = 'rejected';
}
