import '../utils/api_key.dart';

class HttpHelper {
  final String startSessionUrl =
      'https://movie-night-api.onrender.com/start-session';

  final String voteMovieUrl = 'https://movie-night-api.onrender.com/vote-movie';

  final String joinSessionUrl =
      'https://movie-night-api.onrender.com/join-session';

  final String getMoviesUrl =
      'https://api.themoviedb.org/3/movie/popular?api_key=$tmdbApiKey&page=2';
}
