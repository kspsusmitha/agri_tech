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
  static const int primaryColorValue = 0xFF2E7D32; // Green
  static const int secondaryColorValue = 0xFF66BB6A;
  static const int accentColorValue = 0xFF4CAF50;

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
