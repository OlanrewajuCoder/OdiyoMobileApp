import 'dart:convert';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';

final dialogService = Get.find<UtilService>();

cloudFunction({
  required String functionName,
  required Map parameters,
  required Function action,
}) async {
  dialogService.showLoading();
  try {
    HttpsCallable addVoucherCall =
        FirebaseFunctions.instance.httpsCallable(functionName);
    HttpsCallableResult results = await addVoucherCall(parameters);
    Get.back(); //closes loading dialog;
    action();
    if (results.data['success'] == false) {
      showRedAlert(results.data['message']);
    } else {
      showGreenAlert(results.data['message']);
    }
    return;
  } catch (e) {
    Get.back();
    showRedAlert('Something went wrong. Please try again');
    return false;
  }
}

cloudFunctionValueReturn({
  required String functionName,
  required Map parameters,
}) async {
  dialogService.showLoading();
  try {
    HttpsCallable addVoucherCall =
        FirebaseFunctions.instance.httpsCallable(functionName);
    HttpsCallableResult results = await addVoucherCall(parameters);
    Get.back(); //closes loading dialog;
    return results;
  } catch (e) {
    Get.back();
    showRedAlert('Something went wrong. Please try again');
  }
}

Future<Map> callFunction(String url) async {
  var response = await http.get(Uri.parse(url));
  //Map data = json.decode(response.body);
  printWrapped(response.body);
  return json.decode(response.body);
}

printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

getMethod(String url, Map params) async {
  try {
    Map<String, String> header = {"Content-Type": "application/json"};
    var response = await http.get(
        Uri.parse('https://us-central1-odiyo-c8b62.cloudfunctions.net/odiyo/$url'),
        headers: header);
    log(response.body);
    return response;
  } catch (e) {
    printWrapped(e.toString());
  }
}

postMethod(String url, Map params) async {
  try {
    Map<String, String> header = {"Content-Type": "application/json"};
    var response = await http.post(
        Uri.parse('https://us-central1-odiyo-c8b62.cloudfunctions.net/odiyo/$url'),
        body: json.encode(params),
        headers: header);
    debugPrint(response.body);
    return response;
  } catch (e) {
    printWrapped(e.toString());
  }
}
