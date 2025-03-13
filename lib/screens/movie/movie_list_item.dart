import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/services/watchlist_service.dart';
import 'package:movie_app/widgets/hover_animated_button.dart';
import 'widgets/rating_chip.dart';

class MovieListItem extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;
  final bool isInitiallyInWatchlist;
  final ValueChanged<bool>? onWatchlistChanged;

  const MovieListItem({
    super.key,
    required this.movie,
    required this.onTap,
    this.isInitiallyInWatchlist = false,
    this.onWatchlistChanged,
  });

  @override
  State<MovieListItem> createState() => _MovieListItemState();
}

class _MovieListItemState extends State<MovieListItem> {
  final WatchlistService _watchlistService = WatchlistService();
  final User? _user = FirebaseAuth.instance.currentUser;

  late bool _isInWatchlist;
  bool _isToggling = false;
  StreamSubscription? _watchlistSubscription;

  @override
  void initState() {
    super.initState();
    _isInWatchlist = widget.isInitiallyInWatchlist;

    if (_user != null) {
      _watchlistSubscription = _watchlistService.watchlistStream().listen((
        movies,
      ) {
        final inWatchlist = movies.any((m) => m.id == widget.movie.id);
        if (inWatchlist != _isInWatchlist) {
          setState(() {
            _isInWatchlist = inWatchlist;
          });
          widget.onWatchlistChanged?.call(inWatchlist);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MovieListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInitiallyInWatchlist != oldWidget.isInitiallyInWatchlist) {
      setState(() {
        _isInWatchlist = widget.isInitiallyInWatchlist;
      });
    }
  }

  Future<void> _toggleWatchlist() async {
    if (_user == null) {
      return;
    }
    setState(() => _isToggling = true);

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
      widget.onWatchlistChanged?.call(newState);
    } catch (_) {
      setState(() => _isInWatchlist = !_isInWatchlist);
    }

    setState(() => _isToggling = false);
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(12));
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: widget.movie.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.movie.posterUrl,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget:
                      (context, url, error) => const SizedBox(
                        height: 150,
                        child: Center(child: Icon(Icons.error)),
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Year: ${widget.movie.year}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('IMDb: ', style: TextStyle(fontSize: 14)),
                        RatingChip(
                          rating:
                              widget.movie.imdbRating.isEmpty
                                  ? 'N/A'
                                  : widget.movie.imdbRating,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildWatchlistButton(context),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistButton(BuildContext context) {
    if (_user == null) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.bookmark_outline),
        label: const Text("Sign in to watchlist"),
      );
    }
    if (_isToggling) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final label = _isInWatchlist ? 'In watchlist' : 'Add to watchlist';
    final icon = _isInWatchlist ? Icons.bookmark_remove : Icons.bookmark_add;

    return animatedButton(
      button: ElevatedButton.icon(
        onPressed: _toggleWatchlist,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _watchlistSubscription?.cancel();
    super.dispose();
  }
}
