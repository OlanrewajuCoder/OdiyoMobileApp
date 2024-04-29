import 'dart:io';

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:odiyo/screens/auth/forgot_password.dart';
import 'package:odiyo/screens/auth/signup.dart';
import 'package:odiyo/services/authentication_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/custom_text_field.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final utilService = Get.find<UtilService>();
  final authService = Get.find<AuthService>();
  final miscService = Get.find<UtilService>();
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(onPressed: () => Get.to(() => ForgotPassword()), child: const Text('Forgot Password?')),
                                    const SizedBox(height: 40),
                                    TextButton(onPressed: () => Get.off(() => const SignUp(), transition: Transition.circularReveal), child: const Text('Sign Up?')),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              DelayedDisplay(
                                delay: const Duration(milliseconds: 500),
                                child: InkWell(onTap: () => login(), child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.arrow_forward, color: Colors.white))),
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
                    const Text('Or sign in using'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(onTap: () => authService.signInWithGoogle(true), child: socialLoginButton(FontAwesomeIcons.googlePlusG)),
                        if (Platform.isIOS) InkWell(onTap: () => authService.signInWithApple(true), child: socialLoginButton(FontAwesomeIcons.apple)),
                        InkWell(onTap: () => authService.signInWithFacebook(true), child: socialLoginButton(FontAwesomeIcons.facebookF)),
                        InkWell(onTap: () => authService.signInWithTwitter(true), child: socialLoginButton(FontAwesomeIcons.twitter)),
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

  login() async {
    if (!formKey.currentState!.validate()) {
      return showRedAlert('Please fill the necessary details');
    }

    utilService.showLoading();
    await authService.signIn(emailTEC.text.toLowerCase(), passwordTEC.text);
  }
}
