import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/widgets/hover_animated_button.dart';

class AnimatedWatchlistItem extends StatefulWidget {
  final Movie movie;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const AnimatedWatchlistItem({
    super.key,
    required this.movie,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<AnimatedWatchlistItem> createState() => _AnimatedWatchlistItemState();
}

class _AnimatedWatchlistItemState extends State<AnimatedWatchlistItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(curved);
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.0).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateRemoval() {
    _controller.forward().then((_) => widget.onRemove());
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          height: 120,
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Row(
                    children: [
                      Hero(
                        tag: widget.movie.id,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          child: Image.network(
                            widget.movie.posterUrl,
                            width: 80,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (ctx, obj, st) => const SizedBox(
                                  height: 120,
                                  child: Icon(Icons.broken_image),
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 6,
                          ),
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
                              const SizedBox(height: 4),
                              Text(
                                widget.movie.imdbRating.isEmpty
                                    ? "N/A"
                                    : widget.movie.imdbRating,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 70,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: animatedButton(
                  button: IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _animateRemoval,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
