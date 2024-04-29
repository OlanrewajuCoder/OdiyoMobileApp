import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/screens/audiobooks/audio_book_details.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/widgets/cached_image.dart';

class DisplaySearchResult extends StatelessWidget {
  final String? audioBookID;
  final String? title;
  final String? poster;

  DisplaySearchResult({Key? key, this.title, this.audioBookID, this.poster}) : super(key: key);
  final firestoreService = Get.find<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<AudioBook>>(
      future: firestoreService.getAudioBookByID(audioBookID!),
      builder: (context, AsyncSnapshot<DocumentSnapshot<AudioBook>> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        } else {
          AudioBook audioBook = snapshot.requireData.data()!;
          return ListTile(
            onTap: () => Get.to(() => AudioBookDetails(audioBook: audioBook)),
            leading: CachedImage(url: poster, height: 50),
            title: Text(title!),
          );
        }
      },
    );
  }
}
