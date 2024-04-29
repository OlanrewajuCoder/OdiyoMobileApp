import 'package:flutter/material.dart';
import 'package:odiyo/utils/constants.dart';
import 'package:odiyo/widgets/empty_box.dart';

class Notifications extends StatelessWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: lightLinearGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(
          child: EmptyBox(text: 'You are all caught up!'),
        ),
      ),
    );
  }
}
