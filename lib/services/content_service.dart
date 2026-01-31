import 'package:firebase_database/firebase_database.dart';

class ContentService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Stream all fertilizer types
  Stream<List<Map<String, dynamic>>> streamFertilizers() {
    return _database.child('fertilizers').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value as Map);
        return {...val, 'id': e.key};
      }).toList();
    });
  }

  /// Add or update fertilizer
  Future<void> saveFertilizer(Map<String, dynamic> fertilizer) async {
    final id = fertilizer['id'] ?? _database.child('fertilizers').push().key;
    await _database.child('fertilizers').child(id).set(fertilizer);
  }

  /// Delete fertilizer
  Future<void> deleteFertilizer(String id) async {
    await _database.child('fertilizers').child(id).remove();
  }

  /// Stream crop lifecycles
  Stream<List<Map<String, dynamic>>> streamCropLifecycles() {
    return _database.child('crop_lifecycles').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value as Map);
        return {...val, 'id': e.key};
      }).toList();
    });
  }

  /// Save crop lifecycle stage
  Future<void> saveCropLifecycle(Map<String, dynamic> lifecycle) async {
    final id = lifecycle['id'] ?? _database.child('crop_lifecycles').push().key;
    await _database.child('crop_lifecycles').child(id).set(lifecycle);
  }
}
