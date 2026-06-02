import 'package:flutter/material.dart';
import 'news_model.dart';
import 'news_services.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  
  // Future yang menyimpan hasil pemanggilan API
  late Future<List<NewsModel>> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Memanggil fetchSources saat layar pertama kali dimuat
    _newsFuture = _newsService.fetchSources();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Sources'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // Menggunakan FutureBuilder untuk menangani asynchronous data
      body: FutureBuilder<List<NewsModel>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          // 1. Kondisi saat data masih dimuat (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // 2. Kondisi saat terjadi error (Gagal fetch / tidak ada internet)
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          // 3. Kondisi saat data kosong
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada sumber berita ditemukan.'));
          }

          // Menyimpan data hasil fetch ke variabel
          final news = snapshot.data!;

          // 4. Kondisi saat data berhasil dimuat (Success)
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
              return Container(
                height: 90,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.only(left: 30, top: 15, right: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue), // Kotak dengan border biru
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? 'No Name',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description ?? 'No Description',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}