import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_app/models/movie.dart';

class MovieService {
  static const String _moviesUrl =
      'https://raw.githubusercontent.com/FEND16/movie-json-data/master/json/movies-coming-soon.json';

  Future<Set<Movie>> fetchMovies() async {
    final response = await http.get(Uri.parse(_moviesUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final movies =
          jsonData
              .map((item) => Movie.fromJson(item as Map<String, dynamic>))
              .toSet(); // Converting list to set directly
      return movies;
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
