import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:odiyo/utils/constants.dart';

class MyRatingBar extends StatelessWidget {
  final double rating;
  final int ratingsCount;
  final double size;
  const MyRatingBar({Key? key, required this.ratingsCount, required this.rating, this.size = 18}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => const Icon(FontAwesomeIcons.solidStar, color: primaryColor),
          itemCount: 5,
          itemSize: size,
          itemPadding: EdgeInsets.all(size == 18 ? 5 : 2.5),
        ),
        const SizedBox(width: 10),
        Text('($ratingsCount)', textScaleFactor: size == 18 ? 1 : 0.9),
      ],
    );
  }
}
