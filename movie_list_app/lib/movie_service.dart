import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  static const String apiKey = 'API_KEY_ANDA_DI_SINI';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  Future<List<Movie>> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&language=en-US&page=1'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat daftar film');
    }
  }
}
