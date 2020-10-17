import 'package:NearBY/Screens/AuthScreen/authScreen.dart';
import 'package:NearBY/Screens/Login/loginPage.dart';
import 'package:NearBY/Screens/MainScreen/mainScreen.dart';
import 'package:NearBY/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AskLocation extends StatefulWidget {
  const AskLocation({
    Key key,
  }) : super(key: key);
  @override
  _AskLocationState createState() => _AskLocationState();
}

class _AskLocationState extends State<AskLocation> {
  double latitute;
  double longitude;
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  logout() async {
    var token = sharedPreferences.getString("token");
    print(token);
    if (token != null) {
      var response = await http.post(
          "http://127.0.0.1:8000/logoutall/",
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

  // return position of current location
  Future<void> _getCurrentLocation() async {
    final position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

    setState(() {
      latitute = position.latitude;
      longitude = position.longitude;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => MainScreen()),
        (Route<dynamic> route) => false);
  }

  // permission [1: deny, 0: yet now asked, 2: grant]
  Future<void> _isEnable() async {
    LocationPermission permission = await checkPermission();
    if (permission.index == 1) {
      await openLocationSettings();
    } else {
      _getCurrentLocation();
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
        height: size.height,
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "This Application will use your device location to find nearby Shops, Grocery, Hospitals and other places that you need to know !",
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            SizedBox(height: size.height * 0.03),
            latitute != null
                ? Container(
                    height: size.height * 0.3,
                    width: size.width * 0.9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: new FlutterMap(
                        options: new MapOptions(
                          zoom: 10.0,
                          center: new LatLng(latitute, longitude),
                        ),
                        layers: [
                          new TileLayerOptions(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
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
                  )
                : Container(),
            SizedBox(height: size.height * 0.03),
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: FlatButton(
                  color: MediumTurquoise,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  onPressed: () {
                    _isEnable();
                  },
                  // onPressed: _getCurrentLocation,
                  child: Text(
                    "Show Location",
                    style: TextStyle(
                      color: BabyPowder,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
