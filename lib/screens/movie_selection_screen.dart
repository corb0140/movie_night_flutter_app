import 'dart:convert';
// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/api_key.dart';

class MovieSelectionScreen extends StatelessWidget {
  final String sessionId;

  const MovieSelectionScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Night',
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimary,
            )),
        backgroundColor: const Color.fromARGB(84, 0, 0, 0),
      ),
      body: Dismissible(
        key: const ValueKey('movie-selection'),
        child: Center(
          child: FutureBuilder(
              future: fetchMovies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final movies = snapshot.data as List<Movies>;
                return ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.network(
                        'https://image.tmdb.org/t/p/w500${movies[index].image}',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      title: Text(movies[index].name),
                      subtitle: Text('Rating: ${movies[index].voteAverage}'),
                      trailing:
                          Text('Release Date: ${movies[index].releaseDate}'),
                    );
                  },
                );
              }),
        ),
      ),
    );
  }

  Future<List<Movies>> fetchMovies() async {
    var response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$tmdbApiKey&page=2'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final results = jsonResponse['results'] as List<dynamic>;
      return results.map((dynamic data) => Movies.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data from the internet');
    }
  }
}

class Movies {
  final String image;
  final String name;
  final double voteAverage;
  final String releaseDate;

  Movies(
      {required this.image,
      required this.name,
      required this.voteAverage,
      required this.releaseDate});

  factory Movies.fromJson(Map<String, dynamic> json) {
    return Movies(
      image: json['poster_path'] ?? 'Unknown image',
      name: json['original_title'] ?? 'Unknown title',
      voteAverage: json['vote_Average'] ?? 0.0,
      releaseDate: json['release_date'] ?? 'Unknown date',
    );
  }
}
