import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/api_service.dart';
import '../helpers/favorite_helper.dart';
import '../helpers/comment_helper.dart';
import '../helpers/shopping_list_helper.dart';
import 'package:translator/translator.dart';

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
  List<String> comments = [];
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadRecipe();
    checkFavorite();
    loadComments();
  }

  Future<void> loadRecipe() async {
    try {
      final data = await ApiService.getRecipeDetail(widget.recipeId);

      // Translate instructions and ingredients
      final translator = GoogleTranslator();
      final instructions = data['instructions'] ?? '';
      final translated = await translator.translate(instructions, to: 'id');
      data['instructions'] = translated.text;

      final ingredients = data['extendedIngredients'] as List;
      for (var ing in ingredients) {
        final ingText = ing['original'];
        final ingTranslated = await translator.translate(ingText, to: 'id');
        ing['original'] = ingTranslated.text;
      }

      setState(() {
        recipe = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil detail resep: $e')),
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

  Future<void> loadComments() async {
    final list = await CommentHelper.getComments(widget.recipeId);
    setState(() {
      comments = list;
    });
  }

  Future<void> submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    await CommentHelper.addComment(widget.recipeId, _commentController.text.trim());
    _commentController.clear();
    loadComments();
  }

  Future<void> addToShoppingList() async {
    final ingredients = recipe?["extendedIngredients"] as List;
    final title = recipe?["title"] ?? "Resep";

    await ShoppingListHelper.addRecipeIngredients(title, ingredients.map((e) => e["original"].toString()).toList());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bahan-bahan telah ditambahkan ke daftar belanja!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC), // pink soft
      appBar: AppBar(
        title: const Text("Detail Resep"),
        backgroundColor: const Color.fromARGB(255, 222, 124, 183),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: const Color.fromARGB(255, 173, 46, 46),
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
                      ...List.generate(
                        (recipe!["extendedIngredients"] as List).length,
                        (index) => Text("• ${recipe!["extendedIngredients"][index]["original"]}"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: addToShoppingList,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Tambah ke Daftar Belanja"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Langkah-langkah:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      recipe!["instructions"] != null
                          ? Html(data: recipe!["instructions"])
                          : const Text("Instruksi tidak tersedia."),
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text(
                        "Komentar:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...comments.map((c) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.comment, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(c)),
                              ],
                            ),
                          )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: "Tulis komentar...",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: const Color.fromARGB(255, 242, 144, 203),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: submitComment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 235, 154, 202),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Kirim"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
