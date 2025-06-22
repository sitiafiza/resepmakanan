import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewHelper {
  static const String _key = 'recipe_reviews';

  static Future<void> saveReview(int recipeId, int rating, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    Map<String, List<Map<String, dynamic>>> reviews =
        data != null ? Map<String, List<Map<String, dynamic>>>.from(json.decode(data)) : {};

    final id = recipeId.toString();
    reviews.putIfAbsent(id, () => []);
    reviews[id]!.add({
      'rating': rating,
      'comment': comment,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_key, json.encode(reviews));
  }

  static Future<List<Map<String, dynamic>>> getReviews(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];

    final reviews = Map<String, List<dynamic>>.from(json.decode(data));
    final list = reviews[recipeId.toString()] ?? [];
    return List<Map<String, dynamic>>.from(list);
  }
}
