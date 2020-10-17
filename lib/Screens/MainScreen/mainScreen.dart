import 'dart:convert';
import 'dart:io';

import 'package:NearBY/Screens/AuthScreen/authScreen.dart';
import 'package:flutter/material.dart';
import 'package:NearBY/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  SharedPreferences sharedPreferences;
  logout() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    print(token);
    if (token != null) {
      var response = await http.post("http://127.0.0.1:8000/logoutall/",
          headers: {"Authorization": "Token " + token});
      if (response.statusCode == 204) {
        sharedPreferences.clear();
        // ignore: deprecated_member_use
        sharedPreferences.commit();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => AuthScreen()),
            (Route<dynamic> route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "NearBY",
          style: TextStyle(fontWeight: FontWeight.bold, color: Charcoal),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.red[50],
            ),
            onPressed: () {
              logout();
            }),
      ),
      body: Container(
          alignment: Alignment.center,
          height: size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: FlatButton(
                  child: Text("Load Data"),
                  onPressed: _mapData,
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                  child: FutureBuilder<Mapdata>(
                future: futureMapData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data.placeName.toString(),
                              style: (TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                            ),
                            Text(
                              snapshot.data.placeAddress.toString(),
                              style: (TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300)),
                            ),
                            Text(
                              (snapshot.data.distance/1000).toString()+'m',
                              style: (TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w300)),
                            )
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner.
                  return CircularProgressIndicator();
                },
              ))
            ],
          )),
    );
  }
}

class Mapdata {
  final int distance;
  final String placeAddress;
  final String placeName;

  Mapdata({this.distance, this.placeAddress, this.placeName});

  factory Mapdata.fromJson(Map<String, dynamic> json) {
    // var jsondata;
    // for (int i = 0; i < json['suggestedLocations'].length; i++) {
    //   Map toMap() => {
    //         "distance": json['suggestedLocations'][i]['distance'],
    //         "placeAddress": json['suggestedLocations'][i]['placeAddress'],
    //         "placeName": json['suggestedLocations'][i]['placeName']
    //             .map((c) => c.toJson().toList())
    //       };
    //   jsondata = jsonEncode(toMap());
    // }
    print(json['suggestedLocations']);
    
    return Mapdata(
      distance: json['suggestedLocations'][0]['distance'],
      placeAddress: json['suggestedLocations'][0]['placeAddress'],
      placeName: json['suggestedLocations'][0]['placeName'],
    );
  }
}
