import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CommentHelper {
  static Future<void> addComment(int recipeId, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'comments_$recipeId';
    final existing = prefs.getStringList(key) ?? [];
    existing.add(comment);
    await prefs.setStringList(key, existing);
  }

  static Future<List<String>> getComments(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'comments_$recipeId';
    return prefs.getStringList(key) ?? [];
  }
}
