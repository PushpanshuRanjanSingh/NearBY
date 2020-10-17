import 'package:NearBY/Function/functions.dart';
import 'package:NearBY/Screens/Login/components/Background.dart';
import 'package:NearBY/Screens/Login/loginPage.dart';
import 'package:NearBY/colors.dart';
import 'package:NearBY/widget/roundedButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPBackground extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String otp;

  const OTPBackground({
    Key key,
    @required this.username,
    this.email,
    this.password,
    this.otp,
  }) : super(key: key);

  @override
  _OTPBackgroundState createState() => _OTPBackgroundState();
}

class _OTPBackgroundState extends State<OTPBackground> {
  Color verifybtncolor = VividSkyBlue;
  String verifybtntext = "Verify";
  Color otpcolor = VividSkyBlue;
  Future<String> authRegister;
  bool _isLoading = false;

  TextEditingController otpcodeController = TextEditingController();
  register({String username, String email, String password}) async {
    Map data = {
      "username": username,
      "email": email,
      "password": password,
    };
    String body = json.encode(data);
    var response = await http.post(
      'http://127.0.0.1:8000/register/',
      body: body,
      headers: {"Content-Type": "application/json"},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      _isLoading = false;
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    } else {
      setState(() {
        _isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Enter Your \nVerification Code",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: PurpleDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      "We sent a verification code \nto ${widget.email}",
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "This Code will expire in ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TweenAnimationBuilder(
                          tween: Tween(begin: 59.0, end: 0),
                          duration: Duration(seconds: 59),
                          builder: (context, value, child) => Text(
                            value.toInt() > 9
                                ? "00:${value.toInt()}"
                                : "00:0${value.toInt()}",
                            style: TextStyle(color: LightCoral),
                          ),
                          onEnd: () {},
                        )
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      width: size.width * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                      ),
                      child: TextField(
                        controller: otpcodeController,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          letterSpacing: 5,
                          color: otpcolor,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: " O T P ",
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.all(3),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SvgPicture.asset(
                      "assets/icons/otp.svg",
                      height: size.height * 0.35,
                      alignment: Alignment.center,
                    ),
                    RoundedButton(
                        btnColor: verifybtncolor,
                        text: verifybtntext,
                        textColor: Colors.white,
                        press: () {
                          if (this.otpcodeController.text == widget.otp) {
                            register(
                              username: widget.username,
                              email: widget.email,
                              password: widget.password,
                            );
                            setState(() {
                              _isLoading = true;
                            });
                          } else {
                            this.verifybtncolor = LightCoral;
                            this.verifybtntext = "Re-Verify";
                            this.otpcolor = LightCoral;
                          }
                        }),
                    GestureDetector(
                      onTap: () {
                        sendMail(widget.otp, widget.email);
                        print("Mail resend");
                      },
                      child: Text(
                        "Send the code again",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
