import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final Function? onTap;
  final double? marginBottom;

  const CustomListTile({Key? key, this.leading, this.title, this.trailing, this.onTap, this.marginBottom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: EdgeInsets.only(bottom: marginBottom ?? 15),
      child: InkWell(
        onTap: () => onTap!(),
        child: Row(
          children: [
            Expanded(flex: 10, child: leading ?? Container()),
            Expanded(flex: 30, child: title ?? Container()),
            Flexible(flex: 15, child: Container(padding: const EdgeInsets.only(right: 15), alignment: Alignment.centerRight, child: trailing ?? Container())),
          ],
        ),
      ),
    );
  }
}
