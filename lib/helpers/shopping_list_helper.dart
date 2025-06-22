import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListHelper {
  static const String _key = 'shopping_list_grouped';

  static Future<Map<String, List<String>>> getGroupedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final Map<String, dynamic> decoded = json.decode(raw);
    return decoded.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  static Future<void> addRecipeIngredients(String recipeTitle, List<String> ingredients) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    Map<String, dynamic> currentData = raw == null ? {} : json.decode(raw);

    if (!currentData.containsKey(recipeTitle)) {
      currentData[recipeTitle] = ingredients;
    } else {
      final existing = List<String>.from(currentData[recipeTitle]);
      for (var item in ingredients) {
        if (!existing.contains(item)) {
          existing.add(item);
        }
      }
      currentData[recipeTitle] = existing;
    }

    await prefs.setString(_key, json.encode(currentData));
  }

  static Future<void> removeItem(String recipeTitle, String item) async {
    final prefs = await SharedPreferences.getInstance();
    final data = await getGroupedItems();
    data[recipeTitle]?.remove(item);
    if (data[recipeTitle]?.isEmpty ?? true) {
      data.remove(recipeTitle);
    }
    await prefs.setString(_key, json.encode(data));
  }

  static Future<void> removeAllFromRecipe(String recipeTitle) async {
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
