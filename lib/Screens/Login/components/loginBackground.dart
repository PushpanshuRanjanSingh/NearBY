import 'dart:convert';
import 'package:NearBY/Screens/AskLocation/askLocation.dart';
import 'package:NearBY/Screens/Login/components/Background.dart';
import 'package:NearBY/Screens/Register/registerPage.dart';
import 'package:NearBY/colors.dart';
import 'package:NearBY/widget/AlreadyHaveAccountCheck.dart';
import 'package:NearBY/widget/roundedButton.dart';
import 'package:NearBY/widget/roundedInputField.dart';
import 'package:NearBY/widget/roundedPasswordInputField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginBackground extends StatefulWidget {
  const LoginBackground({
    Key key,
  }) : super(key: key);

  @override
  _LoginBackgroundState createState() => _LoginBackgroundState();
}

class _LoginBackgroundState extends State<LoginBackground> {
  bool _isLoading = false;
  bool _isnotvalid = false;
  bool _connectivity = true;
  TextEditingController username;
  TextEditingController password;
  bool _secure;
  var token;

  @override
  void initState() {
    _secure = true;
    username = new TextEditingController();
    password = new TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    username?.dispose();
    password?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    signIn(String username, String password) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      Map data = {'username': username, 'password': password};
      // ignore: avoid_init_to_null
      var jsonResponse = null;
      var response = await http.post(
          "https://nearbyme.tk/login/",
          body: data);
      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          setState(() {
            _isLoading = false;
          });
          sharedPreferences.setString("token", jsonResponse['token']);
          token = sharedPreferences.get('token');
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => AskLocation()),
              (Route<dynamic> route) => false);
        }
      } else {
        setState(() {
          _isLoading = false;
          _isnotvalid = true;
          if (response.statusCode == null) {
            _connectivity = false;
          }
        });
        print(response.body);
      }
    }

    return Background(
      child: SingleChildScrollView(
        child: _isLoading
            ? Center(
                child: Container(
                  height: 60,
                  width: 60,
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "LOGIN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: size.height * 0.03),
                  SvgPicture.asset(
                    "assets/icons/login.svg",
                    height: size.height * 0.35,
                  ),
                  SizedBox(height: size.height * 0.03),
                  _isnotvalid
                      ? Text(
                          "username or password is invalid",
                          style: TextStyle(color: Colors.red[300]),
                        )
                      : Text(''),
                  _connectivity
                      ? Text("")
                      : Text(
                          "Ouch! internet break-down",
                          style: TextStyle(color: Colors.red[300]),
                        ),
                  RoundedInputField(
                    hintText: "username",
                    controller: username,
                  ),
                  RoundedPasswordInput(
                    hint: "password",
                    controller: password,
                    icon: _secure
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                    secure: _secure ? true : false,
                    toggle: () {
                      setState(() {
                        _secure = !_secure;
                      });
                    },
                  ),
                  SizedBox(height: size.height * 0.03),
                  RoundedButton(
                    text: "LOGIN",
                    press: () {
                      if (username.text.length > 1 &&
                          password.text.length > 7) {
                        signIn(username.text, password.text);
                        setState(() {
                          _isLoading = true;
                          username.text = "";
                          password.text = "";
                        });
                      } else {
                        setState(() {
                          _isnotvalid = true;
                        });
                      }
                    },
                    btnColor: Colors.blue,
                    textColor: BabyPowder,
                  ),
                  SizedBox(height: size.height * 0.01),
                  AlreadyHaveAccountCheck(
                    press: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RegisterPage()),
                          (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
