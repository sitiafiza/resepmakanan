import 'package:flutter/material.dart';
import '../helpers/shopping_list_helper.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  Map<String, List<Map<String, dynamic>>> groupedItems = {};

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final items = await ShoppingListHelper.getGroupedItems();
    setState(() {
      groupedItems = items;
    });
  }

  Future<void> toggleBought(String recipeTitle, String itemName) async {
    await ShoppingListHelper.toggleBought(recipeTitle, itemName);
    await loadItems();
  }

  Future<void> removeRecipe(String recipeTitle) async {
    await ShoppingListHelper.removeRecipe(recipeTitle);
    await loadItems();
  }

  Future<void> clearAll() async {
    await ShoppingListHelper.clearAll();
    await loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text("Daftar Belanja"),
        backgroundColor: const Color.fromARGB(255, 222, 124, 183),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearAll,
          ),
        ],
      ),
      body: groupedItems.isEmpty
          ? const Center(child: Text("Belum ada bahan belanja."))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: groupedItems.entries.map((entry) {
                final recipeTitle = entry.key;
                final ingredients = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header nama resep + ikon hapus
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 242, 144, 203),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recipeTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => removeRecipe(recipeTitle),
                          ),
                        ],
                      ),
                    ),
                    // List bahan
                    ...ingredients.map((ingredient) {
                      final itemName = ingredient['name'];
                      final bought = ingredient['bought'] == true;
                      return Card(
                        color: const Color(0xFFF8BBD0),
                        child: ListTile(
                          title: Text(
                            itemName,
                            style: TextStyle(
                              decoration: bought
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: bought ? Colors.grey : Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              bought
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: bought ? Colors.green : Colors.grey,
                            ),
                            onPressed: () => toggleBought(recipeTitle, itemName),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
