import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_service.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.posterPath != null)
              Image.network(
                '${MovieService.imageBaseUrl}${movie.posterPath}',
                width: double.infinity,
                height: 450,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 450, color: Colors.grey, child: Icon(Icons.broken_image, size: 100)),
              )
            else
              Container(height: 450, color: Colors.grey, child: Icon(Icons.movie, size: 100)),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(
                        '${movie.voteAverage.toStringAsFixed(1)}/10',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 24),
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                      SizedBox(width: 6),
                      Text(
                        movie.releaseDate,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
