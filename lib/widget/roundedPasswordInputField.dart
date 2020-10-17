import 'package:NearBY/widget/textFieldContainer.dart';
import 'package:flutter/material.dart';

class RoundedPasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const RoundedPasswordInput({
    Key key,
    this.hint,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: true,
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          icon: Icon(
            Icons.lock,
            color: Colors.white,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.visibility),
            color: Colors.white,
            onPressed: () => print('suffixIcon pressed'),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
