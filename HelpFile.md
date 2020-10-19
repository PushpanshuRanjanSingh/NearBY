## NearBY ##

Create Project

```bash
flutter create NearBY
cd NearBY
# need to start your emulator first then
flutter run
```
Flutter will create project for you

<img src="https://i.loli.net/2020/10/08/ARtcYNO3BD9lzTv.png" width="45%" style="zoom:45%;" />

**Main.dart**

This is Main File that execute first
```dart

import 'package:flutter/material.dart';
import 'package:NearBY/widgets/AuthLandingPage.dart';

void main() {
  runApp(MyApp());
} //Main function to execute app

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // return Android Theme App : MaterialApp
        // return iOS Theme App     : CupertinoApp
      debugShowCheckedModeBanner: false,
        // Debug Banner : True/False to Show/Hide
      title: "NearBY",
      home: AuthLandingPage(),
        // HomePage of Application
    );
  }
}

```

**AuthLandingPage.dart**

```dart

import 'package:flutter/material.dart';

class AuthLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Page Type as Android : Scaffold
        // Page Type as iOS : CupertinoPageScaffold
      body: Center(
        child: Text("Hello World "),
      ),
    );
  }
}

```

**pubspec.yaml**

```yaml

# Dependencies

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^0.1.3
  flutter_svg: ^0.19.0

# Flutter Assets, Fonts, Icons Path Configuration

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/

  fonts:

    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
        - asset: assets/fonts/Poppins-Italic.ttf
          weight: 300
          style: italic
        - asset: assets/fonts/Poppins-Regular.ttf
          weight: 400

    - family: Quicksand
      fonts:
        - asset: assets/fonts/Quicksand-Bold.ttf
          weight: 700
        - asset: assets/fonts/Quicksand-Medium.ttf
          weight: 500
        - asset: assets/fonts/Quicksand-Regular.ttf
          weight: 400

```

**Create a Widget as Component**

convert code to widget

![Extract Widget](https://i.loli.net/2020/10/08/UYvKCOoStfLIxbR.png)

<center>When you Extract as Widget (left pic) it convert it into widget(right pic). now you can use it anywhere in this project</center>

Uses:

```dart
import 'package:flutter/material.dart';
import 'background.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Background(
      child: Column(
        children: [],
      ),
    );
  }
}

```
**Button Function on Press :  Route to other page/screen**

```dart
RoundedButton(
  text: "REGISTER",
  btnColor: BabyBlue,
  textColor: BabyPowder,
  press: () {
    Navigator.push( // Android :: Page Routing 
      context,
      MaterialPageRoute(
        builder: (context) {
          return RegisterPage();
        },
      ),
    );
  },
),
```
---

## Handling API

**OAuth2 + API Request**

```dart
Future<http.Response> mapData() async {
  final response = await http.get(
    'https://atlas.mapmyindia.com/api/places/nearby/json?keywords=coffee;beer&refLocation=25.7692802,84.741993',
    headers: {
      HttpHeaders.authorizationHeader:
          "Bearer bece0337-a537-4a03-b32a-16a2c91b5bab"
    },
  );
  final responseData = jsonDecode(response.body);
  print(responseData);

  return response;
}
```

**API Request & Response**
Hit and Trail in Other File tempTesting/TestButton.dart

```dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class TestButton extends StatelessWidget {
  // Function used to fetch response from API
  Future <String> fetchAlbum() async {
    final response = await http.get(
      'https://jsonplaceholder.typicode.com/comments/1',
      headers: {HttpHeaders.authorizationHeader: "Basic your_api_token_here"},
    );
    final responseJson = jsonDecode(response.body);
    print(responseJson);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        width: size.width * 0.8,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          onPressed: fetchAlbum,
          child: Text(
            "Press Me ",
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue,
        ),
      ),
    );
  }
}
```
> **Response**
{
postId: 1, 
id: 1, 
name: id labore ex et quam laborum,
email: Eliseo@gardner.biz,
body: laudantium enim quasi est quidem magnam voluptate ipsam eos tempora quo necessitatibus dolor quam autem quasi reiciendis et nam sapiente accusantium
}

**API Data Handling**

1. Create Class for API Data
    - Constructor 
    - ```Factory``` (sub class Intance)
2. Create API Request defining Classname with ```Future```
3. Manage State ```initState()```
4. Use ```FlutterBuilder``` for showing data

Example 

```dart
// Class + Constructor + Factory
class NearBYData {
  final id;
  final userID;
  final title;

  NearBYData(
      {this.distance, this.placeAddress, this.placeName});

  factory NearBYData.fromJson(final json) {
    return NearBYData(
      id: json["id"],
      userId: json["userId"],
      title: json["title"],
    );
  }
}
```

```dart
// API Request
Future<NearBYData> _mapData() async {
 final response =
     await http.get("https://jsonplaceholder.typicode.com/todos/1");

 if (response.statusCode == 200) {
   final responseData = jsonDecode(response.body);
   print(responseData);
   return NearBYData.fromJson(responseData);
 } else {
   throw Exception();
 }
}
```

_Display Data on Output Screen_

```dart
SingleChildScrollView(
 child: Center(
   child: FutureBuilder<NearBYData>(
     future: mapDATA,
     builder: (context, snapshot) {
       if (snapshot.hasData) {
         final mapdata = snapshot.data;
         return Column(
           children: [
            Text(mapdata.title.toString() != null
                  ? mapdata.title.toString()
                  : " "),
             Text(mapdata.id.toString() != null
                 ? mapdata.id.toString()
                 : " "),
             Text(mapdata.userId.toString() != null
                 ? mapdata.userId.toString()
                 : " "),
           ],
         );
       } else if (snapshot.hasError) {
         return Text(snapshot.error.toString());
       }
       return LinearProgressIndicator();
     },
   ),
 ),
),
```

Snapshot
<center>
<img src="https://i.loli.net/2020/10/10/m6vq5VTMhdKNQtc.png" alt="API Output" width="33%" style="zoom:33%;"/>
</center>

## Transfer Data From one Screen To another Screen ##

<table>
<tr>
<th> Screen - 1 {Sender} </th>
<th> Screen - 2 {Receiver} </th>
</tr>
<tr>
<td>
Stateless Widget
</td>
</tr>
<tr>
<td>

```dart
// 1. Define variable in Widget build(BuildContext context)
String username;

// 2. Pass value to variable
RoundedInputField(
  hintText: "username",
  onChanged: (value) {
    username = value;
  },
),

// 3. Pass variable 
onPressed: () {
Navigator.push(context,MaterialPageRoute(
  builder: (context) {
  return OTPHandler(
      username: username,
      );
    },
  ),
);
}
```
</td>
<td>

```dart
// 1. define in class OTPHandler extends StatelessWidget{...}
final String username;

// 2. Create Constructor
const OTPHandler({
  Key key,
  this.username
  }) : super(key: key);
return Scaffold(
  body: OTPBackground(
    username: username),
    ),
    );
        ||
       \  /
        \/
class OTPBackground extends StatelessWidget {
  final String username;
  const OTPBackground({
    Key key,
    @required this.username,
  }) : super(key: key);

  // 3. Now use it in Widget
  Text("We sent a verification code \nto $username"),
}
```
</td>
</tr>

<tr>
<td>
Statefull Widget
</td>
</tr>

<tr>
<td>

```dart
// 1. Define variable in Widget build(BuildContext context)
String username;

// 2. Pass value to variable
RoundedInputField(
  hintText: "username",
  onChanged: (value) {
    username = value;
  },
),

// 3. Pass variable 
onPressed: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) {
    return OTPHandler(
      username: username,
      );
    },
  ),
);
}
```
</td>
<td>

```dart
// 1. Define in class OTPHandler extends StatefulWidget{...}
String username;
OTPHandler({
  Key key, this.username
  }) : super(key: key);

// 2. Pass value in createState
_OTPHandlerState createState() => _OTPHandlerState(username: username);

// 3. Define in class _OTPHandlerState extends State<OTPHandler> {...}
String username;
_OTPHandlerState({this.username});

return Scaffold(
  body: OTPBackground(
    username: widget.username
    ),
  );
        ||
       \  /
        \/
class OTPBackground extends StatelessWidget {
  final String username;
  const OTPBackground({
    Key key,
    @required this.username,
  }) : super(key: key);

    // 4. Now use it in Widget
  Text("We sent a verification code \nto $username"),

}
```
</td>
</tr>
</table>


## Map Data Fetching Function

```dart

  Future<Mapdata> futureMapData;
  final apiurl =
      'https://atlas.mapmyindia.com/api/places/nearby/json?keywords=coffee;beer&refLocation=25.765150,84.783840';

  Future<Mapdata> _mapData() async {
    final response = await http.get(
      apiurl,
      headers: {
        HttpHeaders.authorizationHeader:
            "Bearer a32eca00-44aa-4765-b9e9-02f8b6fa0b8b"
      },
    );
    if (response.statusCode == 200) {
      final responseData = Mapdata.fromJson(jsonDecode(response.body));
      return responseData;
    } else {
      throw ('Failed to load Data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureMapData = _mapData();
  }

```

## Create Json Model Class with the help of [Quicktype](https://app.quicktype.io/)

