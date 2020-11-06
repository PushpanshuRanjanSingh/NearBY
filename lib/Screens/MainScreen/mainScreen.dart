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
import 'package:flutter/foundation.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List data;
  SharedPreferences sharedPreferences;
  String nearbytoken;
  double latitude;
  double longitude;
  String query = "";
  bool _isloading = false;
  bool _isGettingLocation;
  TextEditingController searchquery;
  bool _hasdata = false;
  bool _rotatecred = true;

  Map data1 = {
    "grant_type": "client_credentials",
    "client_id":
        "33OkryzDZsIuJ-q-hQx_kUD73j7vP4zSXxjRb6eE7QDNJpRA7Qphpiq_2708Ho5iG-2AB08ZOJCT7UChLF0ZuK_pQaxfOzPseXGMV6U-6sYAq6YYDA-JCQ==",
    "client_secret":
        "lrFxI-iSEg_bPOrlEssw54i0mzky1a5ofL-yZgrAvcvfnDscuTAhLxndgfpL6Uj5FNM4jXoNQwwl3k-mkZDjKCJcy3La870YTVDV98bGAa-3J0MtEoaIK3UMhhSIoO6G",
  };

  Map data2 = {
    "grant_type": "client_credentials",
    "client_id":
        "33OkryzDZsJCei93pVtUPUsNWGQG83EF1q3W5s_THs01S84BWKEsItgo-gzkLqsSw7-BmjAqv6rttDxeNJg-o8ZDkZUtho4Jt4KeWB-_sBws8BucWCpyzw==",
    "client_secret":
        "lrFxI-iSEg8G4loULHqd1yqyhdTr9glfnhPIVEIGHeGO5KAyXkGNvaT6Lhi23FXC9m-p5YvHFtfZinNG_4Z662tvrRXW6OgUxsl-8ATL7ZJnc_8Xa1JBF34bokPlW9sg",
  };
  @override
  void initState() {
    super.initState();
    _isGettingLocation = true;
    getCurrentLocation();
    getToken();
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        _isGettingLocation = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> getToken() async {
    var response = await http.post(
      Uri.encodeFull('https://outpost.mapmyindia.com/api/security/oauth/token'),
      body: _rotatecred ? data1 : data2,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
    );
    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      setState(() {
        nearbytoken = jsondata["access_token"];
      });
    } else {
      setState(() {
        _rotatecred = !_rotatecred;
      });
    }
  }

  Future<String> getJsonData(
      String searchquery, String latitude, String longitude) async {
    _isloading = true;
    var response = await http.get(
      Uri.encodeFull(
          'https://atlas.mapmyindia.com/api/places/nearby/json?keywords=$query&refLocation=$latitude,$longitude'),
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
        data.length > 0 ? _hasdata = true : _hasdata = false;
      } catch (e) {
        print(e);
      }
    });

    return "Success";
  }

  logout() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    if (token != null) {
      var response = await http.post("https://nearbyme.tk/logoutall/",
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
    // var platform = Theme.of(context).platform;
    // ************ Android *********
    // if (platform == TargetPlatform.android) {
    //   return Scaffold(
    //     body: Stack(
    //       children: [
    //         MapContainer(
    //           latitude: latitude,
    //           longitude: longitude,
    //           height: size.height * 1.0,
    //         ),
    //         Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           children: [
    //             Container(
    //               padding: EdgeInsets.symmetric(horizontal: 10),
    //               margin: EdgeInsets.symmetric(horizontal: 10, vertical: 50),
    //               color: Colors.white,
    //               child: TextField(
    //                 onChanged: (value) {
    //                   query = value;
    //                 },
    //                 textAlign: TextAlign.start,
    //                 style: TextStyle(color: Colors.black, fontSize: 20),
    //                 autofocus: true,
    //                 decoration: InputDecoration(
    //                   hintText: "Search your NearBY",
    //                   suffixIcon: IconButton(
    //                     icon: Icon(Icons.search),
    //                     color: Colors.blue,
    //                     splashColor: Colors.transparent,
    //                     onPressed: () {
    //                       if (query.isNotEmpty) {
    //                         Navigator.push(
    //                           context,
    //                           MaterialPageRoute(
    //                             builder: (context) => MainScreenViewList(
    //                               query: query,
    //                               latitude: latitude.toString(),  //"25.7870462",
    //                               longitude: longitude.toString(), //"84.7230354",
    //                               nearbytoken: nearbytoken,
    //                             ),
    //                           ),
    //                         );
    //                       }
    //                     },
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         )
    //       ],
    //     ),
    //   );
    // }
    // ************ iOS *********
    // else if (platform == TargetPlatform.iOS) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "NearBY",
            style: TextStyle(fontWeight: FontWeight.bold),
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
        body: _isGettingLocation
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        onChanged: (value) {
                          query = value;
                        },
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "Search your NearBY",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            color: Colors.blue,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              setState(() {
                                getToken();
                                try {
                                  if (query.isNotEmpty) {
                                    getJsonData(query, latitude.toString(),
                                        longitude.toString());
                                  } else {
                                    _hasdata = false;
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    MapContainer(
                      latitude: latitude,
                      longitude: longitude,
                      height: size.height * 0.3,
                    ),
                    Container(
                        child: _isloading
                            ? Container(child: CircularProgressIndicator())
                            : _hasdata
                                ? Expanded(
                                    child: ListView.builder(
                                      itemCount: data == null ? 0 : data.length,
                                      itemBuilder:
                                          (BuildContext contex, int index) {
                                        return NearBYListView(
                                          data: data,
                                          index: index,
                                        );
                                      },
                                    ),
                                  )
                                : Expanded(
                                    child: Center(
                                        child: Text(
                                    "OOPS!! \n Nothing to Show",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ))))
                  ],
                ),
              ));
    // }
    // else {
    //   return Container();
    // }
  }
}

class NearBYListView extends StatelessWidget {
  final List<dynamic> data;
  final int index;

  const NearBYListView({Key key, this.data, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
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
          leading:
              Text((data[index]['distance'] / 1000).toStringAsFixed(1) + ' km'),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}

class MapContainer extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double height;

  const MapContainer({
    Key key,
    this.latitude,
    this.longitude,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            new FlutterMap(
              options: new MapOptions(
                minZoom: 13,
                center: LatLng(latitude, longitude),
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
                      point: new LatLng(latitude, longitude),
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
