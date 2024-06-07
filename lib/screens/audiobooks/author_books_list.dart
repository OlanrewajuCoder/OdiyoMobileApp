import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/widgets/audio_book_item.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/loading.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class AuthorBooks extends StatelessWidget {
  final String authorName;

  AuthorBooks({Key? key, required this.authorName}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(authorName)),
      body: PaginateFirestore(
        physics: const BouncingScrollPhysics(),
        key: GlobalKey(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
        padding: const EdgeInsets.all(10),
        itemBuilderType: PaginateBuilderType.gridView,
        itemBuilder: (context, List<DocumentSnapshot> documentSnapshot, i) {
          AudioBook audioBook = documentSnapshot[i].data()! as AudioBook;
          return AudioBookItem(audioBook: audioBook);
        },
        query: firestoreService.getAudioBooksWhere('author', authorName, 10),
        onEmpty: EmptyBox(text: 'Books by $authorName'),
        itemsPerPage: 10,
        bottomLoader: const LoadingData(),
        initialLoader: const LoadingData(),
      ),
    );
  }
}
