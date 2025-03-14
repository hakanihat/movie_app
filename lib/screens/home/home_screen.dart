import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/movie/movie_detail_screen.dart';
import 'package:movie_app/screens/movie/movie_list_item.dart';
import 'package:movie_app/services/movie_service.dart';
import 'package:movie_app/services/watchlist_service.dart';
import 'package:movie_app/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _movieService = MovieService();
  final _watchlistService = WatchlistService();

  // Future returns a Set<Movie> to ensure uniqueness.
  late Future<Set<Movie>> _futureMovies;
  Set<Movie> _allMovies = {};
  Set<Movie> _filteredMovies = {};
  Set<String> _watchlistedIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Convert the fetched list to a set.
    _futureMovies = _movieService.fetchMovies().then(
      (movies) => movies.toSet(),
    );
    _fetchWatchlist();
  }

  Future<void> _fetchWatchlist() async {
    try {
      final watchlistedIds = await _watchlistService.fetchWatchlistIds();
      setState(() {
        _watchlistedIds = watchlistedIds;
      });
    } catch (e) {
      debugPrint('Error fetching watchlist: $e');
    }
  }

  void _filterMovies(String query) {
    setState(() {
      _filteredMovies =
          _allMovies
              .where(
                (movie) =>
                    movie.title.toLowerCase().contains(query.toLowerCase()),
              )
              .toSet();
    });
  }

  void _updateWatchlist(String movieId, bool isNowInWatchlist) {
    setState(() {
      if (isNowInWatchlist) {
        _watchlistedIds.add(movieId);
      } else {
        _watchlistedIds.remove(movieId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movies',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMovies,
              decoration: InputDecoration(
                hintText: "Search for a movie...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<Set<Movie>>(
              future: _futureMovies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No movies found.'));
                }

                if (_allMovies.isEmpty) {
                  _allMovies = snapshot.data!;
                  _filteredMovies = _allMovies;
                }

                // Convert set to list using elementAt(index) for ListView builder
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _filteredMovies.elementAt(index);
                    return MovieListItem(
                      movie: movie,
                      isInitiallyInWatchlist: _watchlistedIds.contains(
                        movie.id,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      onWatchlistChanged: (bool inWatchlist) {
                        _updateWatchlist(movie.id, inWatchlist);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
