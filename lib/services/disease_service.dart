import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class DiseaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String _node = 'disease_detections';

  /// Save a disease detection result
  Future<void> saveDetection({
    required String userId,
    required String diseaseName,
    required double confidence,
    required String imageBase64,
  }) async {
    try {
      await _database.child(_node).push().set({
        'userId': userId,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'imageBase64': imageBase64,
        'timestamp': ServerValue.timestamp,
        'status': 'pending_review',
      });
      debugPrint('✅ [Disease Service] Detection saved to Realtime Database');
    } catch (e) {
      debugPrint('❌ [Disease Service] Save detection error: $e');
      rethrow;
    }
  }

  /// Stream all detections for admin monitoring
  Stream<List<Map<String, dynamic>>> streamAllDetections() {
    return _database.child(_node).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      final List<Map<String, dynamic>> detections = [];
      data.forEach((key, value) {
        final map = Map<String, dynamic>.from(value as Map);

        // Handle timestamp (RTDB stores as ms since epoch)
        DateTime timestamp;
        if (map['timestamp'] != null) {
          if (map['timestamp'] is int) {
            timestamp = DateTime.fromMillisecondsSinceEpoch(
              map['timestamp'] as int,
            );
          } else {
            timestamp = DateTime.now(); // Fallback
          }
        } else {
          timestamp = DateTime.now();
        }

        detections.add({
          ...map,
          'id': key,
          'timestamp': timestamp,
          // Ensure confidence is double
          'confidence': (map['confidence'] as num?)?.toDouble() ?? 0.0,
        });
      });

      // Sort by timestamp descending
      detections.sort((a, b) {
        final tA = a['timestamp'] as DateTime;
        final tB = b['timestamp'] as DateTime;
        return tB.compareTo(tA);
      });

      return detections;
    });
  }

  /// Update detection status (verified/flagged)
  Future<void> updateDetectionStatus(String id, String status) async {
    try {
      await _database.child(_node).child(id).update({'status': status});
    } catch (e) {
      debugPrint('❌ [Disease Service] Update status error: $e');
      rethrow;
    }
  }
}
