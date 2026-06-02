import 'dart:convert';

import 'package:news_app/news_model.dart';
import 'package:http/http.dart' as http;

class NewsService {
  static const String _apiKey = '41631214275a462788d3c20a4c474aff';
  static const String _baseUrl = 'https://newsapi.org/v2';

  Future<List<NewsModel>> fetchSources() async {
    // Endpoint sources: https://newsapi.org/v2/sources
    final uri = Uri.parse(
      '$_baseUrl/sources'
      '?apiKey=$_apiKey',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          throw Exception('Request timeout. Periksa koneksi internet kamu.'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Response sources menggunakan key "sources",
      if (data['status'] == 'ok') {
        final List<dynamic> sourcesJson = data['sources'];

        return sourcesJson
            .map((json) => NewsModel.fromJson(json))
            .where((source) => source.name != '[Removed]')
            .toList();
      } else {
        throw Exception('NewsAPI error: ${data['message']}');
      }
    } else if (response.statusCode == 401) {
      throw Exception(
          'API Key tidak valid. Periksa kembali _apiKey di news_service.dart');
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit tercapai. Coba lagi nanti.');
    } else {
      throw Exception('Gagal memuat sources. Status: ${response.statusCode}');
    }
  }
}
