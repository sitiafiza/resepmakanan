import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = 'f5d28b07f9db4e46a289d90d8fe68ec4';
const String baseUrl = 'https://api.spoonacular.com/recipes';

class ApiService {
  static Future<List<dynamic>> searchRecipes(String query) async {
    final url = Uri.parse('$baseUrl/complexSearch?query=$query&number=10&apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Gagal memuat data resep');
    }
  }

  static Future<Map<String, dynamic>> getRecipeDetail(int recipeId) async {
    final url = Uri.parse('$baseUrl/$recipeId/information?apiKey=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail resep');
    }
  }
}
