import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:translator/translator.dart';

import '../services/api_service.dart';
import '../helpers/favorite_helper.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  bool isLoading = true;
  bool isFavorite = false;
  List<String> translatedIngredients = [];
  String translatedInstructions = '';

  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    loadRecipe();
    checkFavorite();
  }

  Future<void> loadRecipe() async {
    try {
      final data = await ApiService.getRecipeDetail(widget.recipeId);

      // Translate ingredients
      final ingredients = (data['extendedIngredients'] as List)
          .map((item) => item['original'].toString())
          .toList();

      final translatedIng = await Future.wait(
        ingredients.map((ing) async {
          final result = await translator.translate(ing, to: 'id');
          return result.text;
        }),
      );

      // Translate instructions
      final instructionsRaw = data['instructions'] ?? '';
      final translatedInstr = instructionsRaw.isNotEmpty
          ? (await translator.translate(instructionsRaw, to: 'id')).text
          : 'Instruksi tidak tersedia.';

      setState(() {
        recipe = data;
        translatedIngredients = translatedIng;
        translatedInstructions = translatedInstr;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail resep: $e')),
      );
    }
  }

  Future<void> checkFavorite() async {
    final favs = await FavoriteHelper.getFavorites();
    setState(() {
      isFavorite = favs.contains(widget.recipeId);
    });
  }

  Future<void> toggleFavorite() async {
    if (isFavorite) {
      await FavoriteHelper.removeFavorite(widget.recipeId);
    } else {
      await FavoriteHelper.saveFavorite(widget.recipeId);
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Resep"),
        backgroundColor: const Color.fromARGB(255, 222, 124, 183),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipe == null
              ? const Center(child: Text("Data tidak tersedia"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          recipe!["image"] ?? '',
                          errorBuilder: (context, error, stackTrace) =>
                              const Text("Gambar tidak tersedia"),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recipe!["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Bahan-bahan:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...translatedIngredients.map((item) => Text("• $item")),
                      const SizedBox(height: 16),
                      const Text(
                        "Langkah-langkah:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Html(data: translatedInstructions),
                    ],
                  ),
                ),
    );
  }
}
