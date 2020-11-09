import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MainScreenViewList extends StatefulWidget {
  final String nearbytoken;
  final String query;
  final String latitude;
  final String longitude;

  const MainScreenViewList({
    Key key,
    this.nearbytoken,
    this.query,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  _MainScreenViewListState createState() => _MainScreenViewListState();
}

class _MainScreenViewListState extends State<MainScreenViewList> {
  List data;
  String nearbytoken;
  bool _isloading = false;

  Future<String> getJsonData() async {
    _isloading = true;
    var response = await http.get(
      Uri.encodeFull(
          'https://atlas.mapmyindia.com/api/places/nearby/json?keywords=${widget.query}&refLocation=${widget.latitude},${widget.longitude}'),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer ${widget.nearbytoken}",
      },
    );
    print("\n ${widget.nearbytoken}");
    print(response.statusCode);
    setState(() {
      _isloading = false;
      var convertToJsonData = json.decode(response.body);
      data = convertToJsonData['suggestedLocations'];
      print("getjson body:  $convertToJsonData");
    });
    print("getjson :  $data");
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    getJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NearBY"),
      ),
      body: _isloading
          ? Center(child: Container(child: CircularProgressIndicator()))
          : Container(
              child: ListView.builder(
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (context, index) {
                  return NearBYListView(
                    data: data,
                    index: index,
                  );
                },
              ),
            ),
    );
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
                        Icons.directions_car,
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
                                Icons.navigation,
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
