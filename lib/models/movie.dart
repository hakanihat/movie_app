class Movie {
  final String id;
  final String title;
  final String year;
  final List<String> genres;
  final List<int> ratings;
  final String poster;
  final String contentRating;
  final String duration;
  final String releaseDate;
  final double averageRating;
  final String originalTitle;
  final String storyline;
  final List<String> actors;
  final String imdbRating;
  final String posterUrl;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.genres,
    required this.ratings,
    required this.poster,
    required this.contentRating,
    required this.duration,
    required this.releaseDate,
    required this.averageRating,
    required this.originalTitle,
    required this.storyline,
    required this.actors,
    required this.imdbRating,
    required this.posterUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    String parseDuration(String duration) {
      if (duration.startsWith('PT') && duration.endsWith('M')) {
        final minutes = duration.substring(2, duration.length - 1);
        return '$minutes minutes';
      }
      return duration.isNotEmpty ? duration : 'N/A';
    }

    return Movie(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      year: (json['year'] ?? '').toString(),
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((genre) => genre as String)
              .toList() ??
          [],
      ratings:
          (json['ratings'] as List<dynamic>?)
              ?.map((rating) => rating as int)
              .toList() ??
          [],
      poster: (json['poster'] ?? '').toString(),
      contentRating: (json['contentRating'] ?? '').toString(),
      duration: parseDuration((json['duration'] ?? '').toString()),
      releaseDate: (json['releaseDate'] ?? '').toString(),
      averageRating:
          (json['averageRating'] is num)
              ? (json['averageRating'] as num).toDouble()
              : 0.0,
      originalTitle: (json['originalTitle'] ?? '').toString(),
      storyline: (json['storyline'] ?? '').toString(),
      actors:
          (json['actors'] as List<dynamic>?)
              ?.map((actor) => actor as String)
              .toList() ??
          [],
      imdbRating: (json['imdbRating'] ?? '').toString(),
      posterUrl: (json['posterurl'] ?? '').toString(),
    );
  }
}
