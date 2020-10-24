import 'dart:io';
import 'dart:convert';
import 'package:NearBY/Screens/AuthScreen/authScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List data;
  SharedPreferences sharedPreferences;
  String token = "e981ae32-7ddf-4fdd-8c53-378fc0007127";

  double latitute;
  double longitude;
  String query = "";
  bool _isloading = false;
  bool _issearched = false;
  TextEditingController searchquery;
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

  Future<void> getToken() async {
    Map data = {
      "grant_type": "client_credentials",
      "client_id":
          "33OkryzDZsIuJ-q-hQx_kUD73j7vP4zSXxjRb6eE7QDNJpRA7Qphpiq_2708Ho5iG-2AB08ZOJCT7UChLF0ZuK_pQaxfOzPseXGMV6U-6sYAq6YYDA-JCQ==",
      "client_secret":
          "lrFxI-iSEg_bPOrlEssw54i0mzky1a5ofL-yZgrAvcvfnDscuTAhLxndgfpL6Uj5FNM4jXoNQwwl3k-mkZDjKCJcy3La870YTVDV98bGAa-3J0MtEoaIK3UMhhSIoO6G",
    };
    String body = json.encode(data);
    var response = await http.post(
      Uri.encodeFull('https://outpost.mapmyindia.com/api/security/oauth/token'),
      body: body,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      print("JSON ${jsondata["access_token"]}");
      setState(() {
        token = jsondata["access_token"];
      });
    }
  }

  Future<String> getJsonData(
      String searchquery, String latitute, String longitude) async {
    _isloading = true;
    var response = await http.get(
      Uri.encodeFull(
          'https://atlas.mapmyindia.com/api/places/nearby/json?keywords=$query&refLocation=$latitute,$longitude'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        "Accept": "application/json"
      },
    );
    setState(() {
      _isloading = false;
      var convertToJsonData = json.decode(response.body);
      data = convertToJsonData['suggestedLocations'];
    });

    return "Success";
  }

  logout() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    print(token);
    if (token != null) {
      var response = await http.post("http://ec2-15-206-117-147.ap-south-1.compute.amazonaws.com/logoutall/",
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
        elevation: 0,
        title: TextField(
          onChanged: (value) {
            query = value;
          },
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
              hintText: "Search your NearBY", border: InputBorder.none),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.red[50],
            ),
            onPressed: () {
              logout();
            }),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(
                () {
                  if (query.length >= 3) {
                    getToken();
                    getJsonData(
                      query,
                      latitute.toString(),
                      longitude.toString(),
                    );
                    _issearched = true;
                  } else {
                    _issearched = false;
                  }
                },
              );
            },
          ),
        ],
      ),
      body: _issearched
          ? _isloading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext contex, int index) {
                    return _listVIew(data, index);
                  },
                )
          : Container(
              height: size.height,
              width: size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: new FlutterMap(
                  options: new MapOptions(
                    zoom: 15.0,
                    center: new LatLng(latitute, longitude),
                  ),
                  layers: [
                    new TileLayerOptions(
                      urlTemplate:
                          "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
                      subdomains: ['a', 'b', 'c'],
                      additionalOptions: {
                        'subscriptionKey':
                            'QmkAOUcS0XIR0Z1JnXRAZy-n5g8UnY8ftvIsYdwHcKk'
                      },
                    ),
                    new MarkerLayerOptions(
                      markers: [
                        new Marker(
                          width: 80.0,
                          height: 80.0,
                          point: new LatLng(latitute, longitude),
                          builder: (ctx) => new Container(
                            child: Icon(
                              Icons.location_on,
                              color: Colors.redAccent[700],
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  _listVIew(data, index) {
    return new Container(
      child: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            new Card(
              child: new ListTile(
                onTap: () {
                  MapsLauncher.launchCoordinates(
                      data[index]['latitude'], data[index]['longitude']);
                },
                title: Text(data[index]['placeName']),
                subtitle: Text(data[index]['placeAddress']),
                leading: Text(
                    (data[index]['distance'] / 1000).toStringAsFixed(1) +
                        ' km'),
                trailing: Icon(Icons.arrow_forward),
              ),
            )
          ],
        ),
      ),
    );
  }
}
