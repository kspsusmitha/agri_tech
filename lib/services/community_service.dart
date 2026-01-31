import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';

class CommunityService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Create a new community post
  Future<void> createPost(PostModel post) async {
    try {
      await _database.child('community').child(post.id).set(post.toJson());
      debugPrint('✅ [Community Service] Post created: ${post.id}');
    } catch (e) {
      debugPrint('❌ [Community Service] Create post error: $e');
      rethrow;
    }
  }

  /// Stream all posts (real-time updates)
  Stream<List<PostModel>> streamPosts() {
    return _database.child('community').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final posts = data.values
          .map((v) => PostModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  /// Like/Unlike a post
  Future<void> toggleLike(String postId, String userId) async {
    final ref = _database.child('community').child(postId).child('likes');
    final snapshot = await ref.get();

    List<String> likes = [];
    if (snapshot.exists) {
      likes = List<String>.from(snapshot.value as List);
    }

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await ref.set(likes);
  }

  /// Add a reply to a post
  Future<void> addReply(String postId, Map<String, dynamic> reply) async {
    final ref = _database.child('community').child(postId).child('replies');
    final snapshot = await ref.get();

    List<dynamic> replies = [];
    if (snapshot.exists) {
      replies = List<dynamic>.from(snapshot.value as List);
    }

    replies.add({...reply, 'createdAt': DateTime.now().toIso8601String()});

    await ref.set(replies);
  }

  /// Get posts by category (e.g., Land Posting)
  Stream<List<PostModel>> streamPostsByCategory(String category) {
    return streamPosts().map(
      (posts) => posts.where((p) => p.category == category).toList(),
    );
  }

  /// Delete a post (Admin moderation)
  Future<void> deletePost(String postId) async {
    try {
      await _database.child('community').child(postId).remove();
      debugPrint('✅ [Community Service] Post deleted: $postId');
    } catch (e) {
      debugPrint('❌ [Community Service] Delete post error: $e');
      rethrow;
    }
  }
}
