import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/models/movie.dart';

class WatchlistService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addToWatchlist(Movie movie) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(movie.id);

    await docRef.set({
      'id': movie.id,
      'title': movie.title,
      'year': movie.year,
      'genres': movie.genres,
      'ratings': movie.ratings,
      'poster': movie.poster,
      'contentRating': movie.contentRating,
      'duration': movie.duration,
      'releaseDate': movie.releaseDate,
      'averageRating': movie.averageRating,
      'originalTitle': movie.originalTitle,
      'storyline': movie.storyline,
      'actors': movie.actors,
      'imdbRating': movie.imdbRating,
      'posterUrl': movie.posterUrl,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromWatchlist(String movieId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(movieId);
    await docRef.delete();
  }

  Future<Set<String>> fetchWatchlistIds() async {
    final user = _auth.currentUser;
    if (user == null) return {};
    final snapshot =
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('watchlist')
            .get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<bool> isInWatchlist(String movieId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(movieId);
    final snapshot = await docRef.get();
    return snapshot.exists;
  }

  Future<void> toggleWatchlist(Movie movie) async {
    final inList = await isInWatchlist(movie.id);
    if (inList) {
      await removeFromWatchlist(movie.id);
    } else {
      await addToWatchlist(movie);
    }
  }

  Stream<List<Movie>> watchlistStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Movie(
              id: data['id'] ?? '',
              title: data['title'] ?? '',
              year: data['year'] ?? '',
              genres:
                  (data['genres'] as List<dynamic>?)
                      ?.map((e) => e as String)
                      .toList() ??
                  [],
              ratings:
                  (data['ratings'] as List<dynamic>?)
                      ?.map((e) => e as int)
                      .toList() ??
                  [],
              poster: data['poster'] ?? '',
              contentRating: data['contentRating'] ?? '',
              duration: data['duration'] ?? '',
              releaseDate: data['releaseDate'] ?? '',
              averageRating:
                  (data['averageRating'] is num)
                      ? (data['averageRating'] as num).toDouble()
                      : 0.0,
              originalTitle: data['originalTitle'] ?? '',
              storyline: data['storyline'] ?? '',
              actors:
                  (data['actors'] as List<dynamic>?)
                      ?.map((e) => e as String)
                      .toList() ??
                  [],
              imdbRating: (data['imdbRating'] ?? '').toString(),
              posterUrl: data['posterUrl'] ?? '',
            );
          }).toList();
        });
  }
}
