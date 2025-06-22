import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<String> shoppingItems = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadShoppingList();
  }

  Future<void> loadShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      shoppingItems = prefs.getStringList('shopping_list') ?? [];
    });
  }

  Future<void> saveShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('shopping_list', shoppingItems);
  }

  void addItem(String item) {
    if (item.trim().isEmpty) return;
    setState(() {
      shoppingItems.add(item.trim());
      _controller.clear();
    });
    saveShoppingList();
  }

  void removeItem(int index) {
    setState(() {
      shoppingItems.removeAt(index);
    });
    saveShoppingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC), // pink soft
      appBar: AppBar(
        title: const Text("Daftar Belanja"),
        backgroundColor: const Color.fromARGB(255, 222, 124, 183),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Tambah item belanja...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 242, 144, 203),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => addItem(_controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 235, 154, 202),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Tambah"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: shoppingItems.isEmpty
                  ? const Center(child: Text("Belum ada item belanja."))
                  : ListView.builder(
                      itemCount: shoppingItems.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: const Color(0xFFF8BBD0),
                          child: ListTile(
                            title: Text(shoppingItems[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeItem(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
