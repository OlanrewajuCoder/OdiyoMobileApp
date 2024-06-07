import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/screens/auth/login.dart';
import 'package:odiyo/screens/home/home_page.dart';
import 'package:odiyo/services/authentication_service.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/player_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/utils/preferences.dart';
import 'package:odiyo/widgets/loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final firestoreService = Get.find<FirestoreService>();
  final userController = Get.find<UserController>();
  final playerService = Get.find<PlayerService>();
  final utilService = Get.find<UtilService>();
  final authService = Get.find<AuthService>();

  void handleTimeout() async {
    try {
      String userID = await Preferences.getUser();
      if (userID == '') {
        Get.offAll(() => const Login());
      } else {
        userController.currentUser.value = (await firestoreService.getUser(userID)).data()!;

        Get.offAll(() => HomePage());
      }
    } catch (e) {
      authService.signOut();
    }
  }

  startTimeout() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, handleTimeout);
  }

  @override
  void initState() {
    super.initState();
    startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(systemOverlayStyle: SystemUiOverlayStyle.light),
        body: Container(
          padding: const EdgeInsets.all(50),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 75),
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/images/only_logo.png',
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
              ),
              const SizedBox(height: 100),
              const LoadingData(),
            ],
          ),
        ),
      ),
    );
  }
}
