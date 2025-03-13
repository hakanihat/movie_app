import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/watchlist_service.dart';
import 'package:movie_app/widgets/hover_animated_button.dart';
import 'widgets/rating_chip.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final bool showWatchlistButton;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    this.showWatchlistButton = true,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final WatchlistService _watchlistService = WatchlistService();
  final user = FirebaseAuth.instance.currentUser;

  bool _isInWatchlist = false;
  bool _isLoadingWatchlistStatus = true;
  bool _isImagePrecached = false;

  @override
  void initState() {
    super.initState();
    _checkIfInWatchlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isImagePrecached) {
      precacheImage(
        CachedNetworkImageProvider(widget.movie.posterUrl),
        context,
      );
      _isImagePrecached = true;
    }
  }

  Future<void> _checkIfInWatchlist() async {
    if (user == null) {
      setState(() {
        _isInWatchlist = false;
        _isLoadingWatchlistStatus = false;
      });
      return;
    }
    try {
      final inList = await _watchlistService.isInWatchlist(widget.movie.id);
      setState(() {
        _isInWatchlist = inList;
        _isLoadingWatchlistStatus = false;
      });
    } catch (_) {
      setState(() {
        _isInWatchlist = false;
        _isLoadingWatchlistStatus = false;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    final newState = !_isInWatchlist;
    setState(() {
      _isInWatchlist = newState;
    });
    try {
      if (newState) {
        await _watchlistService.addToWatchlist(widget.movie);
      } else {
        await _watchlistService.removeFromWatchlist(widget.movie.id);
      }
    } catch (_) {
      setState(() {
        _isInWatchlist = !_isInWatchlist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double avgRating = 0.0;
    final hasUserRatings = widget.movie.ratings.isNotEmpty;
    if (hasUserRatings) {
      final sum = widget.movie.ratings.reduce((a, b) => a + b);
      avgRating = sum / widget.movie.ratings.length;
    }
    final String userRatingStr =
        hasUserRatings ? avgRating.toStringAsFixed(1) : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        centerTitle: false,
        actions: [
          if (widget.showWatchlistButton) _buildWatchlistButton(context),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Column(
                children: [
                  Hero(
                    tag: widget.movie.id,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade900,
                          width: 1.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        child: Image.network(
                          widget.movie.posterUrl,
                          height: 300,
                          fit: BoxFit.fitHeight,
                          errorBuilder: (ctx, error, stackTrace) {
                            return const SizedBox(
                              height: 300,
                              child: Center(
                                child: Icon(Icons.broken_image, size: 80),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movie.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Year: ${widget.movie.year}  |  Rating: ${widget.movie.contentRating}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'IMDb Rating: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            RatingChip(rating: widget.movie.imdbRating),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'User Rating: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            RatingChip(rating: userRatingStr),
                            if (hasUserRatings) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${widget.movie.ratings.length} votes)',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        if (widget.movie.genres.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Genres: ${widget.movie.genres.join(", ")}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        if (widget.movie.actors.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Actors: ${widget.movie.actors.join(", ")}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Duration: ${widget.movie.duration.isNotEmpty ? widget.movie.duration : "N/A"}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.movie.releaseDate.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Release Date: ${widget.movie.releaseDate}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.movie.storyline.isNotEmpty) ...[
                      const Text(
                        'Storyline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.movie.storyline,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistButton(BuildContext context) {
    if (_isLoadingWatchlistStatus) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    }
    final label = _isInWatchlist ? 'In watchlist' : 'Add to watchlist';
    final icon = _isInWatchlist ? Icons.bookmark_remove : Icons.bookmark_add;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: animatedButton(
        button: ElevatedButton.icon(
          onPressed: _toggleWatchlist,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
