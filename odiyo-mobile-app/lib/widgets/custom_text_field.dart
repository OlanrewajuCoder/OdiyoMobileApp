import 'package:flutter/material.dart';
import 'package:odiyo/utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final Color? labelColor;
  final int? maxLines;
  final bool? validate;
  final bool? isPassword;
  final bool? isEmail;
  final bool? enabled;
  final Widget? dropdown;
  final int? maxLength;
  final Widget? prefix;

  const CustomTextField({Key? key, this.hint, this.isEmail, this.label, this.controller, this.textInputType, this.labelColor, this.maxLines, this.validate, this.isPassword, this.enabled, this.dropdown, this.maxLength, this.prefix}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != '')
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 15),
            child: Text(label!, style: TextStyle(color: labelColor ?? primaryColor)),
          ),
        dropdown == null
            ? TextFormField(
                maxLength: maxLength ?? 250,
                enabled: enabled ?? true,
                obscureText: isPassword ?? false,
                maxLines: maxLines ?? 1,
                keyboardType: textInputType,
                textInputAction: (maxLines ?? 1) > 1 ? TextInputAction.newline : TextInputAction.next,
                onEditingComplete: () => node.nextFocus(),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => validate ?? false
                    ? isEmail ?? false
                        ? validateEmail(value!)
                        : validateText(value!)
                    : null,
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                decoration: maxLength == null
                    ? InputDecoration(
                        hintText: hint,
                        prefixIcon: prefix ?? Container(width: 0),
                        counterText: '',
                        contentPadding: (maxLines ?? 1) == 1 ? const EdgeInsets.symmetric(horizontal: 15) : const EdgeInsets.all(15),
                      )
                    : InputDecoration(
                        hintText: hint,
                        prefix: prefix ?? Container(width: 0),
                        contentPadding: (maxLines ?? 1) == 1 ? const EdgeInsets.symmetric(horizontal: 15) : const EdgeInsets.all(15),
                      ),
              )
            : dropdown!,
      ],
    );
  }

  validateEmail(String email) {
    if (email.isEmpty) {
      return "Email cannot be empty";
    }
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email) ? null : 'Invalid Email';
  }

  validateText(String text) {
    if (text.isEmpty) {
      return "Cannot be empty";
    }
  }
}
