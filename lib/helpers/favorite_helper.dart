import 'package:shared_preferences/shared_preferences.dart';

class FavoriteHelper {
  static const String key = 'favorite_recipes';

  static Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key)?.map(int.parse).toList() ?? [];
  }

  static Future<void> saveFavorite(int recipeId) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> favorites = prefs.getStringList('favorites') ?? [];
  if (!favorites.contains(recipeId.toString())) {
    favorites.add(recipeId.toString());
    await prefs.setStringList('favorites', favorites);
  }
}
  static Future<void> removeFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();
    favs.remove(id);
    await prefs.setStringList(key, favs.map((e) => e.toString()).toList());
  }

  static Future<bool> isFavorite(int id) async {
    final favs = await getFavorites();
    return favs.contains(id);
  }
}
