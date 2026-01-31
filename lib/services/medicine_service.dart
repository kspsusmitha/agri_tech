import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/medicine_model.dart';

class MedicineService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

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
      debugPrint('❌ [Medicine Service] Error: $e');
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

  /// Add a new medicine
  Future<void> addMedicine(MedicineModel medicine) async {
    await _database
        .child('medicines')
        .child(medicine.id)
        .set(medicine.toJson());
  }

  /// Update an existing medicine
  Future<void> updateMedicine(MedicineModel medicine) async {
    await _database
        .child('medicines')
        .child(medicine.id)
        .update(medicine.toJson());
  }

  /// Delete a medicine
  Future<void> deleteMedicine(String medicineId) async {
    await _database.child('medicines').child(medicineId).remove();
  }
}
