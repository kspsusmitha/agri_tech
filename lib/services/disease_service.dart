import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DiseaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'disease_detections';

  /// Save a disease detection result
  Future<void> saveDetection({
    required String userId,
    required String diseaseName,
    required double confidence,
    required String
    imageBase64, // Storing in Firestore as base64 for simplicity in this prototype,
    // but Storage + URL is better for production.
  }) async {
    try {
      await _firestore.collection(_collection).add({
        'userId': userId,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'imageBase64': imageBase64,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending_review', // Admin can review these
      });
      debugPrint('✅ [Disease Service] Detection saved to Firestore');
    } catch (e) {
      debugPrint('❌ [Disease Service] Save detection error: $e');
      rethrow;
    }
  }

  /// Stream all detections for admin monitoring
  Stream<List<Map<String, dynamic>>> streamAllDetections() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              ...data,
              'id': doc.id,
              'timestamp':
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            };
          }).toList();
        });
  }

  /// Update detection status (verified/flagged)
  Future<void> updateDetectionStatus(String id, String status) async {
    await _firestore.collection(_collection).doc(id).update({'status': status});
  }
}
