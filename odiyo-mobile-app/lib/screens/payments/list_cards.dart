import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/payment_method_model.dart' as card;
import 'package:odiyo/models/payment_method_model.dart';
import 'package:odiyo/models/users_model.dart';
import 'package:odiyo/services/buy_service.dart';
import 'package:odiyo/services/cloud_function.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/custom_button.dart';
import 'package:odiyo/widgets/empty_box.dart';
import 'package:odiyo/widgets/loading.dart';

import 'add_card.dart';

class ListCards extends StatelessWidget {
  final userController = Get.find<UserController>();
  final buyService = Get.find<BuyService>();

  ListCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('CARDS')),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<PaymentMethodsList>(
                  future: buyService.getCards(),
                  builder: (context, AsyncSnapshot<PaymentMethodsList> snapshot) {
                    if (snapshot.hasData) {
                      card.PaymentMethodsList payments = snapshot.data!;
                      return payments.paymentMethods!.data!.isNotEmpty
                          ? ListView.builder(
                              itemBuilder: (context, i) {
                                return Column(
                                  children: [
                                    CreditCardWidget(
                                      cardNumber: '0000 0000 0000 ${payments.paymentMethods!.data![i].card!.last4}',
                                      expiryDate: '${payments.paymentMethods!.data![i].card!.expMonth}/${payments.paymentMethods!.data![i].card!.expYear}',
                                      cardHolderName: userController.currentUser.value.name!,
                                      cardType: getCardType(payments.paymentMethods!.data![i].card!.brand!),
                                      cvvCode: '***',
                                      showBackView: false,
                                      obscureCardNumber: true,
                                      obscureCardCvv: true,
                                      isHolderNameVisible: true,
                                      cardBgColor: primaryColor,
                                      isSwipeGestureEnabled: false,
                                      onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Obx(() {
                                          return InkWell(
                                            onTap: () async {
                                              if (userController.currentUser.value.paymentID != payments.paymentMethods!.data![i].id) {
                                                final userService = Get.find<FirestoreService>();
                                                dialogService.showLoading();
                                                User user = userController.currentUser.value;
                                                user.paymentID = payments.paymentMethods!.data![i].id;
                                                await userService.editUser(user);
                                                Get.back();
                                                showGreenAlert('Default Card set successfully');
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(15, 0, 25, 20),
                                              child: Text(userController.currentUser.value.paymentID == payments.paymentMethods!.data![i].id ? 'DEFAULT CARD' : 'SET AS DEFAULT CARD', style: TextStyle(color: userController.currentUser.value.paymentID == payments.paymentMethods!.data![i].id ? Colors.green : redColor)),
                                            ),
                                          );
                                        }),
                                        InkWell(
                                          onTap: () => dialogService.showConfirmationDialog(
                                            title: 'Delete Card?',
                                            contentText: 'Are you sure you want to delete this card?',
                                            confirm: () async {
                                              Get.back();
                                              dialogService.showLoading();
                                              var response = await buyService.removeCard({'payment_method_id': payments.paymentMethods!.data![i].id});
                                              Get.back();
                                              Get.back();
                                              if (response['success']) {
                                                showGreenAlert(response['message']);
                                              } else {
                                                showRedAlert(response['message']);
                                              }
                                            },
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(15, 0, 25, 20),
                                            child: Text('DELETE', style: TextStyle(color: redColor)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                );
                              },
                              itemCount: payments.paymentMethods!.data!.length,
                            )
                          : const EmptyBox(text: 'No cards added yet.');
                    } else {
                      return const LoadingData();
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: CustomButton(text: 'Add a new Card', function: () => Get.off(() => AddCard())),
            ),
          ],
        ),
      ),
    );
  }

  getCardType(String brand) {
    if (brand == 'visa') return CardType.visa;
    if (brand == 'americanExpress') return CardType.americanExpress;
    if (brand == 'discover') return CardType.discover;
    if (brand == 'mastercard') return CardType.mastercard;
    return CardType.otherBrand;
  }
}
