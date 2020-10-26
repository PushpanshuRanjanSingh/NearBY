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
  String nearbytoken;
  double latitute;
  double longitude;
  String query = "";
  bool _isloading = false;
  bool _isGettingLocation;
  TextEditingController searchquery;

  @override
  void initState() {
    super.initState();
    _isGettingLocation = true;
    getCurrentLocation();
    getToken();
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    try {
      setState(() {
        latitute = position.latitude;
        longitude = position.longitude;
        _isGettingLocation = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getToken() async {
    Map data = {
      "grant_type": "client_credentials",
      "client_id":
          "33OkryzDZsIuJ-q-hQx_kUD73j7vP4zSXxjRb6eE7QDNJpRA7Qphpiq_2708Ho5iG-2AB08ZOJCT7UChLF0ZuK_pQaxfOzPseXGMV6U-6sYAq6YYDA-JCQ==",
      "client_secret":
          "lrFxI-iSEg_bPOrlEssw54i0mzky1a5ofL-yZgrAvcvfnDscuTAhLxndgfpL6Uj5FNM4jXoNQwwl3k-mkZDjKCJcy3La870YTVDV98bGAa-3J0MtEoaIK3UMhhSIoO6G",
    };
    var response = await http.post(
      Uri.encodeFull('https://outpost.mapmyindia.com/api/security/oauth/token'),
      body: data,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
    );
    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      setState(() {
        nearbytoken = jsondata["access_token"];
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
        HttpHeaders.authorizationHeader: "Bearer $nearbytoken",
        "Accept": "application/json"
      },
    );
    setState(() {
      _isloading = false;
      try {
        var convertToJsonData = json.decode(response.body);
        data = convertToJsonData['suggestedLocations'];
      } catch (e) {
        print(e);
      }
    });

    return "Success";
  }

  logout() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    print(token);
    if (token != null) {
      var response = await http.post(
          "http://ec2-15-206-117-147.ap-south-1.compute.amazonaws.com/logoutall/",
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
    if (_isGettingLocation) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return _isGettingLocation
          ? Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : Scaffold(
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
                          getToken();
                          try {
                            getJsonData(
                              query,
                              latitute.toString(),
                              longitude.toString(),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Container(
                    child: mapContainer(context, size.height * 0.3, size.width,
                        latitute, longitude),
                  ),
                  Expanded(
                      child: _isloading
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                              child: ListView.builder(
                                itemCount: data == null ? 0 : data.length,
                                itemBuilder: (BuildContext contex, int index) {
                                  return listVIew(data, index);
                                },
                              ),
                            ))
                ],
              ),
            );
    }
  }

  listVIew(data, index) {
    return new Container(
      child: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            new Card(
              child: new ListTile(
                onTap: () {
                  _bottomSheetModel(context, data[index]);
                },
                title: Text(
                  data[index]['placeName'],
                  maxLines: 1,
                ),
                subtitle: Text(
                  data[index]['placeAddress'],
                  maxLines: 2,
                ),
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

mapContainer(context, height, width, latitute, longitude) {
  return new Container(
    height: height,
    width: width,
    padding: EdgeInsets.all(5),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          new FlutterMap(
            options: new MapOptions(
              minZoom: 13,
              center: new LatLng(latitute, longitude),
            ),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                      "https://api.mapbox.com/styles/v1/pushpanshuranjansingh/ckgqo8jcm4ze819qox5ko9y4k/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicHVzaHBhbnNodXJhbmphbnNpbmdoIiwiYSI6ImNrZ3FubHdsazBkb3QydW1yN2k3NW1nM2kifQ.ukVroXX5O6EgSc5VT5dW6Q",
                  additionalOptions: {
                    'accessToken':
                        'pk.eyJ1IjoicHVzaHBhbnNodXJhbmphbnNpbmdoIiwiYSI6ImNrZ3FubHdsazBkb3QydW1yN2k3NW1nM2kifQ.ukVroXX5O6EgSc5VT5dW6Q',
                    'id': 'mapbox.mapbox-streets-v8',
                  }),
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
          Positioned(
            right: 3,
            bottom: 3,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  child: Center(
                      child: IconButton(
                    icon: Icon(Icons.my_location),
                    onPressed: () {},
                    color: Colors.pinkAccent,
                    splashColor: Colors.transparent,
                    splashRadius: 0.1,
                  )),
                  color: Colors.grey[50],
                )),
          ),
        ],
      ),
    ),
  );
}

void _bottomSheetModel(context, data) {
  showModalBottomSheet(
      context: context,
      builder: (builder) {
        Size size = MediaQuery.of(context).size;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: new Container(
            padding: EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 15,
            ),
            child: Wrap(
              children: [
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    new ListTile(
                      leading: Icon(Icons.business),
                      title: Text("${data['placeName']}"),
                      subtitle: Text('place'),
                    ),
                    new ListTile(
                      leading: Icon(Icons.location_city),
                      title: Text("${data['placeAddress']}"),
                      subtitle: Text('address'),
                    ),
                    new ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(
                          "${(data['latitude']).toStringAsFixed(6)} ${(data['longitude']).toStringAsFixed(6)}"),
                      subtitle: Text('coordinates'),
                    ),
                    new ListTile(
                      leading: Icon(
                        Icons.directions_car_rounded,
                      ),
                      title: Text(
                          "${(data['distance'] / 1000).toStringAsFixed(3)} km"),
                      subtitle: Text('distance'),
                    ),
                    Container(
                      width: size.width * 0.8,
                      height: size.height * 0.07,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: FlatButton(
                          onPressed: () {
                            MapsLauncher.launchCoordinates(
                                data['latitude'], data['longitude']);
                          },
                          color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assistant_navigation,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Navigate",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
}
