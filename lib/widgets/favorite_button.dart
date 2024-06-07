import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/favorites_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';

class FavoriteButton extends StatelessWidget {
  final String audioBookID;

  FavoriteButton({Key? key, required this.audioBookID}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();
  final userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Favorite>>(
      stream: firestoreService.checkIfFavorite(audioBookID),
      builder: (context, AsyncSnapshot<DocumentSnapshot<Favorite>> snapshot) {
        if (snapshot.hasData) {
          return IconButton(
            onPressed: () async {
              !snapshot.data!.exists ? await firestoreService.addToFavorites(Favorite(userID: userController.currentUser.value.userID, audioBookID: audioBookID, createdDate: Timestamp.now())) : await firestoreService.removeFromFavorites(audioBookID);
            },
            icon: Icon(
              snapshot.data!.exists ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: !snapshot.data!.exists ? Colors.white : redColor,
              size: 20,
            ),
          );
        } else {
          return IconButton(
            icon: const Icon(FontAwesomeIcons.heart, color: Colors.white, size: 20),
            onPressed: () {},
          );
        }
      },
    );
  }
}
