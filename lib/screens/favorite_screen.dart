import 'package:flutter/material.dart';
import '../helpers/favorite_helper.dart';
import '../services/api_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> favoriteRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final ids = await FavoriteHelper.getFavorites();
    List<Map<String, dynamic>> recipes = [];

    for (var id in ids) {
      final data = await ApiService.getRecipeDetail(id);
      recipes.add({
        'id': data['id'],
        'title': data['title'],
        'image': data['image'],
      });
    }

    setState(() {
      favoriteRecipes = recipes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC), // pink soft
      appBar: AppBar(
        title: const Text("Resep Favorit Anda"),
        backgroundColor: const Color.fromARGB(255, 222, 124, 183),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteRecipes.isEmpty
              ? const Center(child: Text("Belum ada resep favorit."))
              : ListView.builder(
                  itemCount: favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = favoriteRecipes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: const Color(0xFFF8BBD0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: recipe['id'],
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                recipe['image'] ?? '',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(
                                      height: 180,
                                      child: Center(child: Text('Gambar tidak tersedia')),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                recipe['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
