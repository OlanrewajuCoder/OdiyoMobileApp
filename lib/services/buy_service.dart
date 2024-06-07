// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nanoid/async.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/payment_method_model.dart';
import 'package:odiyo/models/transactions_model.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:uuid/uuid.dart';

import 'cloud_function.dart';

class BuyService {
  final utilService = Get.find<UtilService>();
  final firestoreService = Get.find<FirestoreService>();
  final userController = Get.find<UserController>();
  late Map<String, dynamic> paymentIntentData;
  String stripeCustomerID = '';
  String stripeCustomerEphemeralKey = '';
  MyTransaction? transaction;

  processPayment({String? audioBookID, num? total}) async {
    try {
      http.Response response;
      Map data;
      utilService.showLoading();

      //Step 1 : Get Publishable Key
      response = await http.get(Uri.parse('https://us-central1-odiyo-c8b62.cloudfunctions.net/odiyo/pub-key'));
      data = json.decode(response.body);
      Stripe.publishableKey = data['publishable_key'];

      //Step 2 : Get Customer ID
      if (userController.currentUser.value.stripeCustomerID == '') {
        Map<String, String> header = {"Content-Type": "application/json"};
        Map params = {'full_name': userController.currentUser.value.name, 'email': userController.currentUser.value.email};
        response = await http.post(Uri.parse('https://us-central1-odiyo-c8b62.cloudfunctions.net/odiyo/create-customer'), body: json.encode(params), headers: header);
        data = json.decode(response.body);
        stripeCustomerID = data['stripe_customer_id'];
        userController.currentUser.value.stripeCustomerID = stripeCustomerID;
        await firestoreService.editUser(userController.currentUser.value);
      } else {
        stripeCustomerID = userController.currentUser.value.stripeCustomerID!;
      }

      //Step 3 : Get Payment Intent
      Map<String, String> header = {"Content-Type": "application/json"};
      Map params = {'amount': total! * 100, 'customer_id': stripeCustomerID, 'email': userController.currentUser.value.email};
      response = await http.post(Uri.parse('https://us-central1-odiyo-c8b62.cloudfunctions.net/odiyo/stripePI'), body: json.encode(params), headers: header);
      data = json.decode(response.body);
      paymentIntentData = data['paymentIntent'];
      stripeCustomerEphemeralKey = data['ephemeralKey'];

      //Step 4 :Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'ODIYO',
          customerId: stripeCustomerID,
          customerEphemeralKeySecret: stripeCustomerEphemeralKey,
        ),
      );

      // Step 5 : Display Payment Sheet
      bool success = await displayPaymentSheet(audioBookID!, total);

      if (!success) {
        Get.back();
      }
      // Step 6 : Store booking data and transaction
      if (success) {
        // await makePayment(bookingID);
        await firestoreService.addTransaction(transaction!);
      }

      // Step 7 : Send notification
      if (success) {
        //final formatCurrency = NumberFormat.simpleCurrency();
        //Send notification here
        Get.back();
        Get.back();
        showGreenAlert('Audiobook unlocked. Payment successful');
      }
    } catch (e) {
      Get.back();
      showRedAlert(e.toString());
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> displayPaymentSheet(String audioBookID, num total) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      final postPaymentIntent = await Stripe.instance.retrievePaymentIntent(paymentIntentData['client_secret']);
      if (postPaymentIntent.status == PaymentIntentsStatus.Succeeded) {
        transaction = MyTransaction(
          userID: userController.currentUser.value.userID,
          transactionID: const Uuid().v1(),
          transactionRef: await customAlphabet('1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ', 6),
          audioBookID: audioBookID,
          stripeCustomerID: stripeCustomerID,
          stripePaymentID: postPaymentIntent.id,
          stripeRefundID: '',
          notes: '',
          stripeChargeID: '',
          receiptID: '',
          paymentMethod: 'card',
          type: 'payment',
          amount: total,
          createdDate: Timestamp.now(),
        );
        return true;
      } else {
        return false;
      }
    } on StripeException catch (e) {
      Get.back();
      showRedAlert(e.toString());
      debugPrint(e.toString());
      return false;
    }
  }

  Future<PaymentMethodsList> getCards() async {
    stripeCustomerID = userController.currentUser.value.stripeCustomerID!;
    var response = await getMethod('list-cards?customer_id=$stripeCustomerID', {});
    final data = json.decode(response.body);
    debugPrint('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    debugPrint(data.toString());
    return PaymentMethodsList.fromJson(data);
  }

  addCard(Map parameters) async {
    var response = await postMethod('stripe-add-card', parameters);
    final data = json.decode(response.body);
    debugPrint('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    debugPrint(data.toString());
    return data;
  }

  removeCard(Map parameters) async {
    var response = await postMethod('stripe-remove-card', parameters);
    final data = json.decode(response.body);
    debugPrint('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
    debugPrint(data.toString());
    return data;
  }
}
