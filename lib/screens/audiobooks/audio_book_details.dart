import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/models/review_model.dart';
import 'package:odiyo/screens/audiobooks/audio_book_reviews.dart';
import 'package:odiyo/screens/audiobooks/author_books_list.dart';
import 'package:odiyo/screens/audiobooks/my_player.dart';
import 'package:odiyo/screens/auth/login.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/player_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/cached_image.dart';
import 'package:odiyo/widgets/circular_clipper.dart';
import 'package:odiyo/widgets/custom_button.dart';
import 'package:odiyo/widgets/custom_list_tile.dart';
import 'package:odiyo/widgets/custom_text_field.dart';
import 'package:odiyo/widgets/favorite_button.dart';
import 'package:odiyo/widgets/rating_bar.dart';
import 'package:odiyo/widgets/review_item.dart';
//import 'package:share/share.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:uuid/uuid.dart';

class AudioBookDetails extends StatefulWidget {
  final AudioBook audioBook;

  const AudioBookDetails({Key? key, required this.audioBook}) : super(key: key);

  @override
  State<AudioBookDetails> createState() => _AudioBookDetailsState();
}

class _AudioBookDetailsState extends State<AudioBookDetails> {
  final PageController reviewController = PageController();
  final firestoreService = Get.find<FirestoreService>();
  final userController = Get.find<UserController>();
  final utilService = Get.find<UtilService>();
  final RxBool isPurchased = false.obs;

  @override
  void initState() {
    checkIfPurchased();
    super.initState();
  }

  Future<bool> checkIfPurchased() async {
    if (widget.audioBook.price == 0 || await firestoreService.checkIfPurchased(widget.audioBook.audioBookID!) == true) {
      isPurchased.value = true;
      return true;
    } else {
      isPurchased.value = false;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: lightLinearGradient),
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  child: ClipShadowPath(
                    clipper: CircularClipper(),
                    shadow: const Shadow(blurRadius: 10.0, color: Colors.black54),
                    child: CachedImage(
                      height: Get.width,
                      url: widget.audioBook.poster!,
                    ),
                  ),
                ),
                Positioned.fill(
                  bottom: 10.0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 30),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.audioBook.price! > 0 ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.audioBook.price! > 0 ? 'PAID' : 'FREE',
                        textScaleFactor: 0.8,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 20.0,
                  child: Visibility(visible: userController.currentUser.value.userID != null, child: FavoriteButton(audioBookID: widget.audioBook.audioBookID!)),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 25.0,
                  child: Visibility(
                    visible: userController.currentUser.value.userID != null,
                    child: IconButton(
                      onPressed: (){},// => Share.share('Check out ${widget.audioBook.title} by ${widget.audioBook.author} on Odiyo. Get Odiyo from Play Store and App Store and enjoy an exciting collection of thousands of audio books. Download now'),
                      icon: const Icon(Icons.share),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.audioBook.title!.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    textScaleFactor: 1.1,
                  ),
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () => Get.to(() => AuthorBooks(authorName: widget.audioBook.author!)),
                    child: Text(
                      widget.audioBook.author!,
                      style: const TextStyle(
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  MyRatingBar(rating: widget.audioBook.rating!.toDouble(), ratingsCount: widget.audioBook.ratingsCount!),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          const Text('Price'),
                          const SizedBox(height: 2.0),
                          Text(widget.audioBook.price == 0 ? 'Free' : '\$${widget.audioBook.price}', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          const Text('Category'),
                          const SizedBox(height: 2.0),
                          Text(widget.audioBook.category!, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  Text(
                    widget.audioBook.description!,
                    textAlign: TextAlign.justify,
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('CHAPTERS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 60),
                    ],
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      return CustomListTile(
                        onTap: () async {
                          if (userController.currentUser.value.userID == null) {
                            Get.offAll(() => const Login());
                          } else {
                            if (await checkIfPurchased()) {
                              index.value = i;
                              Get.off(() => MyPlayer(
                                    audioBook: widget.audioBook,
                                  ));
                            } else {
                              utilService.showBuyDialog(widget.audioBook);
                            }
                          }
                        },
                        leading: Row(
                          children: [
                            CachedImage(
                              url: widget.audioBook.poster,
                              height: 50,
                            ),
                          ],
                        ),
                        title: Text(widget.audioBook.chapterTitles![i]),
                        trailing: (index.value == i && widget.audioBook.audioBookID == currentAudioBook.value.audioBookID)
                            ? const Text(
                                'PLAYING',
                                textScaleFactor: 0.9,
                                style: TextStyle(color: Colors.white),
                              )
                            : const Icon(Icons.play_arrow),
                      );
                    },
                    itemCount: widget.audioBook.chapters!.length,
                  ),
                  const Divider(height: 50),
                  StreamBuilder<QuerySnapshot<Review>>(
                    stream: firestoreService.getAudioBookReviews(widget.audioBook.audioBookID!, 3),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      } else {
                        return snapshot.requireData.docs.isEmpty
                            ? Container()
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('REVIEWS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      IconButton(onPressed: () => Get.to(() => AudioBookReviews(audioBook: widget.audioBook)), icon: const Icon(Icons.arrow_forward)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 180,
                                    child: PageView.builder(
                                      controller: reviewController,
                                      itemBuilder: (context, i) => ReviewItem(review: snapshot.requireData.docs[i].data()),
                                      itemCount: snapshot.requireData.size,
                                    ),
                                  ),
                                  SmoothPageIndicator(
                                    controller: reviewController, // PageController
                                    count: snapshot.requireData.size,
                                    effect: const WormEffect(activeDotColor: primaryColor, radius: 2, dotHeight: 10, dotWidth: 10),
                                    onDotClicked: (index) {},
                                  ),
                                ],
                              );
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  Obx(() {
                    return Visibility(
                      visible: userController.currentUser.value.userID != null && isPurchased.value,
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
                                    Review review = Review(userID: userController.currentUser.value.userID, reviewID: const Uuid().v1(), rating: rating, createdDate: Timestamp.now(), comment: commentTEC.text, audioBookID: widget.audioBook.audioBookID, flagged: false);
                                    num averageRating = ((widget.audioBook.rating! * widget.audioBook.ratingsCount!) + rating) / (widget.audioBook.ratingsCount! + 1);
                                    widget.audioBook.rating = double.parse(averageRating.toStringAsFixed(2));
                                    widget.audioBook.ratingsCount = widget.audioBook.ratingsCount! + 1;
                                    await firestoreService.addReview(review, widget.audioBook);
                                    await firestoreService.editAudioBookRatingsCount(widget.audioBook);
                                    Get.back();
                                    showGreenAlert('Submitted review successfully');
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
