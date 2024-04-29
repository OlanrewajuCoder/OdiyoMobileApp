import 'dart:io';

import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:odiyo/models/users_model.dart';
import 'package:odiyo/screens/auth/login.dart';
import 'package:odiyo/services/authentication_service.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final utilService = Get.find<UtilService>();
  final authService = Get.find<AuthService>();
  final firestoreService = Get.find<FirestoreService>();
  final TextEditingController nameTEC = TextEditingController();
  final TextEditingController emailTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(),
        body: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Hero(tag: 'logo', child: Image.asset('assets/images/only_logo.png', height: Get.width / 2.75, fit: BoxFit.contain)),
                            const Text('ODIYO', textScaleFactor: 2, style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            children: [
                              const SizedBox(height: 50),
                              DelayedDisplay(
                                delay: const Duration(milliseconds: 250),
                                child: CustomTextField(controller: nameTEC, prefix: const Icon(Icons.person_outline_rounded, color: Colors.grey), label: '', hint: 'Enter full name', validate: true),
                              ),
                              const SizedBox(height: 30),
                              DelayedDisplay(
                                delay: const Duration(milliseconds: 250),
                                child: CustomTextField(controller: emailTEC, prefix: const Icon(Icons.alternate_email, color: Colors.grey), label: '', hint: 'Enter email address', validate: true, isEmail: true, textInputType: TextInputType.emailAddress),
                              ),
                              const SizedBox(height: 30),
                              DelayedDisplay(
                                delay: const Duration(milliseconds: 250),
                                child: CustomTextField(controller: passwordTEC, prefix: const Icon(Icons.lock_outline_rounded, color: Colors.grey), label: '', hint: 'Enter password', validate: true, isPassword: true, textInputType: TextInputType.text),
                              ),
                              const SizedBox(height: 20),
                              DelayedDisplay(
                                delay: const Duration(milliseconds: 500),
                                child: TextButton(onPressed: () => Get.off(() => const Login(), transition: Transition.circularReveal), child: const Text('Sign In?')),
                              ),
                              const SizedBox(height: 10),
                              DelayedDisplay(
                                delay: const Duration(milliseconds: 500),
                                child: InkWell(onTap: () => signUp(), child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.arrow_forward, color: Colors.white))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              DelayedDisplay(
                delay: const Duration(milliseconds: 750),
                child: Column(
                  children: [
                    const Text('Or sign up using'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(onTap: () => authService.signInWithGoogle(false), child: socialLoginButton(FontAwesomeIcons.googlePlusG)),
                        if (Platform.isIOS) InkWell(onTap: () => authService.signInWithApple(false), child: socialLoginButton(FontAwesomeIcons.apple)),
                        InkWell(onTap: () => authService.signInWithFacebook(false), child: socialLoginButton(FontAwesomeIcons.facebookF)),
                        InkWell(onTap: () => authService.signInWithTwitter(false), child: socialLoginButton(FontAwesomeIcons.twitter)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  socialLoginButton(IconData iconData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      height: 50,
      width: 50,
      decoration: BoxDecoration(color: secondaryColor, border: Border.all(color: lightBackgroundColor), borderRadius: BorderRadius.circular(50)),
      child: Icon(iconData, color: Colors.grey),
    );
  }

  signUp() async {
    if (!formKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    }
    final miscService = Get.find<UtilService>();
    Get.defaultDialog(
      titlePadding: const EdgeInsets.only(top: 10),
      contentPadding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
      title: 'Create Account',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('By signing up, you accept the Terms & Conditions of use of this app.'),
          InkWell(
            onTap: () => miscService.openLink('https://soundojo.com'),
            child: const Text('Know more', textScaleFactor: 0.95, maxLines: 2, style: TextStyle(color: primaryColor, decoration: TextDecoration.underline)),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(onTap: () => Get.back(), child: const CircleAvatar(backgroundColor: backgroundColor, radius: 35, child: Icon(Icons.close, color: Colors.white))),
              InkWell(
                  onTap: () async {
                    Get.back();
                    utilService.showLoading();
                    final FirebaseMessaging messaging = FirebaseMessaging.instance;
                    if (Platform.isIOS) await messaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);
                    String? token = await messaging.getToken();
                    await authService.signUp(User(userID: const Uuid().v1(), email: emailTEC.text.toLowerCase(), name: nameTEC.text, token: token!, photoURL: '', unreadNotifications: false, preferences: []), passwordTEC.text);
                  },
                  child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.check, color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }
}
