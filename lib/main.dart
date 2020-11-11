import 'package:NearBY/colors.dart';
import 'package:NearBY/rohit/sliderScreen.dart';
import 'package:flutter/material.dart';
import 'rohit/chatview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NearBY",
      theme: ThemeData(
        primaryColor: BabyBlue,
        scaffoldBackgroundColor: BabyPowder,
        fontFamily: 'Poppins',
      ),
      home: Home(),
    );
  }
}
