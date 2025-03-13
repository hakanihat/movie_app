import 'package:flutter/material.dart';

class RatingChip extends StatelessWidget {
  final String rating;
  const RatingChip({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    double? imdbRatingValue;
    if (rating.isNotEmpty) {
      imdbRatingValue = double.tryParse(rating);
    }

    Color? bgColor;
    Color? textColor;
    String displayValue;

    if (imdbRatingValue != null) {
      displayValue = rating;
      if (imdbRatingValue >= 8.0) {
        bgColor = Colors.green[100];
        textColor = Colors.green[900];
      } else if (imdbRatingValue >= 6.0) {
        bgColor = Colors.yellow[100];
        textColor = Colors.yellow[900];
      } else {
        bgColor = Colors.orange[100];
        textColor = Colors.orange[900];
      }
    } else {
      displayValue = 'N/A';
      bgColor = Colors.red[100];
      textColor = Colors.red[900];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        displayValue,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
