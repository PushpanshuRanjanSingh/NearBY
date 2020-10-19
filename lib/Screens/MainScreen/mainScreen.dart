import 'dart:io';
import 'dart:convert';
import 'package:NearBY/Screens/AuthScreen/authScreen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List data;
  SharedPreferences sharedPreferences;

  double latitute;
  double longitude;
  String searchquery = "ornaments";

  @override
  void initState() {
    super.initState();
    this._getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    setState(() {
      latitute = position.latitude;
      longitude = position.longitude;
    });
  }

  Future<String> getJsonData(
      String searchquery, String latitute, String longitude) async {
    var respone = await http.get(
      Uri.encodeFull(
          'https://atlas.mapmyindia.com/api/places/nearby/json?keywords=$searchquery&refLocation=$latitute,$longitude'),
      headers: {
        HttpHeaders.authorizationHeader:
            "Bearer 80e248ff-bc3f-4089-81b1-c321ed991f6e",
        "Accept": "application/json"
      },
    );
    setState(() {
      var convertToJsonData = json.decode(respone.body);
      data = convertToJsonData['suggestedLocations'];
    });

    return "Success";
  }

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
    // Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("NearBY"),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  getJsonData(
                      searchquery, latitute.toString(), longitude.toString());
                });
              },
            ),
          ],
        ),
        body: ListView.builder(
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (BuildContext contex, int index) {
              return new Container(
                child: new Center(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      new Card(
                        child: new ListTile(
                          title: Text(data[index]['placeName']),
                          subtitle: Text(data[index]['placeAddress']),
                          leading: Text((data[index]['distance'] / 1000)
                                  .toStringAsFixed(1) +
                              ' km'),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}
