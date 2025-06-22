import 'package:flutter/material.dart';
import '../helpers/shopping_list_helper.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  Map<String, List<String>> groupedItems = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await ShoppingListHelper.getGroupedItems();
    setState(() {
      groupedItems = data;
    });
  }

  Future<void> removeItem(String recipeTitle, String item) async {
    await ShoppingListHelper.removeItem(recipeTitle, item);
    await loadData();
  }

  Future<void> removeRecipe(String recipeTitle) async {
    await ShoppingListHelper.removeAllFromRecipe(recipeTitle);
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        title: const Text("Daftar Belanja"),
        backgroundColor: const Color.fromARGB(255, 222, 124, 183),
      ),
      body: groupedItems.isEmpty
          ? const Center(child: Text("Belum ada bahan yang ditambahkan."))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: groupedItems.entries.map((entry) {
                final title = entry.key;
                final items = entry.value;

                return Card(
                  color: const Color(0xFFF8BBD0),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => removeRecipe(title),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...items.map((item) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeItem(title, item),
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
