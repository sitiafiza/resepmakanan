import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListHelper {
  static const String _key = 'shopping_list_grouped';

  static Future<Map<String, List<Map<String, dynamic>>>> getGroupedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final Map<String, dynamic> decoded = json.decode(raw);

    // Konversi ke Map<String, List<Map<String, dynamic>>>
    return decoded.map((key, value) {
      final items = List<Map<String, dynamic>>.from(
        (value as List).map((item) {
          if (item is String) {
            return {"name": item, "bought": false}; // Versi lama
          } else {
            return Map<String, dynamic>.from(item); // Versi baru
          }
        }),
      );
      return MapEntry(key, items);
    });
  }

  static Future<void> addRecipeIngredients(String recipeTitle, List<String> ingredients) async {
    final prefs = await SharedPreferences.getInstance();
    final data = await getGroupedItems();

    final existing = data[recipeTitle] ?? [];
    for (var ing in ingredients) {
      if (!existing.any((item) => item["name"] == ing)) {
        existing.add({"name": ing, "bought": false});
      }
    }

    data[recipeTitle] = existing;
    await prefs.setString(_key, json.encode(data));
  }

  static Future<void> toggleBought(String recipeTitle, String itemName) async {
    final prefs = await SharedPreferences.getInstance();
    final data = await getGroupedItems();

    final items = data[recipeTitle];
    if (items != null) {
      for (var item in items) {
        if (item["name"] == itemName) {
          item["bought"] = !(item["bought"] ?? false);
        }
      }
      data[recipeTitle] = items;
      await prefs.setString(_key, json.encode(data));
    }
  }

  static Future<void> removeRecipe(String recipeTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final data = await getGroupedItems();
    data.remove(recipeTitle);
    await prefs.setString(_key, json.encode(data));
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
