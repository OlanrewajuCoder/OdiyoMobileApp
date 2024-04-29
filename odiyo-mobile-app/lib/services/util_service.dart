import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/audio_book_model.dart';
import 'package:odiyo/screens/auth/login.dart';
import 'package:odiyo/services/buy_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/custom_button.dart';
import 'package:odiyo/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilService {
  openLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch URL';
    }
  }

  showLoading() {
    Get.defaultDialog(
      backgroundColor: secondaryColor,
      titlePadding: const EdgeInsets.all(10),
      contentPadding: const EdgeInsets.all(10),
      barrierDismissible: false,
      title: 'Please wait...',
      content: const LoadingData(),
    );
  }

  showConfirmationDialog({String? title, String? contentText, String? confirmText, String? cancelText, Function? cancel, Function? confirm}) {
    Get.defaultDialog(
      title: title!,
      content: Text(contentText!),
      actions: [
        CustomButton(
          text: confirmText ?? 'Yes',
          color: primaryColor,
          function: () {
            if (confirm == null) {
              Get.back();
            } else {
              confirm();
            }
          },
        ),
        CustomButton(
          text: cancelText ?? 'No',
          color: Colors.grey,
          function: () {
            if (cancel == null) {
              Get.back();
            } else {
              cancel();
            }
          },
        ),
      ],
    );
  }

  showBuyDialog(AudioBook audioBook) {
    Get.defaultDialog(
      backgroundColor: lightBackgroundColor,
      titleStyle: const TextStyle(color: Colors.white),
      titlePadding: const EdgeInsets.only(top: 10),
      contentPadding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
      title: 'Buy the book?',
      content: Column(
        children: [
          const Text('This book is paid. Do you want to buy the book?'),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(onTap: () => Get.back(), child: const CircleAvatar(backgroundColor: backgroundColor, radius: 35, child: Icon(Icons.close, color: Colors.white))),
              InkWell(
                  onTap: () async {
                    Get.back();
                    final buyService = Get.find<BuyService>();
                    await buyService.processPayment(audioBookID: audioBook.audioBookID, total: audioBook.price);
                  },
                  child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.check, color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  logout() {
    Get.defaultDialog(
      title: 'Logout',
      content: const Text('Are you sure you want to logout?', textScaleFactor: 1),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel', textScaleFactor: 1)),
        TextButton(
            onPressed: () async {
              final u.FirebaseAuth auth = u.FirebaseAuth.instance;
              await auth.signOut();
              Get.back();
              Get.off(() => const Login());
            },
            child: const Text('Logout', textScaleFactor: 1)),
      ],
    );
  }
}
