import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'session_service.dart';
import '../models/notification_model.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final NotificationService _notificationService = NotificationService();
  final String _userId = SessionService().user?.id ?? 'guest';

  /// Show a simulated push notification
  void showNotification(
    BuildContext context, {
    required String title,
    required String body,
    String type = 'general',
    String? relatedId,
  }) {
    // 1. Show SnackBar for immediate feedback
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: 20,
          ),
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

    // 2. Persist to database
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _userId,
      title: title,
      message: body,
      type: type,
      relatedId: relatedId,
      timestamp: DateTime.now(),
    );
    _notificationService.sendNotification(notification);
  }

  /// Simulate a weather alert notification
  void triggerWeatherAlert(BuildContext context, String message) {
    showNotification(
      context,
      title: 'Weather Alert ⛈️',
      body: message,
      type: 'weather',
    );
  }

  /// Simulate a crop stage notification
  void triggerCropUpdate(
    BuildContext context,
    String cropName,
    String phase, {
    String? cropId,
  }) {
    showNotification(
      context,
      title: 'Crop Status: $cropName',
      body: 'Your crop has entered the $phase phase. Check recommendations!',
      type: 'crop',
      relatedId: cropId,
    );
  }
}
