import 'dart:convert';
// ignore: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/api_key.dart';

class MovieSelectionScreen extends StatefulWidget {
  final String sessionId;

  const MovieSelectionScreen({super.key, required this.sessionId});

  @override
  State<MovieSelectionScreen> createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  int currentIndex = 0;
  late Future<List<Movies>> movieSwipe;

  @override
  void initState() {
    super.initState();
    movieSwipe = fetchMovies();
  }

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
      body: Center(
          child: FutureBuilder(
        future: fetchMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final movies = snapshot.data as List<Movies>;
          final movie = movies[currentIndex];

          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Dismissible(
                key: Key(movie.id.toString()),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) async {
                  final bool vote =
                      (direction == DismissDirection.startToEnd) ? true : false;
                  final int movieId = movies[currentIndex].id;
                  final String sessionId = widget.sessionId;

                  try {
                    await voteForMovie(sessionId, movieId, vote);
                    setState(() {
                      if (direction == DismissDirection.startToEnd) {
                        currentIndex = (currentIndex < movies.length - 1)
                            ? currentIndex + 1
                            : 0;
                      } else if (direction == DismissDirection.endToStart) {
                        currentIndex = (currentIndex < movies.length - 1)
                            ? currentIndex + 1
                            : 0;
                      }
                    });
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to submit vote: $error'),
                      ),
                    );
                  }
                },
                background: Container(
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.thumb_up,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.thumb_down,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                child: Container(
                  height: 450,
                  width: 350,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(children: [
                    ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie.image}',
                          width: 350,
                          height: 250,
                          fit: BoxFit.cover,
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 30, 5, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie.name,
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                              )),
                          const SizedBox(height: 20),
                          Text('Vote Average: ${movie.voteAverage}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary,
                              )),
                          const SizedBox(height: 20),
                          Text('Release Date: ${movie.releaseDate}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary,
                              )),
                        ],
                      ),
                    )
                  ]),
                ))
          ]);
        },
      )),
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

  Future<void> voteForMovie(String sessionId, int movieId, bool vote) async {
    final url = Uri.parse(
        'https://movie-night-api.onrender.com/vote-movie?session_id=$sessionId&movie_id=$movieId&vote=$vote');

    final response = await http.get(
      url.replace(queryParameters: {
        'session_id': sessionId,
        'movie_id': movieId.toString(),
        'vote': vote.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      final match = jsonResponse['data']['match'];

      if (match) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Match found for movie ID: $movieId'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No match found for movie ID: $movieId'),
          ),
        );
      }
    } else {
      throw Exception(
          'Failed to vote for the movie. Status code: ${response.statusCode}');
    }
  }
}

class Movies {
  final String image;
  final String name;
  final double voteAverage;
  final String releaseDate;
  final int id;

  Movies(
      {required this.image,
      required this.name,
      required this.voteAverage,
      required this.releaseDate,
      required this.id});

  factory Movies.fromJson(Map<String, dynamic> json) {
    return Movies(
      image: json['poster_path'] ?? 'Unknown image',
      name: json['original_title'] ?? 'Unknown title',
      voteAverage:
          double.parse((json['vote_average'] ?? 0.0).toStringAsFixed(2)),
      releaseDate: json['release_date'] ?? 'Unknown date',
      id: json['id'] ?? 0,
    );
  }
}
