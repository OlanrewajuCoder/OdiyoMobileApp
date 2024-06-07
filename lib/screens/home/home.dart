import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/screens/audiobooks/books_list.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/audio_book_item.dart';
import 'package:odiyo/widgets/loading.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final PageController pageController = PageController(initialPage: 1, viewportFraction: 0.8);
  final userController = Get.find<UserController>();
  final firestoreService = Get.find<FirestoreService>();

  showList(String title, ListType value) {
    Stream<QuerySnapshot<AudioBook>> stream = firestoreService.getAudioBooksStream(10, 'createdDate');
    switch (value) {
      case ListType.recent:
        stream = firestoreService.getAudioBooksStream(10, 'createdDate');
        break;
      case ListType.featured:
        stream = firestoreService.getAudioBooksWhereStream('isFeatured', true, 10, 'createdDate');
        break;
      case ListType.category:
        stream = firestoreService.getAudioBooksWhereStream('category', title, 10, 'createdDate');
        break;
      case ListType.topRated:
        stream = firestoreService.getAudioBooksStream(10, 'rating');
        break;
      case ListType.popular:
        stream = firestoreService.getAudioBooksStream(10, 'ratingsCount');
        break;
      default:
        stream = firestoreService.getAudioBooksStream(10, 'createdDate');
        break;
    }

    return StreamBuilder<QuerySnapshot<AudioBook>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (!snapshot.hasData) {
          return const LoadingData();
        }

        final data = snapshot.requireData;

        if (value == ListType.featured) {
          return CarouselSlider(
            options: CarouselOptions(
              height: Get.width / .95,
              viewportFraction: 0.7,
              initialPage: 1,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
            ),
            items: data.docs.map((i) => AudioBookItem(audioBook: i.data())).toList(),
          );
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(title, textScaleFactor: 1.2, style: const TextStyle(color: Colors.white)),
                    IconButton(onPressed: () => Get.to(() => BookList(title: title, value: value)), icon: const Icon(Icons.arrow_forward)),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: Get.width / 2,
                      child: AudioBookItem(audioBook: data.docs[index].data()),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      children: <Widget>[
        showList('Featured', ListType.featured),
        SizedBox(
          height: 85,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 15, top: 30),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => Get.to(() => BookList(title: categories[index], value: ListType.category)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  margin: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(40.0),
                    border: Border.all(color: lightBackgroundColor),
                  ),
                  child: Text(categories[index], style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        showList('Recent', ListType.recent),
        showList('Top Rated', ListType.topRated),
        showList('Popular', ListType.popular),
        const SizedBox(height: 100),
      ],
    );
  }
}
