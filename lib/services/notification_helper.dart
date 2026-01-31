import 'package:flutter/material.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  /// Show a simulated push notification
  void showNotification(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
        backgroundColor: Colors.indigo,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Simulate a weather alert notification
  void triggerWeatherAlert(BuildContext context, String message) {
    showNotification(context, title: 'Weather Alert ⛈️', body: message);
  }

  /// Simulate a crop stage notification
  void triggerCropUpdate(BuildContext context, String cropName, String phase) {
    showNotification(
      context,
      title: 'Crop Status: $cropName',
      body: 'Your crop has entered the $phase phase. Check recommendations!',
    );
  }
}
