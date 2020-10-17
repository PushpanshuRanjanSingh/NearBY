import 'package:NearBY/Screens/Register/components/otpBackground.dart';
import 'package:flutter/material.dart';

class OTPHandler extends StatelessWidget {
  final String username;
  final String email;
  final String password;
  final String otp;

  const OTPHandler({Key key, this.username, this.email, this.password, this.otp})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
        return Scaffold(
        body: OTPBackground(
      username: username,
      email: email,
      password: password,
      otp: otp,
    ));
  }
}
