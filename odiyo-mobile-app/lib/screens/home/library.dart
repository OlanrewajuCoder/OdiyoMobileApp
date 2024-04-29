import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:odiyo/screens/audiobooks/my_books.dart';
import 'package:odiyo/screens/profile/favorites.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/widgets/custom_list_tile.dart';

class Library extends StatelessWidget {
  Library({Key? key}) : super(key: key);

  final firestoreService = Get.find<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomListTile(
          leading: const Icon(FontAwesomeIcons.heart, color: Colors.white70),
          title: const Text('Favorites', style: TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: () => Get.to(() => const Favorites()),
        ),
        CustomListTile(
          leading: const Icon(Icons.list_alt_outlined, color: Colors.white70),
          title: const Text('My books', style: TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: () => Get.to(() => MyBooks()),
        ),
      ],
    );
  }
}
