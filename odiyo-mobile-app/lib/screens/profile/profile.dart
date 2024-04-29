import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/screens/auth/login.dart';
import 'package:odiyo/screens/home/edit_profile.dart';
import 'package:odiyo/screens/payments/list_cards.dart';
import 'package:odiyo/screens/profile/my_transactions.dart';
import 'package:odiyo/screens/profile/set_preferences.dart';
import 'package:odiyo/services/authentication_service.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/utils/preferences.dart';
import 'package:odiyo/widgets/cached_image.dart';
import 'package:odiyo/widgets/custom_list_tile.dart';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  final userController = Get.find<UserController>();
  final utilService = Get.find<UtilService>();
  final authService = Get.find<AuthService>();
  final firestoreService = Get.find<FirestoreService>();
  final RxList selectedChoices = [].obs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.black38,
            child: Column(
              children: [
                const SizedBox(height: 50),
                CircleAvatar(radius: 80, backgroundColor: primaryColor, child: CachedImage(url: userController.currentUser.value.photoURL, height: 150, circular: true)),
                const SizedBox(height: 15),
                Text(userController.currentUser.value.name!, textScaleFactor: 1.25, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('Freemium Member')),
                const SizedBox(height: 25),
                const Divider(height: 1),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white70),
            title: const Text('Edit Profile', style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => Get.to(() => const EditProfile()),
          ),
          CustomListTile(
            leading: const Icon(Icons.settings, color: Colors.white70),
            title: const Text('Set Preferences', style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () {
              selectedChoices.value = userController.currentUser.value.preferences!;
              showDialog(
                  context: context,
                  builder: (context) {
                    return MyDialog(
                        cities: categories,
                        // ignore: invalid_use_of_protected_member
                        selectedCities: selectedChoices.value,
                        onSelectedCitiesListChanged: (cities) {
                          selectedChoices.value = cities;
                        });
                  });
            },
          ),
          CustomListTile(
            leading: const Icon(Icons.list_alt_outlined, color: Colors.white70),
            title: const Text('Transactions', style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => Get.to(() => Transactions()),
          ),
          CustomListTile(
            leading: const Icon(Icons.payment, color: Colors.white70),
            title: const Text('Payment Methods', style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => Get.to(() => ListCards()),
          ),
          CustomListTile(
            leading: Icon(Icons.delete_forever, color: redColor),
            title: Text('Delete Account', style: TextStyle(color: redColor)),
            onTap: () async {
              Get.defaultDialog(
                titlePadding: const EdgeInsets.only(top: 10),
                contentPadding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
                title: 'Delete Account',
                content: const Text('Deleting your account will delete your profile data, library, favorites, transactions, purchases and preferences. You cannot undo this action.\n\nAre you sure you want to Delete your Account?'),
                confirm: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                ),
                cancel: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(redColor)),
                    onPressed: () async {
                      userController.currentUser.value.token = '';
                      userController.currentUser.value.name = 'Deleted User';
                      await firestoreService.editUser(userController.currentUser.value);
                      await Preferences.setUser('');
                      await authService.signOut();
                      Get.back();
                      Get.offAll(() => const Login());
                    },
                    child: const Text('Delete Account')),
              );
            },
          ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomButton(
          //         text: 'Show Jamaica Books',
          //         function: () {
          //           LocationService.country = 'Jamaica';
          //           Get.offAll(() => const SplashScreen());
          //         },
          //       ),
          //     ),
          //     Expanded(
          //       child: CustomButton(
          //         text: 'Show India Books',
          //         function: () {
          //           LocationService.country = 'India';
          //           Get.offAll(() => const SplashScreen());
          //         },
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
