import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/audio_book_item.dart';
import 'package:odiyo/widgets/custom_button.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/loading.dart';

class BookList extends StatelessWidget {
  final String? title;
  final ListType value;

  BookList({Key? key, this.title, required this.value}) : super(key: key);

  final RxString sortBy = 'popular'.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        appBar: AppBar(title: Text(title!)),
        body: getList(),
      ),
    );
  }

  getList() {
    final firestoreService = Get.find<FirestoreService>();

    Stream<QuerySnapshot<AudioBook>> stream = firestoreService.getAudioBooksStream(1000, 'createdDate');
    switch (value) {
      case ListType.recent:
        stream = firestoreService.getAudioBooksStream(1000, 'createdDate');
        break;
      case ListType.featured:
        stream = firestoreService.getAudioBooksWhereStream('isFeatured', true, 1000, 'createdDate');
        break;
      case ListType.category:
        stream = firestoreService.getAudioBooksWhereStream('category', title, 1000, 'createdDate');
        break;
      case ListType.topRated:
        stream = firestoreService.getAudioBooksStream(1000, 'rating');
        break;
      case ListType.popular:
        stream = firestoreService.getAudioBooksStream(1000, 'ratingsCount');
        break;
      default:
        stream = firestoreService.getAudioBooksStream(1000, 'createdDate');
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

        return data.size > 0
            ? Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10),
                      padding: const EdgeInsets.all(10),
                      itemCount: data.size,
                      itemBuilder: (context, index) => AudioBookItem(audioBook: data.docs[index].data()),
                    ),
                  ),
                  Container(
                      height: 60,
                      color: secondaryColor,
                      child: InkWell(
                        onTap: () => showSortDialog(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(onPressed: () {}, icon: const Icon(Icons.sort, color: primaryColor)),
                            const SizedBox(width: 10),
                            const Text('Sort by', style: TextStyle(color: primaryColor)),
                          ],
                        ),
                      )),
                ],
              )
            : const EmptyBox(text: 'Nothing to show');
      },
    );
  }

  void showSortDialog(context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  insetPadding: const EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Sort By", textScaleFactor: 1.2),
                        Divider(color: Colors.grey.shade700, height: 20, thickness: 1),
                        RadioListTile(
                          activeColor: primaryColor,
                          contentPadding: EdgeInsets.zero,
                          groupValue: sortBy.value,
                          title: const Text('Popularity'),
                          value: 'popular',
                          onChanged: (val) {},
                        ),
                        RadioListTile(
                          activeColor: primaryColor,
                          contentPadding: EdgeInsets.zero,
                          groupValue: sortBy.value,
                          title: const Text('Ratings'),
                          value: 'ratings',
                          onChanged: (val) {},
                        ),
                        CustomButton(
                          function: () {
                            Navigator.of(context).pop(true);
                          },
                          text: 'Apply',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
