import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/services/authentication_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/custom_text_field.dart';

class ForgotPassword extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final utilService = Get.find<UtilService>();
  final authService = Get.find<AuthService>();
  final TextEditingController emailTEC = TextEditingController();

  ForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Container(
        decoration: const BoxDecoration(gradient: linearGradient),
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Forgot Password', textScaleFactor: 2, style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 30),
                  DelayedDisplay(
                    delay: const Duration(milliseconds: 250),
                    child: CustomTextField(controller: emailTEC, prefix: const Icon(Icons.alternate_email, color: Colors.grey), label: '', hint: 'Enter email address', validate: true, isEmail: true, textInputType: TextInputType.emailAddress),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DelayedDisplay(
                        delay: const Duration(milliseconds: 500),
                        child: InkWell(onTap: () => Get.back(), child: const CircleAvatar(backgroundColor: lightBackgroundColor, radius: 35, child: Icon(Icons.arrow_back, color: Colors.white))),
                      ),
                      DelayedDisplay(
                        delay: const Duration(milliseconds: 500),
                        child: InkWell(
                            onTap: () async {
                              if (emailTEC.text.isEmpty) {
                                showRedAlert('Please enter your email address');
                              } else {
                                await authService.resetPassword(emailTEC.text);
                              }
                            },
                            child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.arrow_forward, color: Colors.white))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
