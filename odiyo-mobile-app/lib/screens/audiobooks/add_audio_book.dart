import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/custom_button.dart';
import 'package:uuid/uuid.dart';

class AddAudioBook extends StatelessWidget {
  AddAudioBook({Key? key}) : super(key: key);
  final TextEditingController titleTEC = TextEditingController();
  final TextEditingController imageURL = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: lightLinearGradient),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Audio Book'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Title'),
              const SizedBox(height: 10),
              TextField(controller: titleTEC),
              const SizedBox(height: 30),
              const Text('Image URL'),
              const SizedBox(height: 10),
              TextField(controller: imageURL),
              const SizedBox(height: 50),
              CustomButton(
                text: 'Add',
                function: () async {
                  final firestoreService = Get.find<FirestoreService>();
                  AudioBook audioBook = AudioBook(
                    poster: imageURL.text,
                    title: titleTEC.text,
                    category: 'Adventure',
                    rating: 0,
                    ratingsCount: 0,
                    //runtime: 125,
                    description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'
                        '. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                    price: 0,
                    audioBookID: const Uuid().v1(),
                    createdDate: Timestamp.now(),
                    isFeatured: DateTime.now().millisecondsSinceEpoch % 2 == 0,
                  );
                  await firestoreService.addBook(audioBook);
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
