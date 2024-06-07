import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/review_model.dart';
import 'package:odiyo/models/users_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewItem extends StatelessWidget {
  final Review? review;

  ReviewItem({Key? key, this.review}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();
  final userController = Get.find<UserController>();
  final utilService = Get.find<UtilService>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<User>>(
        future: firestoreService.getUser(review!.userID!),
        builder: (context, AsyncSnapshot<DocumentSnapshot<User>> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            User user = snapshot.requireData.data()!;
            return Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      CachedImage(url: user.photoURL!, circular: true, height: 45),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(user.name!, style: const TextStyle(color: Colors.white)),
                                // if (user.userID == userController.currentUser.value.userID)
                                //   Row(
                                //     children: [
                                //       InkWell(
                                //         onTap: () {
                                //           utilService.showConfirmationDialog(
                                //             title: 'Delete Review',
                                //             contentText: 'Are you sure you want to delete this review?',
                                //           );
                                //         },
                                //         child: Icon(Icons.delete_forever, size: 25),
                                //       ),
                                //       InkWell(
                                //         onTap: () {},
                                //         child: Icon(Icons.edit, size: 25),
                                //       ),
                                //     ],
                                //   ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RatingBarIndicator(
                                  rating: review!.rating!.toDouble(),
                                  itemBuilder: (context, index) => const Icon(FontAwesomeIcons.solidStar, color: primaryColor),
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.all(3),
                                  itemSize: 15,
                                ),
                                Text(
                                  timeago.format(review!.createdDate!.toDate()),
                                  style: const TextStyle(color: Colors.grey),
                                  textScaleFactor: 0.9,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          review!.comment!,
                          textAlign: TextAlign.justify,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
