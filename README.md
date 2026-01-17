# Farm Tech - AI-Powered Agri-Tech Platform

A comprehensive Flutter application that connects farmers, buyers, and administrators through an AI-powered agricultural technology platform.

## Features

### 🤖 AI-Powered Disease Detection
- Analyze plant images using Google Gemini AI
- Get instant disease identification and treatment recommendations
- View confidence levels and detailed descriptions

### 👨‍🌾 Farmer Features
- **Disease Detection**: AI-powered plant disease analysis
- **Crop Management**: Track crops, phases, and get AI-powered advice
- **Product Listing**: List agricultural products for sale
- **Order Management**: Track and manage orders from buyers

### 🛒 Buyer Features
- **Product Browsing**: Browse and search agricultural products
- **Shopping Cart**: Add products to cart and checkout
- **Order Tracking**: Track order status and history

### 👨‍💼 Admin Features
- **User Management**: Manage farmers and buyers
- **Product Approval**: Approve or reject product listings
- **Transaction Management**: Monitor all transactions
- **Complaint Resolution**: Handle user complaints

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Google Gemini API Key ([Get one here](https://ai.google.dev/))

### 2. Install Dependencies

Run the following command to install all required packages:

```bash
flutter pub get
```

### 3. API Key Configuration

The Gemini API key is configured in `lib/utils/constants.dart`:

```dart
static const String apiKey = 'YOUR_API_KEY_HERE';
static const String modelName = 'gemini-flash-lite-latest';
```

**⚠️ Important:** 
- Replace `YOUR_API_KEY_HERE` with your actual Google Gemini API key
- For production apps, use environment variables or secure storage instead of hardcoding
- Get your API key from: https://ai.google.dev/

### 4. Permissions

The app requires the following permissions (already configured):

#### Android (`android/app/src/main/AndroidManifest.xml`):
- `CAMERA` - For taking photos of plants
- `READ_EXTERNAL_STORAGE` - For accessing gallery images
- `READ_MEDIA_IMAGES` - For accessing images on Android 13+

#### iOS (`ios/Runner/Info.plist`):
- `NSCameraUsageDescription` - Camera access for disease detection
- `NSPhotoLibraryUsageDescription` - Photo library access

### 5. Running the App

```bash
# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release

# Build APK for Android
flutter build apk

# Build iOS app
flutter build ios
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── crop_model.dart
│   ├── disease_detection_model.dart
│   ├── order_model.dart
│   ├── product_model.dart
│   └── user_model.dart
├── screens/                     # UI screens
│   ├── role_selection_screen.dart
│   ├── admin/                   # Admin screens
│   ├── farmer/                  # Farmer screens
│   └── buyer/                   # Buyer screens
├── services/                    # Business logic
│   └── ai_service.dart          # Gemini AI integration
└── utils/                       # Utilities
    ├── constants.dart           # App constants & API config
    └── theme.dart               # App theme
```

## Usage Guide

### For Farmers

1. **Disease Detection**:
   - Select "Farmer" role on login
   - Tap "Disease Detection" from dashboard
   - Capture or select a plant image
   - Tap "Analyze Disease" to get AI-powered analysis
   - View disease name, description, treatment, and confidence level

2. **Crop Management**:
   - Add crops with details (type, planting date, phase)
   - Get AI-powered crop management advice
   - Track crop progress through different phases

3. **Product Listing**:
   - List your agricultural products
   - Set prices and descriptions
   - Wait for admin approval

### For Buyers

1. **Browse Products**:
   - Select "Buyer" role on login
   - Browse available products
   - Add items to cart
   - Place orders

2. **Track Orders**:
   - View order history
   - Track order status
   - View delivery details

### For Admins

1. **Manage Users**:
   - View all farmers and buyers
   - Manage user accounts

2. **Approve Products**:
   - Review product listings
   - Approve or reject products

3. **Monitor Transactions**:
   - View all orders and transactions
   - Handle complaints

## API Integration

### Gemini AI Service

The app uses Google's Gemini API for:
- **Plant Disease Detection**: Image analysis using `gemini-flash-lite-latest` model
- **Crop Management Advice**: Text-based AI recommendations

**Service Location**: `lib/services/ai_service.dart`

**Features**:
- Automatic image format conversion (PNG, WebP, etc. → JPEG)
- Error handling with detailed logging
- Quota management and retry logic

## Troubleshooting

### API Errors

- **Quota Exceeded**: 
  - Check your API usage at: https://ai.dev/usage?tab=rate-limit
  - Wait a few minutes and retry
  - Consider upgrading your plan: https://ai.google.dev/pricing

- **Invalid API Key**: 
  - Verify your API key in `lib/utils/constants.dart`
  - Ensure the key is valid and has proper permissions

- **Network Errors**: 
  - Check your internet connection
  - Verify API service status

### Image Picker Issues

- **Permission Denied**: 
  - Grant camera and storage permissions in device settings
  - Restart the app after granting permissions

- **Image Format Errors**: 
  - The app automatically converts images to JPEG
  - Try selecting a different image if issues persist

### Build Issues

- **Dependencies**: Run `flutter pub get` again
- **Clean Build**: Run `flutter clean && flutter pub get`
- **Platform Issues**: Ensure platform-specific setup is complete

## Dependencies

- `flutter` - Flutter SDK
- `google_generative_ai` - Gemini API integration
- `image_picker` - Camera and gallery access
- `image` - Image format conversion
- `provider` - State management
- `http` - HTTP requests
- `intl` - Date formatting

## Development Notes

- The app uses Provider for state management
- All AI features are handled through `AIService` singleton
- Images are automatically converted to JPEG for API compatibility
- Error handling includes detailed logging for debugging

## License

This project is for educational/demonstration purposes.

## Support

For issues related to:
- **Gemini API**: Visit https://ai.google.dev/docs
- **Flutter**: Visit https://docs.flutter.dev
- **Image Picker**: Check package documentation on pub.dev

---

**Note**: Remember to replace the API key with your own before deploying to production!
