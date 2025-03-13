import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';

import 'widgets/rating_chip.dart';

class MovieListItem extends StatefulWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieListItem({super.key, required this.movie, required this.onTap});

  @override
  State<MovieListItem> createState() => _MovieListItemState();
}

class _MovieListItemState extends State<MovieListItem> {
  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    super.dispose();
  }
}
