import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/screens/audiobooks/audio_book_details.dart';
import 'package:odiyo/services/player_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/widgets/cached_image.dart';
import 'package:odiyo/widgets/rating_bar.dart';

class AudioBookItem extends StatelessWidget {
  AudioBookItem({Key? key, required this.audioBook}) : super(key: key);
  final AudioBook audioBook;
  final playerService = Get.find<PlayerService>();
  final utilService = Get.find<UtilService>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => AudioBookDetails(audioBook: audioBook)),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                    child: CachedImage(url: audioBook.poster, height: double.infinity, roundedCorners: false),
                  ),
                  if (audioBook.price! > 0)
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'PAID',
                        textScaleFactor: 0.8,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(audioBook.title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 5),
                  MyRatingBar(ratingsCount: audioBook.ratingsCount!, rating: audioBook.rating!.toDouble(), size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
