import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';

class MedicineService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch fertilizer/medicine suggestions for a specific disease
  Future<List<MedicineModel>> getSuggestionsForDisease(
    String diseaseName,
  ) async {
    try {
      final snapshot = await _database.child('medicines').get();
      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      final suggestions = <MedicineModel>[];

      data.forEach((key, value) {
        final medicineData = Map<String, dynamic>.from(value);
        if (medicineData['targetDisease'].toString().toLowerCase().contains(
          diseaseName.toLowerCase(),
        )) {
          suggestions.add(MedicineModel.fromJson(medicineData));
        }
      });

      return suggestions;
    } catch (e) {
      debugPrint('❌ [Medicine Service] Error fetching suggestions: $e');
      return [];
    }
  }

  /// Get all medicines available
  Stream<List<MedicineModel>> streamAllMedicines() {
    return _database.child('medicines').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => MedicineModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    });
  }

  /// Get medicines for a specific seller
  Stream<List<MedicineModel>> streamSellerMedicines(String sellerId) {
    return _database.child('medicines').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => MedicineModel.fromJson(Map<String, dynamic>.from(v)))
          .where((m) => m.sellerId == sellerId)
          .toList();
    });
  }

  /// Add a new medicine to both Realtime Database and Firestore
  Future<void> addMedicine(MedicineModel medicine) async {
    try {
      // 1. Save to Realtime Database (Primary Source of Truth for now)
      // Adding a timeout to prevent infinite hanging
      await _database
          .child('medicines')
          .child(medicine.id)
          .set(medicine.toJson())
          .timeout(const Duration(seconds: 10));
      debugPrint('✅ [Medicine Service] Added to Realtime DB: ${medicine.id}');

      // 2. Save to Firestore (Secondary/Backup)
      // We run this effectively in "background" so it doesn't block the UI if it hangs
      _firestore
          .collection('medicines')
          .doc(medicine.id)
          .set(medicine.toJson())
          .then(
            (_) => debugPrint(
              '✅ [Medicine Service] Added to Firestore: ${medicine.id}',
            ),
          )
          .catchError(
            (e) => debugPrint(
              '❌ [Medicine Service] Error adding to Firestore: $e',
            ),
          );
    } catch (e) {
      debugPrint('❌ [Medicine Service] Error adding medicine: $e');
      rethrow; // Rethrow to let UI handle it
    }
  }

  /// Update an existing medicine in both databases
  Future<void> updateMedicine(MedicineModel medicine) async {
    try {
      // 1. Update Realtime Database
      await _database
          .child('medicines')
          .child(medicine.id)
          .update(medicine.toJson())
          .timeout(const Duration(seconds: 10));
      debugPrint('✅ [Medicine Service] Updated in Realtime DB: ${medicine.id}');

      // 2. Update Firestore (Background)
      _firestore
          .collection('medicines')
          .doc(medicine.id)
          .update(medicine.toJson())
          .then(
            (_) => debugPrint(
              '✅ [Medicine Service] Updated in Firestore: ${medicine.id}',
            ),
          )
          .catchError(
            (e) => debugPrint(
              '❌ [Medicine Service] Error updating in Firestore: $e',
            ),
          );
    } catch (e) {
      debugPrint('❌ [Medicine Service] Error updating medicine: $e');
      rethrow;
    }
  }

  /// Delete a medicine from both databases
  Future<void> deleteMedicine(String medicineId) async {
    try {
      // 1. Delete from Realtime Database
      await _database.child('medicines').child(medicineId).remove();
      debugPrint('✅ [Medicine Service] Deleted from Realtime DB: $medicineId');

      // 2. Delete from Firestore
      await _firestore.collection('medicines').doc(medicineId).delete();
      debugPrint('✅ [Medicine Service] Deleted from Firestore: $medicineId');
    } catch (e) {
      debugPrint('❌ [Medicine Service] Error deleting medicine: $e');
      rethrow;
    }
  }
}
