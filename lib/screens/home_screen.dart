import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/recipe_card.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> recipes = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;

  void searchRecipe() async {
    setState(() => isLoading = true);
    try {
      final results = await ApiService.searchRecipes(_searchController.text);
      setState(() {
        recipes = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resep Masakan"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari resep...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: searchRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Cari"),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Hasil pencarian
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recipes.isEmpty
                      ? const Center(child: Text("Belum ada resep"))
                      : ListView.builder(
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return RecipeCard(
                              id: recipe['id'],
                              title: recipe['title'],
                              imageUrl: recipe['image'],
                              duration: "Tidak tersedia",
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
