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

  /// Fetch fertilizer/medicine suggestions for a list of keywords
  Future<List<MedicineModel>> getSuggestionsForKeywords(
    List<String> keywords,
  ) async {
    try {
      if (keywords.isEmpty) return [];

      final snapshot = await _database.child('medicines').get();
      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      final suggestions = <MedicineModel>[];
      final seenIds = <String>{};

      data.forEach((key, value) {
        final medicineData = Map<String, dynamic>.from(value);
        final medicine = MedicineModel.fromJson(medicineData);

        // Check if medicine matches any keyword
        for (final keyword in keywords) {
          final k = keyword.toLowerCase();
          if (medicine.name.toLowerCase().contains(k) ||
              medicine.category.toLowerCase().contains(k) ||
              medicine.targetDisease.toLowerCase().contains(k) ||
              medicine.instructions.toLowerCase().contains(k)) {
            if (!seenIds.contains(medicine.id)) {
              suggestions.add(medicine);
              seenIds.add(medicine.id);
            }
            break; // Found a match, move to next medicine
          }
        }
      });

      return suggestions;
    } catch (e) {
      debugPrint(
        '❌ [Medicine Service] Error fetching suggestions by keywords: $e',
      );
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
      final medicines = data.values
          .map((v) => MedicineModel.fromJson(Map<String, dynamic>.from(v)))
          .where((m) => m.sellerId == sellerId)
          .toList();
      // Sort by newest first
      medicines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return medicines;
    });
  }

  /// Get approved medicines (for farmers/buyers)
  Stream<List<MedicineModel>> streamApprovedMedicines() {
    return _database.child('medicines').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final medicines = data.values
          .map((v) => MedicineModel.fromJson(Map<String, dynamic>.from(v)))
          .where((m) => m.status == 'approved')
          .toList();
      // Sort by newest first
      medicines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return medicines;
    });
  }

  /// Get list of unique diseases from existing medicines
  Future<List<String>> getKnownDiseases() async {
    try {
      final snapshot = await _database.child('medicines').get();
      if (!snapshot.exists) return [];

      final data = snapshot.value as Map<dynamic, dynamic>;
      final diseases = <String>{};

      data.forEach((key, value) {
        final medicineData = Map<String, dynamic>.from(value);
        if (medicineData.containsKey('targetDisease')) {
          final disease = medicineData['targetDisease'] as String;
          if (disease.isNotEmpty) {
            diseases.add(disease);
          }
        }
      });

      final sortedList = diseases.toList()..sort();
      return sortedList;
    } catch (e) {
      debugPrint('❌ [Medicine Service] Error fetching known diseases: $e');
      return [];
    }
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

  /// Update medicine status (Approved/Rejected)
  Future<void> updateMedicineStatus(String medicineId, String status) async {
    try {
      // 1. Update in Realtime Database
      await _database.child('medicines').child(medicineId).update({
        'status': status,
      });
      debugPrint(
        '✅ [Medicine Service] Status updated to $status in Realtime DB: $medicineId',
      );

      // 2. Update in Firestore
      _firestore
          .collection('medicines')
          .doc(medicineId)
          .update({'status': status})
          .catchError(
            (e) => debugPrint(
              '❌ [Medicine Service] Firestore status update error: $e',
            ),
          );
    } catch (e) {
      debugPrint('❌ [Medicine Service] Error updating status: $e');
      rethrow;
    }
  }
}
