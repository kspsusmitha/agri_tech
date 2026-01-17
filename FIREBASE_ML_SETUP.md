# Firebase ML Model Downloader Setup Guide

## Overview
Your app is now configured to use Firebase ML Model Downloader for plant disease detection. The app will:
1. **First try** to download the model from Firebase ML
2. **Fallback** to the local model if Firebase download fails

## Setup Steps

### 1. Upload Model to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `plantdisease-e827d`
3. Navigate to **ML Kit** → **Custom Models**
4. Click **Add custom model**
5. Set the model name: `plant_disease_detector` (must match the name in code)
6. Upload your `model_unquant.tflite` file from `assets/models/`
7. Click **Publish**

### 2. Model Configuration

The model name in code is: `plant_disease_detector`

If you want to use a different name, update it in `lib/services/ai_service.dart`:
```dart
static const String _firebaseModelName = 'your_model_name';
```

### 3. How It Works

- **On Mobile/Desktop**: The app tries to download the latest model from Firebase ML. If successful, it uses the Firebase model. If it fails (no internet, model not uploaded, etc.), it falls back to the local model bundled with the app.
- **On Web**: Firebase ML Model Downloader is not supported, so it always uses the local model via `tflite_web`.

### 4. Benefits

✅ **Model Updates**: Update your model in Firebase Console without releasing a new app version
✅ **A/B Testing**: Test different model versions
✅ **Offline Fallback**: Always works with local model if Firebase is unavailable
✅ **No API Keys**: No need for Gemini API keys or quotas

### 5. Testing

1. **Without Firebase Model**: The app will use the local model (current behavior)
2. **With Firebase Model**: After uploading to Firebase Console, the app will download and use the Firebase model on first run

### 6. Troubleshooting

- **Model not downloading**: Check that the model name matches exactly
- **Fallback to local**: This is expected behavior if Firebase model is not available
- **Web platform**: Always uses local model (Firebase ML not supported on web)

## Current Implementation

The AI service (`lib/services/ai_service.dart`) has been updated to:
- Try Firebase ML Model Downloader first
- Fallback to local model automatically
- Work on all platforms (mobile, desktop, web)

## Next Steps

1. Upload your model to Firebase Console
2. Test the app - it should download the model automatically
3. Update the model in Firebase Console anytime to push updates to users

