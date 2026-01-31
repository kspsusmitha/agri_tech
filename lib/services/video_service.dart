import 'package:firebase_database/firebase_database.dart';
import '../models/video_model.dart';

class VideoService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Stream all training videos
  Stream<List<VideoModel>> streamVideos() {
    return _database.child('training_videos').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => VideoModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    });
  }

  /// Get videos by category
  Stream<List<VideoModel>> streamVideosByCategory(String category) {
    return streamVideos().map((videos) {
      return videos.where((v) => v.category == category).toList();
    });
  }

  /// Note: Only Admins can upload videos normally, but for demo we might need to populate RTDB
}
