// Stub file for Firebase ML Model Downloader on web platform
// Firebase ML Model Downloader is not available on web

class CustomModel {
  dynamic file;
}

enum FirebaseModelDownloadType {
  latestModel,
  localModel,
}

class FirebaseModelDownloadConditions {
  final bool iosAllowsCellularAccess;
  final bool iosAllowsBackgroundDownloading;
  final bool androidChargingRequired;
  final bool androidWifiRequired;
  final bool androidDeviceIdleRequired;

  FirebaseModelDownloadConditions({
    required this.iosAllowsCellularAccess,
    required this.iosAllowsBackgroundDownloading,
    required this.androidChargingRequired,
    required this.androidWifiRequired,
    required this.androidDeviceIdleRequired,
  });
}

class FirebaseModelDownloader {
  static final FirebaseModelDownloader instance = FirebaseModelDownloader._();
  FirebaseModelDownloader._();

  Future<CustomModel?> getModel(
    String modelName,
    FirebaseModelDownloadType downloadType,
    FirebaseModelDownloadConditions conditions,
  ) async {
    throw UnsupportedError('Firebase ML Model Downloader is not supported on web platform');
  }
}

