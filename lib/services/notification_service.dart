import 'package:firebase_database/firebase_database.dart';
import '../models/notification_model.dart';

class NotificationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Send a notification to a user
  Future<void> sendNotification(NotificationModel notification) async {
    await _database
        .child('notifications')
        .child(notification.id)
        .set(notification.toJson());
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
