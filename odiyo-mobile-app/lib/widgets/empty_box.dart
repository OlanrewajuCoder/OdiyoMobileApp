import 'package:flutter/material.dart';

class EmptyBox extends StatelessWidget {
  final String? text;

  const EmptyBox({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/only_logo.png', height: 80),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(text!, textAlign: TextAlign.center, textScaleFactor: 1.25),
          ),
        ],
      ),
    );
  }
}
