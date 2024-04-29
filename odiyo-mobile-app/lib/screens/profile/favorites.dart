import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/models/favorites_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/audio_book_item.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/loading.dart';

class Favorites extends StatelessWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Favorites')),
        body: getMyFavorites(),
      ),
    );
  }

  getMyFavorites() {
    final firestoreService = Get.find<FirestoreService>();
    return StreamBuilder<QuerySnapshot<Favorite>>(
      stream: firestoreService.getMyFavorites(10),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyBox(text: snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return const LoadingData();
        }

        final data = snapshot.requireData;

        return data.docs.isNotEmpty
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
                padding: const EdgeInsets.all(10),
                itemCount: data.size,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot<AudioBook>>(
                    future: firestoreService.getAudioBookByID(data.docs[index].data().audioBookID!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return EmptyBox(text: snapshot.error.toString());
                      }

                      if (!snapshot.hasData) {
                        return const LoadingData();
                      }

                      return AudioBookItem(audioBook: snapshot.requireData.data()!);
                    },
                  );
                },
              )
            : const EmptyBox(text: 'Your favorite books will show up here');
      },
    );
  }
}
