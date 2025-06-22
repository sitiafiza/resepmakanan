import 'package:shared_preferences/shared_preferences.dart';

class FavoriteHelper {
  static const String _key = 'favorite_recipes';

  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    return ids.map((e) => int.parse(e)).toList();
  }

  static Future<void> saveFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFavorites();
    if (!current.contains(id)) {
      current.add(id);
      await prefs.setStringList(_key, current.map((e) => e.toString()).toList());
    }
  }

  static Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFavorites();
    current.remove(id);
    await prefs.setStringList(_key, current.map((e) => e.toString()).toList());
  }

  static Future<bool> isFavorite(int id) async {
    final favorites = await getFavorites();
    return favorites.contains(id);
  }
}
