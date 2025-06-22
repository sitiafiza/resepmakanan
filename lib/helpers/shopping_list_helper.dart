import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListHelper {
  static const String _key = 'shopping_list';

  static Future<List<String>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addItem(String item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    if (!items.contains(item)) {
      items.add(item);
      await prefs.setStringList(_key, items);
    }
  }

  static Future<void> removeItem(String item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? [];
    items.remove(item);
    await prefs.setStringList(_key, items);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
