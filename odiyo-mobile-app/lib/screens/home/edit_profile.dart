import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/users_model.dart';
import 'package:odiyo/services/authentication_service.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/storage_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/cached_image.dart';
import 'package:odiyo/widgets/custom_text_field.dart';

class EditProfile extends StatefulWidget {
  final User? user;

  const EditProfile({Key? key, this.user}) : super(key: key);

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final TextEditingController nameTEC = TextEditingController();
  final TextEditingController passwordTEC = TextEditingController();
  final TextEditingController confirmTEC = TextEditingController();
  final TextEditingController emailTEC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passwordKey = GlobalKey<FormState>();
  final firestoreService = Get.find<FirestoreService>();
  final storageService = Get.find<StorageService>();
  final userController = Get.find<UserController>();
  final authService = Get.find<AuthService>();
  final utilService = Get.find<UtilService>();

  Rx<File> image = File('').obs;
  int defaultChoiceIndex = 0;

  bool checkboxValueCity = false;

  @override
  void initState() {
    nameTEC.text = userController.currentUser.value.name!;
    emailTEC.text = userController.currentUser.value.email!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: lightLinearGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Obx(() => CircleAvatar(radius: 80, backgroundColor: primaryColor, child: CachedImage(url: userController.currentUser.value.photoURL, height: 150, circular: true))),
              TextButton(
                onPressed: () async {
                  image.value = await storageService.pickImage();
                  if (image.value.path.isNotEmpty) {
                    utilService.showLoading();
                    String url = await storageService.uploadPhoto(image.value, 'profile');
                    userController.currentUser.value.photoURL = url;
                    await firestoreService.editUser(userController.currentUser.value);
                    Get.back();
                    showGreenAlert('Profile Photo updated');
                  }
                },
                child: const Text('Change Photo', textScaleFactor: 1.15, style: TextStyle(decoration: TextDecoration.underline, color: primaryColor)),
              ),
              const Divider(height: 50),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    const Text('Update Details', textScaleFactor: 1.25),
                    const SizedBox(height: 30),
                    CustomTextField(controller: nameTEC, prefix: const Icon(Icons.person_outline_rounded, color: Colors.grey), label: '', hint: 'Enter full name', validate: true),
                    const SizedBox(height: 30),
                    CustomTextField(controller: emailTEC, prefix: const Icon(Icons.alternate_email, color: Colors.grey), label: '', hint: 'Enter email address', validate: true, isEmail: true, textInputType: TextInputType.emailAddress, enabled: false),
                    const SizedBox(height: 30),
                    InkWell(onTap: () => update(), child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.arrow_forward, color: Colors.white))),
                  ],
                ),
              ),
              const Divider(height: 50),
              Form(
                key: passwordKey,
                child: Column(
                  children: [
                    const Text('Update Password', textScaleFactor: 1.25),
                    const SizedBox(height: 30),
                    CustomTextField(controller: passwordTEC, prefix: const Icon(Icons.lock_outline_sharp, color: Colors.grey), label: '', hint: 'Enter password', validate: true, isPassword: true, textInputType: TextInputType.text),
                    const SizedBox(height: 30),
                    CustomTextField(controller: confirmTEC, prefix: const Icon(Icons.lock_outline_sharp, color: Colors.grey), label: '', hint: 'Re-enter password', validate: true, isPassword: true, textInputType: TextInputType.text),
                    const SizedBox(height: 30),
                    InkWell(onTap: () => changePassword(), child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.arrow_forward, color: Colors.white))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  update() async {
    if (!formKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    }
    utilService.showLoading();
    userController.currentUser.value.name = nameTEC.text;
    await firestoreService.editUser(userController.currentUser.value);
    Get.back();
    showGreenAlert('Profile Details updated');
  }

  changePassword() async {
    if (!passwordKey.currentState!.validate()) {
      showRedAlert('Please fill the necessary details');
      return;
    }
    if (passwordTEC.text != confirmTEC.text) {
      showRedAlert('Passwords do not match');
      return;
    }
    utilService.showLoading();
    authService.changePassword(passwordTEC.text.trim());
  }
}
