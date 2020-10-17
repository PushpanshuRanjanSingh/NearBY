import 'package:NearBY/Screens/Login/loginPage.dart';
import 'package:NearBY/Screens/Register/registerPage.dart';
import 'package:NearBY/widget/roundedButton.dart';
import 'package:flutter/material.dart';
import 'background.dart';
import 'package:flutter_svg/svg.dart';
import 'package:NearBY/colors.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "NearBY",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            SvgPicture.asset(
              "assets/icons/protection.svg",
              height: size.height * 0.45,
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            RoundedButton(
              text: "LOGIN",
              btnColor: VividSkyBlue,
              textColor: BabyPowder,
              press: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()),
                    (Route<dynamic> route) => false);
              },
            ),
            RoundedButton(
              text: "REGISTER",
              btnColor: BabyBlue,
              textColor: BabyPowder,
              press: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => RegisterPage()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
