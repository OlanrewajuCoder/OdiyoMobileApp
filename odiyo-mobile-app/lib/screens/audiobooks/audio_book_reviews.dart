import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/models/review_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/cached_image.dart';
import 'package:odiyo/widgets/custom_button.dart';
import 'package:odiyo/widgets/custom_text_field.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/loading.dart';
import 'package:odiyo/widgets/rating_bar.dart';
import 'package:odiyo/widgets/review_item.dart';
import 'package:uuid/uuid.dart';

class AudioBookReviews extends StatelessWidget {
  final AudioBook audioBook;

  AudioBookReviews({Key? key, required this.audioBook}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();
  final userController = Get.find<UserController>();
  final utilService = Get.find<UtilService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: lightLinearGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('REVIEWS')),
        body: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(15.0),
              alignment: Alignment.center,
              width: double.infinity,
              child: Column(
                children: [
                  CachedImage(
                    height: 120,
                    url: audioBook.poster,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(audioBook.title!, textScaleFactor: 1.5, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  MyRatingBar(rating: audioBook.rating!.toDouble(), ratingsCount: audioBook.ratingsCount!),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text('All Reviews'),
            ),
            Expanded(
              child: showPage(),
            ),
            Visibility(
              visible: userController.currentUser.value.userID != null,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CustomButton(
                  color: primaryColor,
                  text: 'Write a review',
                  function: () {
                    TextEditingController commentTEC = TextEditingController();
                    double rating = 5;
                    Get.defaultDialog(
                      titlePadding: const EdgeInsets.only(top: 15),
                      title: 'Rate this audiobook',
                      content: Column(
                        children: [
                          const SizedBox(height: 20),
                          RatingBar.builder(
                            itemSize: 30,
                            initialRating: rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(Icons.star, color: primaryColor),
                            onRatingUpdate: (myRating) => rating = myRating,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(controller: commentTEC, label: '', hint: 'Write a review', prefix: const Icon(Icons.edit, color: Colors.grey)),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Publish',
                            function: () async {
                              Get.back();
                              utilService.showLoading();
                              Review review = Review(userID: userController.currentUser.value.userID, reviewID: const Uuid().v1(), rating: rating, createdDate: Timestamp.now(), comment: commentTEC.text, audioBookID: audioBook.audioBookID, flagged: false);
                              num averageRating = ((audioBook.rating! * audioBook.ratingsCount!) + rating) / (audioBook.ratingsCount! + 1);
                              audioBook.rating = double.parse(averageRating.toStringAsFixed(2));
                              audioBook.ratingsCount = audioBook.ratingsCount! + 1;
                              await firestoreService.addReview(review, audioBook);
                              await firestoreService.editAudioBookRatingsCount(audioBook);
                              Get.back();
                              showGreenAlert('Submitted review successfully');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showPage() {
    return PaginateFirestore(
      isLive: true,
      physics: const BouncingScrollPhysics(),
      key: GlobalKey(),
      padding: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, List<DocumentSnapshot> documentSnapshot, i) {
        return SizedBox(height: 200, child: ReviewItem(review: documentSnapshot[i].data()! as Review));
      },
      query: firestoreService.getAudioBookReviewsQuery(audioBook.audioBookID!, 5000),
      onEmpty: const EmptyBox(text: 'Be the first one to review'),
      itemsPerPage: 10,
      bottomLoader: const LoadingData(),
      initialLoader: const LoadingData(),
    );
  }
}
