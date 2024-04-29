import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:odiyo/utils/constants.dart';

class LoadingData extends StatelessWidget {
  const LoadingData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.beat(color: primaryColor, size: 70),
    );
  }
}
