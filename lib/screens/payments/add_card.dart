import 'package:flutter/material.dart' hide Card;
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:get/get.dart';
import 'package:odiyo/controllers/user_controller.dart';
import 'package:odiyo/models/users_model.dart';
import 'package:odiyo/services/buy_service.dart';
import 'package:odiyo/services/firestore_service.dart';
import 'package:odiyo/services/util_service.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/custom_button.dart';

class AddCard extends StatefulWidget {
  const AddCard({Key? key}) : super(key: key);

  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  final userController = Get.find<UserController>();
  final dialogService = Get.find<UtilService>();
  final userService = Get.find<FirestoreService>();
  final bookingService = Get.find<BuyService>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late CreditCardModel creditCardModel;
  bool isDefaultCard = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: linearGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('CARDS')),
        body: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
              isHolderNameVisible: true,
              cardBgColor: primaryColor,
              isSwipeGestureEnabled: true,
              onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true,
                      obscureNumber: true,
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      isHolderNameVisible: true,
                      isCardNumberVisible: true,
                      isExpiryDateVisible: true,
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                      themeColor: primaryColor,
                      textColor: Colors.white,
                      cardNumberDecoration: decoration(
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      expiryDateDecoration: decoration(
                        labelText: 'Expiry Date',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: decoration(
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: decoration(
                        labelText: 'Card Holder Name',
                        hintText: 'Card Holder Name',
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CheckboxListTile(
                        value: isDefaultCard,
                        onChanged: (val) =>
                            setState(() => isDefaultCard = val!),
                        title: const Text(
                            'Set this card as your default payment method')),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: CustomButton(
                        text: 'Add Card',
                        function: () async {
                          if (formKey.currentState!.validate()) {
                            Map params = {
                              'number': creditCardModel.cardNumber,
                              'exp_month':
                                  creditCardModel.expiryDate.substring(0, 2),
                              'exp_year':
                                  creditCardModel.expiryDate.substring(3, 5),
                              'cvc': creditCardModel.cvvCode,
                              'customer_id': userController
                                  .currentUser.value.stripeCustomerID,
                            };
                            dialogService.showLoading();
                            var response = await bookingService.addCard(params);
                            Get.back();
                            if (response['success']) {
                              showGreenAlert(response['message']);
                              if (isDefaultCard) {
                                User user = userController.currentUser.value;
                                user.paymentID = response['data']['id'];
                                await userService.editUser(user);
                              }
                            } else {
                              showRedAlert(response['message']);
                            }
                            Get.back();
                            Get.back();
                          } else {
                            print('invalid!');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  decoration({required String labelText, required String hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: inputBorder(lightBackgroundColor),
      focusedBorder: inputBorder(lightBackgroundColor),
      enabledBorder: inputBorder(lightBackgroundColor),
      errorBorder: inputBorder(lightBackgroundColor),
      disabledBorder: inputBorder(lightBackgroundColor),
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: secondaryColor,
      contentPadding: const EdgeInsets.only(left: 20),
    );
  }

  inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(width: 1, color: color),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCard) {
    setState(() {
      creditCardModel = creditCard;
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
