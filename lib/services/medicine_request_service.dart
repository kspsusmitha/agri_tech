import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/medicine_request_model.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class MedicineRequestService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final NotificationService _notificationService = NotificationService();

  /// Create a new medicine request
  Future<void> createRequest({
    required String medicineName,
    required String requesterId,
    required String requesterName,
  }) async {
    try {
      final newRef = _database.child('medicine_requests').push();
      final request = MedicineRequestModel(
        id: newRef.key!,
        medicineName: medicineName,
        requesterId: requesterId,
        requesterName: requesterName,
        createdAt: DateTime.now(),
      );

      await newRef.set(request.toJson());
      debugPrint('✅ [Request Service] Request created: ${request.id}');

      // Notify Admins and Sellers
      await _notifyStakeholders(request);
    } catch (e) {
      debugPrint('❌ [Request Service] Create request error: $e');
      rethrow;
    }
  }

  /// Send notifications to Admins and Medicine Sellers
  Future<void> _notifyStakeholders(MedicineRequestModel request) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Medicine Request',
      message:
          'Farmer ${request.requesterName} is looking for: ${request.medicineName}',
      type: 'order', // Using 'order' type icon for market demands
      timestamp: DateTime.now(),
      userId: '', // Will be set per user in sendToRole
      isRead: false,
    );

    // Notify Admins
    await _notificationService.sendToRole('admin', notification);

    // Notify Medicine Sellers
    await _notificationService.sendToRole('medicine_seller', notification);
  }

  /// Stream all open requests (for Sellers/Admin)
  Stream<List<MedicineRequestModel>> streamOpenRequests() {
    return _database.child('medicine_requests').onValue.map((event) {
      if (!event.snapshot.exists) {
        debugPrint('ℹ️ [Request Service] No requests found in database.');
        return [];
      }

      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        debugPrint('ℹ️ [Request Service] Raw data received: $data');

        final requests = <MedicineRequestModel>[];

        data.forEach((key, value) {
          try {
            final request = MedicineRequestModel.fromJson(
              Map<String, dynamic>.from(value as Map),
            );
            if (request.status == 'open') {
              requests.add(request);
            }
          } catch (e) {
            debugPrint('❌ [Request Service] Error parsing request $key: $e');
          }
        });

        // Sort by newest first
        requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        debugPrint(
          '✅ [Request Service] Parsed ${requests.length} open requests.',
        );
        return requests;
      } catch (e) {
        debugPrint('❌ [Request Service] Error processing stream: $e');
        return [];
      }
    });
  }

  /// Mark request as fulfilled
  Future<void> fulfillRequest(String requestId, String sellerId) async {
    await _database.child('medicine_requests').child(requestId).update({
      'status': 'fulfilled',
      'fulfilledBy': sellerId,
    });
  }
}
