import 'package:flutter/material.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/custom_button.dart';

class Membership extends StatelessWidget {
  const Membership({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: lightLinearGradient),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Membership'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Membership status', style: TextStyle(color: Colors.white)),
                        Text('Monthly', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Expiry Date', style: TextStyle(color: Colors.white)),
                        Text('01 August 2022', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: lightBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: const [
                    Text('Benefits of Paid Membership', style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.check, color: primaryColor),
                      title: Text(
                        'Access to all free and premium books.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.check, color: primaryColor),
                      title: Text(
                        'Ad-free experience on any platform.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.check, color: primaryColor),
                      title: Text(
                        'Exclusive content from hand-picked creators.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.check, color: primaryColor),
                      title: Text(
                        'Cancel anytime without any charges.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 50),
              const Text('Select a Membership Plan', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 25),
              ListTile(
                selectedTileColor: lightBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                selected: false,
                leading: const Icon(Icons.radio_button_off, color: primaryColor),
                title: const Text(
                  'Paid : \$1.99 per month',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ListTile(
                selectedTileColor: lightBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                selected: false,
                leading: const Icon(Icons.radio_button_off, color: primaryColor),
                title: const Text(
                  'Paid : \$5.99 per quarter',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ListTile(
                selectedTileColor: lightBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                selected: false,
                leading: const Icon(Icons.radio_button_off, color: primaryColor),
                title: const Text(
                  'Paid : \$19.99 per year',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              const CustomButton(text: 'Become a member'),
            ],
          ),
        ),
      ),
    );
  }
}
