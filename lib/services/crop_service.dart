import 'package:firebase_database/firebase_database.dart';
import '../models/crop_model.dart';

class CropService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Add a new crop
  Future<void> addCrop(CropModel crop) async {
    await _database.child('crops').child(crop.id).set(crop.toJson());
  }

  /// Update an existing crop
  Future<void> updateCrop(CropModel crop) async {
    await _database.child('crops').child(crop.id).update(crop.toJson());
  }

  /// Delete a crop
  Future<void> deleteCrop(String cropId) async {
    await _database.child('crops').child(cropId).remove();
  }

  /// Stream crops for a specific farmer
  Stream<List<CropModel>> streamFarmerCrops(String farmerId) {
    return _database
        .child('crops')
        .orderByChild('farmerId')
        .equalTo(farmerId)
        .onValue
        .map((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) return [];

          return data.entries.map((e) {
            return CropModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
            );
          }).toList()..sort(
            (a, b) =>
                b.createdAt?.compareTo(a.createdAt ?? DateTime.now()) ?? 0,
          );
        });
  }

  /// Update crop phase
  Future<void> updateCropPhase(String cropId, String phase) async {
    await _database.child('crops').child(cropId).update({'phase': phase});
  }
}
