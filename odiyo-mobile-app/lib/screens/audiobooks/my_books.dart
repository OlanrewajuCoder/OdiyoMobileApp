import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/models/transactions_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/widgets/audio_book_item.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/loading.dart';

class MyBooks extends StatelessWidget {
  MyBooks({Key? key}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Books')),
      body: PaginateFirestore(
        physics: const BouncingScrollPhysics(),
        key: GlobalKey(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
        padding: const EdgeInsets.all(10),
        itemBuilderType: PaginateBuilderType.gridView,
        itemBuilder: (context, List<DocumentSnapshot> documentSnapshot, i) {
          MyTransaction transaction = documentSnapshot[i].data()! as MyTransaction;
          return FutureBuilder<DocumentSnapshot<AudioBook>>(
            future: firestoreService.getAudioBookByID(transaction.audioBookID!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LoadingData();
              }
              return AudioBookItem(audioBook: snapshot.requireData.data()!);
            },
          );
        },
        query: firestoreService.getMyTransactions(10),
        onEmpty: const EmptyBox(text: 'Your purchased books will show up here'),
        itemsPerPage: 10,
        bottomLoader: const LoadingData(),
        initialLoader: const LoadingData(),
      ),
    );
  }
}
