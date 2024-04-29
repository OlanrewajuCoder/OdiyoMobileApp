import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/screens/home/home_page.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';

class SetPreferences extends StatefulWidget {
  const SetPreferences({Key? key}) : super(key: key);

  @override
  State<SetPreferences> createState() => _SetPreferencesState();
}

class _SetPreferencesState extends State<SetPreferences> {
  final firestoreService = Get.find<FirestoreService>();
  final userController = Get.find<UserController>();
  RxList selectedChoices = [].obs;
  int defaultChoiceIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              DelayedDisplay(
                delay: const Duration(milliseconds: 250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome', textScaleFactor: 1.2, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text('Find out what you are looking for', textScaleFactor: 2),
                    const SizedBox(height: 20),
                    Text('Choose the topics you like and we will recommend you the content that relates to your choices', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Expanded(
                child: DelayedDisplay(
                  delay: const Duration(milliseconds: 500),
                  child: SingleChildScrollView(
                    child: Obx(() {
                      return Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: List.generate(categories.length, (index) {
                          return ChoiceChip(
                            labelPadding: const EdgeInsets.all(2.0),
                            label: Text(categories[index]),
                            selected: selectedChoices.contains(categories[index]),
                            selectedColor: primaryColor,
                            onSelected: (item) => selectedChoices.contains(categories[index]) ? selectedChoices.remove(categories[index]) : selectedChoices.add(categories[index]),
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              DelayedDisplay(
                delay: const Duration(milliseconds: 750),
                child: Center(
                  child: InkWell(
                    onTap: () async {
                      userController.currentUser.value.preferences = selectedChoices;
                      await firestoreService.editUser(userController.currentUser.value);
                      Get.offAll(() => HomePage());
                    },
                    child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.arrow_forward, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
