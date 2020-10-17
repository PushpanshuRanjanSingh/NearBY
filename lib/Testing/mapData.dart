import 'package:flutter/material.dart';
import 'dart:async';
// import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestingMapMYIndia extends StatefulWidget {
  @override
  _TestingMapMYIndiaState createState() => _TestingMapMYIndiaState();
}

class _TestingMapMYIndiaState extends State<TestingMapMYIndia> {
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("MapMyIndia"),
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
                  child: Text("Test OAuth2"),
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
                    return Text(snapshot.data.distance.toString());
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
    print(json['suggestedLocations'][0]['distance']);
    return Mapdata(
      distance: json['suggestedLocations'][0]['distance'],
      placeAddress: json['suggestedLocations'][0]['placeAddress'],
      placeName: json['suggestedLocations'][0]['placeName'],
    );
  }
}
