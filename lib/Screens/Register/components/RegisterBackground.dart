import 'package:NearBY/Function/functions.dart';
import 'package:NearBY/Screens/Login/loginPage.dart';
import 'package:NearBY/Screens/Register/components/Background.dart';
import 'package:NearBY/Screens/Register/otpHandler.dart';
import 'package:NearBY/colors.dart';
import 'package:NearBY/widget/AlreadyHaveAccountCheck.dart';
import 'package:NearBY/widget/roundedButton.dart';
import 'package:NearBY/widget/roundedInputField.dart';
import 'package:NearBY/widget/roundedPasswordInputField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RegisterBackground extends StatefulWidget {
  final Widget child;

  const RegisterBackground({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _RegisterBackgroundState createState() => _RegisterBackgroundState();
}

class _RegisterBackgroundState extends State<RegisterBackground> {
  bool _textfieldcheck = false;
  bool _textfieldfail = false;
  TextEditingController username;
  TextEditingController password;
  TextEditingController email;

  @override
  void initState() {
    _textfieldfail = false;
    _textfieldcheck = false;
    username = new TextEditingController();
    email = new TextEditingController();
    password = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    username?.dispose();
    email?.dispose();
    password?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String otp;

    textFieldCheck({String username, String password, String email}) {
      if (username.length > 1 && password.length > 7 && email.contains('@')) {
        otp = otpGenerate();
        sendMail(otp, email);
        print("$otp $email");
        setState(() {
          _textfieldcheck = true;
        });
      } else {
        setState(() {
          _textfieldfail = true;
        });
      }
    }

    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Register",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            SizedBox(height: size.height * 0.03),
            _textfieldfail
                ? Text(
                    "any field is invalid",
                    style: TextStyle(color: Colors.red[300]),
                  )
                : Text(''),
            RoundedInputField(
              hintText: "username",
              controller: username,
            ),
            RoundedInputField(
              icon: Icons.email,
              hintText: "email",
              controller: email,
            ),
            RoundedPasswordInput(
              hint: "password ",
              controller: password,
            ),
            Container(child: Text("password contains 8 characters", textAlign: TextAlign.start, style: TextStyle(color: Colors.grey),)),
            SizedBox(height: size.height * 0.02),
            RoundedButton(
                btnColor: LightCoral,
                text: "Register",
                textColor: BabyPowder,
                press: () {
                  print("${username.text}, ${email.text}, ${password.text}");
                  textFieldCheck(
                    email: email.text,
                    password: password.text,
                    username: username.text,
                  );
                  _textfieldcheck
                      ? Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) => OTPHandler(
                                    email: email.text,
                                    password: password.text,
                                    username: username.text,
                                    otp: otp,
                                  )),
                          (Route<dynamic> route) => false)
                      // ignore: unnecessary_statements
                      : () {};
                }),
            SizedBox(height: size.height * 0.01),
            AlreadyHaveAccountCheck(
              login: false,
              press: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
