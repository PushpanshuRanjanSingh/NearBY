import 'package:NearBY/widget/textFieldContainer.dart';
import 'package:flutter/material.dart';

class RoundedPasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool secure;
  final Icon icon;
  final Function toggle;
  const RoundedPasswordInput(
      {Key key, this.hint, this.controller, this.secure, this.icon, this.toggle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: secure,
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          icon: Icon(
            Icons.lock,
            color: Colors.white,
          ),
          suffixIcon: IconButton(
            icon: icon,
            color: Colors.white,
            splashColor: Colors.transparent,
            onPressed: toggle,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
