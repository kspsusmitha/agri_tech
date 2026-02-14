import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Send a notification to a user
  Future<void> sendNotification(NotificationModel notification) async {
    await _database
        .child('notifications')
        .child(notification.userId) // Ensure we use the userId from the model
        .child(notification.id)
        .set(notification.toJson());
  }

  /// Send notification to all users of a specific role
  Future<void> sendToRole(String role, NotificationModel notification) async {
    try {
      if (role == 'admin') {
        // Hardcoded admin ID as per AuthService
        final adminNotification = notification.copyWith(userId: 'admin_001');
        await sendNotification(adminNotification);
        return;
      }

      // Fetch all users for the role from Realtime DB
      final snapshot = await _database.child('users').child(role).get();
      if (snapshot.exists) {
        final usersData = snapshot.value as Map<dynamic, dynamic>;
        for (var key in usersData.keys) {
          // Key is the userId
          final userNotification = notification.copyWith(
            userId: key.toString(),
          );
          await sendNotification(userNotification);
        }
      }
    } catch (e) {
      debugPrint('❌ [Notification Service] Error sending to role $role: $e');
    }
  }

  /// Stream notifications for a specific user
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _database
        .child('notifications')
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return [];

          return data.entries.map((e) {
            return NotificationModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
            );
          }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
  }

  /// Stream unread count for a user
  Stream<int> streamUnreadCount(String userId) {
    return streamNotifications(
      userId,
    ).map((list) => list.where((n) => !n.isRead).length);
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _database.child('notifications').child(notificationId).update({
      'isRead': true,
    });
  }

  /// Mark all as read for a user
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _database
        .child('notifications')
        .orderByChild('userId')
        .equalTo(userId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final updates = <String, dynamic>{};
      for (var key in data.keys) {
        updates['notifications/$key/isRead'] = true;
      }
      await _database.update(updates);
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _database.child('notifications').child(notificationId).remove();
  }
}
