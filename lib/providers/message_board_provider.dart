import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/message_post.dart';

class MessageBoardProvider extends ChangeNotifier {
  List<MessagePost> _posts = [];
  List<MessagePost> get posts => _posts;

  int get postCount => _posts.length;

  final _uuid = const Uuid();

  Future<void> loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('message_posts');
    if (data != null) {
      final list = jsonDecode(data) as List;
      _posts = list.map((e) => MessagePost.fromJson(e)).toList();
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Future<void> savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_posts.map((e) => e.toJson()).toList());
    await prefs.setString('message_posts', data);
  }

  Future<String> addPost(MessagePost post) async {
    _posts.insert(0, post);
    _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await savePosts();
    notifyListeners();
    return post.id;
  }

  Future<void> updatePost(MessagePost post) async {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = post;
      await savePosts();
      notifyListeners();
    }
  }

  Future<void> deletePost(String id) async {
    _posts.removeWhere((p) => p.id == id);
    await savePosts();
    notifyListeners();
  }

  Future<void> likePost(String postId, String userId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final likes = List<String>.from(post.likes);
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      _posts[index] = MessagePost(
        id: post.id,
        userId: post.userId,
        content: post.content,
        stickerColor: post.stickerColor,
        mood: post.mood,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt,
        likes: likes,
        replies: post.replies,
      );
      await savePosts();
      notifyListeners();
    }
  }

  Future<String> addReply(String postId, MessageReply reply) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final replies = List<MessageReply>.from(post.replies)..add(reply);
      _posts[index] = MessagePost(
        id: post.id,
        userId: post.userId,
        content: post.content,
        stickerColor: post.stickerColor,
        mood: post.mood,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt,
        likes: post.likes,
        replies: replies,
      );
      await savePosts();
      notifyListeners();
    }
    return reply.id;
  }

  Future<void> deleteReply(String postId, String replyId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final replies =
          List<MessageReply>.from(post.replies)..removeWhere((r) => r.id == replyId);
      _posts[index] = MessagePost(
        id: post.id,
        userId: post.userId,
        content: post.content,
        stickerColor: post.stickerColor,
        mood: post.mood,
        imageUrl: post.imageUrl,
        createdAt: post.createdAt,
        likes: post.likes,
        replies: replies,
      );
      await savePosts();
      notifyListeners();
    }
  }
}
