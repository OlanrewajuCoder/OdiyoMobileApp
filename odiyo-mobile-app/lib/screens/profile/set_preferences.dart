import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';

class MyDialog extends StatefulWidget {
  const MyDialog({
    Key? key,
    required this.cities,
    required this.selectedCities,
    required this.onSelectedCitiesListChanged,
  }) : super(key: key);

  final List cities;
  final List selectedCities;
  final ValueChanged onSelectedCitiesListChanged;

  @override
  MyDialogState createState() => MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  List _tempSelectedCities = [];

  @override
  void initState() {
    _tempSelectedCities = widget.selectedCities;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'Set Preferences',
              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: widget.cities.length,
                itemBuilder: (BuildContext context, int index) {
                  final cityName = widget.cities[index];
                  return CheckboxListTile(
                      title: Text(cityName),
                      value: _tempSelectedCities.contains(cityName),
                      onChanged: (bool? value) {
                        if (value!) {
                          if (!_tempSelectedCities.contains(cityName)) {
                            setState(() {
                              _tempSelectedCities.add(cityName);
                            });
                          }
                        } else {
                          if (_tempSelectedCities.contains(cityName)) {
                            setState(() {
                              _tempSelectedCities.removeWhere((city) => city == cityName);
                            });
                          }
                        }
                        widget.onSelectedCitiesListChanged(_tempSelectedCities);
                      });
                }),
          ),
          InkWell(
            onTap: () async {
              Get.back();
              final firestoreService = Get.find<FirestoreService>();

              final userController = Get.find<UserController>();

              final utilService = Get.find<UtilService>();

              utilService.showLoading();
              userController.currentUser.value.preferences = _tempSelectedCities;
              await firestoreService.editUser(userController.currentUser.value);
              Get.back();
              showGreenAlert('Preferences updated successfully');
            },
            child: const CircleAvatar(backgroundColor: primaryColor, radius: 35, child: Icon(Icons.arrow_forward, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
