// lib/screens/favorite_screen.dart
import 'package:flutter/material.dart';
import '../helpers/favorite_helper.dart';
import '../services/api_service.dart';
import '../widgets/recipe_card.dart';

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
        title: const Text("Resep Favorit"),
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
                    return RecipeCard(
                      id: recipe['id'],
                      title: recipe['title'],
                      imageUrl: recipe['image'],
                      duration: "Tidak tersedia",
                    );
                  },
                ),
    );
  }
}
