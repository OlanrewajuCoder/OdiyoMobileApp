import 'package:flutter/material.dart';
import 'package:odiyo/utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Color? color;
  final Function? function;
  final bool? showShadow;
  final Widget? icon;
  final Color? textColor;

  const CustomButton({Key? key, this.text, this.function, this.color, this.showShadow, this.icon, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => function!(),
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: color ?? primaryColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                child: icon,
              ),
            Center(
              child: Text(
                text!,
                style: TextStyle(color: textColor ?? Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                textScaleFactor: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
