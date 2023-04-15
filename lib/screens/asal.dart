import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:now_ui_flutter/screens/CekOngkir/map_asal.dart';
import 'package:now_ui_flutter/screens/favorites_list.dart';
import 'package:now_ui_flutter/services/LocationService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart'
    as Marker;
import 'package:provider/provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class Asal extends StatefulWidget {
  final bool loggedIn;
  static var kInitialPosition = LatLng(-33.8567844, 151.213108);
  final String selectedlatitudeplaceasal;
  final String selectedlongitudeplaceasal;
  final String selectedpelabuhanidasal;
  final String selectedalamatasal;
  final String selectedalamatpengirim;
  final String selectedpengirim;
  final String selectednotelppengirim;
  final String selectedplaceidasal;
  final String selectednotepengirim;
  final String selectednamapelabuhanpengirim;

  const Asal({
    Key key,
    this.loggedIn,
    this.selectedlatitudeplaceasal,
    this.selectedlongitudeplaceasal,
    this.selectedpelabuhanidasal,
    this.selectedalamatasal,
    this.selectedalamatpengirim,
    this.selectedpengirim,
    this.selectednotelppengirim,
    this.selectedplaceidasal,
    this.selectednotepengirim,
    this.selectednamapelabuhanpengirim,
  }) : super(key: key);
  @override
  State<Asal> createState() => _AsalState();
}

class _AsalState extends State<Asal> {
  PickResult selectedPlace;
  String _originController = '';
  TextEditingController _destinationController = TextEditingController();

  Set<Marker.Marker> _markers_origin = {};

  List<LatLng> polygonLatLngs = <LatLng>[];

  GoogleMapController controller;

  bool location = true;

  String distance = '0.0 km';

  String duration = '0.0 min';

  MasterPelabuhan _selectedpelabuhan;

  SimpleFontelicoProgressDialog _dialog;

  // List<Marker> myMarker = [];
  bool _isButtonDisabled = true;
  bool _isTextButtonDisabled = true;

  TextEditingController _favoritescontroller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedpelabuhanidasal != null) {
      _placeidasal = widget.selectedplaceidasal;
      _pelabuhanidasal = widget.selectedpelabuhanidasal;
      _destinationController.text = widget.selectedalamatasal;
      _selectedpengirim.text = widget.selectedpengirim;
      _selectednotelppengirim.text = widget.selectednotelppengirim;
      location = false;
      _latitude_place_asal = widget.selectedlatitudeplaceasal;
      _longitude_place_asal = widget.selectedlongitudeplaceasal;
      namapelabuhanpengirim = widget.selectednamapelabuhanpengirim;
      _selectednotepengirim.text = widget.selectednotepengirim;
      setPelabuhan(_pelabuhanidasal);
    }

    if (_destinationController.text.isNotEmpty &&
        _selectedpengirim.text.isNotEmpty &&
        _selectednotelppengirim.text.isNotEmpty) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  void setPelabuhan(String pelabuhanidAsal) async {
    var response = await http.get(
        Uri.parse(
            "${globals.url}/api-orderemkl/public/api/pelabuhan/combonamapelabuhan?id=$pelabuhanidAsal"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    var pelabuhan = await jsonDecode(response.body);
    // print(pelabuhan['data'][0]);
    setState(() {
      _selectedpelabuhan = MasterPelabuhan.fromJson(pelabuhan['data'][0]);
      _latitude_pelabuhan_asal = _selectedpelabuhan.latitude;
      _longitude_pelabuhan_asal = _selectedpelabuhan.longitude;
      _originController =
          '$_latitude_pelabuhan_asal, $_longitude_pelabuhan_asal';
    });
    Asal.kInitialPosition = LatLng(double.parse(_latitude_place_asal),
        double.parse(_longitude_place_asal));
    await setEditedMap();
    await getMerchant();
  }

  void setEditedMap() async {
    var directions = await LocationService().getDirections(
      _originController,
      _destinationController.text,
    );
    _goToPlace(
      directions['start_location']['lat'],
      directions['start_location']['lng'],
      directions['end_location']['lat'],
      directions['end_location']['lng'],
      directions['distance']['text'],
      directions['duration']['text'],
      directions['bounds_ne'],
      directions['bounds_sw'],
    );
    // Navigator.of(context).pop();
    setState(() {});
  }

  void getMerchant() async {
    try {
      var response = await http.get(
          Uri.parse(
              '${globals.url}/api-orderemkl/public/api/pesanan/getpelabuhan?data={"place_id":"$_placeidasal", "key":"${globals.apikey}"}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${globals.accessToken}',
          });
      if (response.statusCode == 200) {
        var maps = await jsonDecode(response.body);
        print(maps);
        globals.merchantid = maps['data']['merchant_id'];
        globals.merchantpassword = maps['data']['merchant_password'];
        print(globals.merchantid);
      } else {
        print(response.body);
      }
    } catch (e) {
      print("error response");
      print(e.toString());
    }
  }

  void _setMarker(LatLng point, LatLng destination, String distance) {
    setState(() {
      _markers_origin.add(
        Marker.Marker(
          markerId: MarkerId('marker_origin'),
          position: point,
          // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
          infoWindow: InfoWindow(
            title: "Distance: $distance",
            snippet: "Duration: $duration",
          ),
        ),
      );
      _markers_origin.add(
        Marker.Marker(
          markerId: MarkerId('marker_destination'),
          position: destination,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: "Distance: $distance",
            snippet: "Duration: $duration",
          ),
        ),
      );
    });
  }

  // Data Asal
  var _placeidasal;
  var _latitude_place_asal;
  var _longitude_place_asal;
  var _pelabuhanidasal;
  var _latitude_pelabuhan_asal;
  var _longitude_pelabuhan_asal;
  var namapelabuhanpengirim = '-';
  TextEditingController _selectedpengirim = new TextEditingController();
  TextEditingController _selectednotelppengirim = new TextEditingController();
  TextEditingController _selectednotepengirim = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, '/order');
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFB7B7B7),
            )),
        title: Text(
          "Data Muat (Pengirim)",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            fontFamily: 'Nunito-Medium',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        // backButton: true,
        // rightOptions: false,
      ),
      backgroundColor: Color(0xFFF1F1EF),
      body: ListView(
        children: [
          tracking(),
          SizedBox(height: 17.0),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, bottom: 8.0, left: 17.0, right: 7.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 36.0,
                            child: TextField(
                              controller: _destinationController,
                              readOnly: true,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 15.0),
                                suffixIcon: Icon(
                                  Icons.pin_drop,
                                  color: Color(0xFF5599E9),
                                ),
                                border: OutlineInputBorder(),
                                labelText: 'Lokasi Muat',
                                labelStyle: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return PlacePicker(
                                        apiKey: globals.apikey,
                                        initialPosition: Asal.kInitialPosition,
                                        useCurrentLocation: location,
                                        selectInitialPosition: true,
                                        onPlacePicked: (result) async {
                                          showPlacePicker(result);
                                          if (_destinationController
                                                  .text.isNotEmpty &&
                                              _selectedpengirim
                                                  .text.isNotEmpty &&
                                              _selectednotelppengirim
                                                  .text.isNotEmpty) {
                                            setState(() {
                                              _isButtonDisabled = false;
                                            });
                                          } else {
                                            setState(() {
                                              _isButtonDisabled = true;
                                            });
                                          }
                                        },
                                        autocompleteLanguage: "id",
                                        region: 'id',
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.list,
                            color: Color(0xFFC3C3C3),
                          ),
                          onPressed: () async {
                            // final data_favorites = await Navigator.push(
                            //     context,
                            //     CupertinoPageRoute(
                            //         fullscreenDialog: true,
                            //         builder: (context) => FavoritesList()));
                            final data_favorites = await Navigator.pushNamed(
                                context, '/favoritesList');
                            if (data_favorites != null) {
                              updateDataDariFavorites(data_favorites);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 17.0, right: 17.0),
                    child: TextFormField(
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 15.0),
                          labelText: 'Note',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        controller: _selectednotepengirim,
                        textCapitalization: TextCapitalization.sentences),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 17.0, right: 17.0),
                    child: SizedBox(
                      height: 36.0,
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 15.0),
                          labelText: 'Pengirim',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                        controller: _selectedpengirim,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (val) {
                          if (_destinationController.text.isNotEmpty &&
                              _selectedpengirim.text.isNotEmpty &&
                              _selectednotelppengirim.text.isNotEmpty) {
                            setState(() {
                              _isButtonDisabled = false;
                            });
                          } else {
                            setState(() {
                              _isButtonDisabled = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 17.0, right: 17.0),
                    child: SizedBox(
                      height: 36.0,
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 15.0),
                          labelText: 'No.Telp',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        controller: _selectednotelppengirim,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(13),
                        ],
                        onChanged: (val) {
                          if (_destinationController.text.isNotEmpty &&
                              _selectedpengirim.text.isNotEmpty &&
                              _selectednotelppengirim.text.isNotEmpty) {
                            setState(() {
                              _isButtonDisabled = false;
                            });
                          } else {
                            setState(() {
                              _isButtonDisabled = true;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 17.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Jarak",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: 'Nunito-Medium',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 17.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('$distance',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'Nunito-Medium')),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, bottom: 50.0, left: 17.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Pelabuhan",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'Nunito-Medium')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, bottom: 50.0, right: 17.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('$namapelabuhanpengirim',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'Nunito-Medium')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            top: 8.0, bottom: 8.0, left: 17.0, right: 17.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE9558A),
                  textStyle: TextStyle(
                    color: NowUIColors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                onPressed: _isButtonDisabled
                    ? null
                    : () {
                        return showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: ((context, setState) {
                                  return AlertDialog(
                                    title: Text(
                                      "Masukkan Nama Favorit",
                                      style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 3.0,
                                        bottom: 8.0,
                                      ),
                                      child: SizedBox(
                                        height: 36.0,
                                        child: TextField(
                                          controller: _favoritescontroller,
                                          style: TextStyle(
                                            fontSize: 13.0,
                                          ),
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(left: 15.0),
                                            border: OutlineInputBorder(),
                                            labelText: 'Nama Favorit',
                                            labelStyle: TextStyle(
                                              fontSize: 13.0,
                                            ),
                                          ),
                                          onChanged: ((value) {
                                            if (value.isNotEmpty) {
                                              setState(() {
                                                _isTextButtonDisabled = false;
                                              });
                                            } else {
                                              setState(() {
                                                _isTextButtonDisabled = true;
                                              });
                                            }
                                          }),
                                        ),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      new TextButton(
                                        child: new Text(
                                          "OK",
                                          style: TextStyle(
                                            fontFamily: 'Nunito-ExtraBold',
                                          ),
                                        ),
                                        onPressed: _isTextButtonDisabled
                                            ? null
                                            : () async {
                                                Navigator.of(context).pop();
                                                var data = {
                                                  "labelName":
                                                      _favoritescontroller.text,
                                                  "placeid": _placeidasal,
                                                  "userId": globals.loggedinId,
                                                  "pelabuhanid":
                                                      _pelabuhanidasal,
                                                  "alamat":
                                                      _destinationController
                                                          .text,
                                                  "customer":
                                                      _selectedpengirim.text,
                                                  "notelpcustomer":
                                                      _selectednotelppengirim
                                                          .text,
                                                  "latitudeplace":
                                                      _latitude_place_asal,
                                                  "longitudeplace":
                                                      _longitude_place_asal,
                                                  "namapelabuhan":
                                                      namapelabuhanpengirim,
                                                  "note": _selectednotepengirim
                                                      .text,
                                                };
                                                await Provider.of<
                                                            MasterProvider>(
                                                        context,
                                                        listen: false)
                                                    .addToFavorites(data);
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Alamat sudah ditambahkan ke favorit anda.",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    timeInSecForIosWeb: 1,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                                _favoritescontroller.clear();
                                                _isTextButtonDisabled = true;
                                              },
                                      ),
                                      new TextButton(
                                        child: new Text(
                                          "CANCEL",
                                          style: TextStyle(
                                            fontFamily: 'Nunito-ExtraBold',
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _favoritescontroller.clear();
                                          _isTextButtonDisabled = true;
                                        },
                                      ),
                                    ],
                                  );
                                }),
                              );
                            });
                      },
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 12, bottom: 12),
                    child: Text("Tambah Ke Favorit",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Nunito-Medium',
                          fontWeight: FontWeight.bold,
                        ))),
              ),
            ),
            Container(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5599E9),
                  textStyle: TextStyle(
                    color: NowUIColors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                onPressed: _isButtonDisabled
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                          {
                            '_placeidasal': _placeidasal,
                            '_latitude_place_asal': _latitude_place_asal,
                            '_longitude_place_asal': _longitude_place_asal,
                            '_pelabuhanidasal': _pelabuhanidasal,
                            '_latitude_pelabuhan_asal':
                                _latitude_pelabuhan_asal,
                            '_longitude_pelabuhan_asal':
                                _longitude_pelabuhan_asal,
                            '_jarak_asal': distance,
                            '_waktu_asal': duration,
                            '_alamatasal': _destinationController.text,
                            'pengirim': _selectedpengirim.text,
                            'notelppengirim': _selectednotelppengirim.text,
                            'notepengirim': _selectednotepengirim.text,
                            'namapelabuhanpengirim': namapelabuhanpengirim,
                          },
                        );
                      },
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 12, bottom: 12),
                    child: Text("Next",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'Nunito-Medium',
                          fontWeight: FontWeight.bold,
                        ))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tracking() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20.0),
            const CircleAvatar(
              backgroundColor: Color(0xFF5599E9),
              child: Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text("Muat", style: TextStyle(fontSize: 14.0)),
          ],
        ),
        Container(
          width: 5.0,
        ),
        Container(
          color: const Color(0xFFC2C2C2),
          height: 1.0,
          width: 70.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20.0),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                '2',
                style: TextStyle(
                  color: Color(0xFFA5A5A5),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text("Bongkar", style: TextStyle(fontSize: 14.0)),
          ],
        ),
      ],
    );
  }

  Widget dropdownasal() {
    return Padding(
        padding: EdgeInsets.only(top: 15),
        child: Card(
            child: Container(
                padding: EdgeInsets.only(right: 24, left: 24, bottom: 36),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 32),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Lokasi Muat",
                              style: TextStyle(
                                  color: NowUIColors.text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PlacePicker(
                                    apiKey: globals.apikey,
                                    initialPosition: Asal.kInitialPosition,
                                    useCurrentLocation: location,
                                    selectInitialPosition: true,

                                    //usePlaceDetailSearch: true,
                                    onPlacePicked: (result) async {
                                      showPlacePicker(result);
                                      if (_destinationController
                                              .text.isNotEmpty &&
                                          _selectedpengirim.text.isNotEmpty &&
                                          _selectednotelppengirim
                                              .text.isNotEmpty) {
                                        setState(() {
                                          _isButtonDisabled = false;
                                        });
                                      } else {
                                        setState(() {
                                          _isButtonDisabled = true;
                                        });
                                      }
                                    },
                                    autocompleteLanguage: "id",
                                    region: 'id',
                                  );
                                },
                              ),
                            );
                          },
                          child: TextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Lokasi Muat',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 5,
                              // keyboardType: TextInputType.multiline,
                              controller: _destinationController,
                              textCapitalization: TextCapitalization.sentences),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Note',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            controller: _selectednotepengirim,
                            textCapitalization: TextCapitalization.sentences),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Pengirim',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                            controller: _selectedpengirim,
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (val) {
                              if (_destinationController.text.isNotEmpty &&
                                  _selectedpengirim.text.isNotEmpty &&
                                  _selectednotelppengirim.text.isNotEmpty) {
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                              } else {
                                setState(() {
                                  _isButtonDisabled = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'No.Telp',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            controller: _selectednotelppengirim,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                            ],
                            onChanged: (val) {
                              if (_destinationController.text.isNotEmpty &&
                                  _selectedpengirim.text.isNotEmpty &&
                                  _selectednotelppengirim.text.isNotEmpty) {
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                              } else {
                                setState(() {
                                  _isButtonDisabled = true;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Km (Kilometer)",
                              style: TextStyle(
                                  color: NowUIColors.text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                        ),
                      ),

                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text(
                                    '$distance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  // ),
                                ),
                                Center(
                                  child: Text(
                                    '$namapelabuhanpengirim',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                  // ),
                                ),
                                ButtonTheme(
                                  buttonColor: Colors.white70,
                                  minWidth: 10.0,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MapAsal(
                                                    origincontroller:
                                                        _originController,
                                                    destinationcontroller:
                                                        _destinationController
                                                            .text,
                                                  )));
                                    },
                                    child: Icon(Icons.map),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 15),
                      //   child: SizedBox(
                      //     height: 50,
                      //     child: GestureDetector(
                      //       onTap: () => showPlacePicker(),
                      //       child: TextFormField(
                      //         controller: _destinationController,
                      //         enabled: false,
                      //         decoration: InputDecoration(
                      //           labelText: 'Alamat Asal',
                      //           border: OutlineInputBorder(),
                      //         ),
                      //         keyboardType: TextInputType.text,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ))));
  }

  void _showDialog(BuildContext context, SimpleFontelicoProgressDialogType type,
      String text) async {
    if (_dialog == null) {
      _dialog = SimpleFontelicoProgressDialog(
          context: context, barrierDimisable: false);
    }
    if (type == SimpleFontelicoProgressDialogType.custom) {
      _dialog.show(
          message: text,
          type: type,
          width: 150.0,
          height: 75.0,
          loadingIndicator: Text(
            'C',
            style: TextStyle(fontSize: 24.0),
          ));
    } else {
      _dialog.show(
          message: text,
          type: type,
          horizontal: true,
          width: 150.0,
          height: 75.0,
          hideText: true,
          indicatorColor: Colors.blue);
    }
  }

  void showPlacePicker(PickResult result) async {
    print("placeid");
    print(result.placeId);
    _showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
    // Handle the result in your way
    try {
      var response = await http.get(
          Uri.parse(
              '${globals.url}/api-orderemkl/public/api/pesanan/getpelabuhan?data={"place_id":"${result.placeId}", "key":"${globals.apikey}"}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${globals.accessToken}',
          });
      if (response.statusCode == 500) {
        _dialog.hide();
        await globals.alertBerhasilPesan(
            context,
            "Mohon cek kembali koneksi internet WiFi/Data anda",
            'Tidak ada koneksi',
            'assets/imgs/no-internet.json');
      } else if (response.statusCode == 200) {
        var maps = await jsonDecode(response.body);
        if (maps['data'] == null) {
          _dialog.hide();
          await globals.alertBerhasilPesan(
              context,
              "Area belum masuk dalam daftar pengiriman",
              'Area tidak terdaftar',
              'assets/imgs/not-found.json');
        }
        print("masuk latitude");
        // print(data);
        _originController =
            '${maps['data']['latitude']}, ${maps['data']['longitude']}';
        _pelabuhanidasal = maps['data']['pelabuhan_id'];
        _latitude_pelabuhan_asal = maps['data']['latitude'];
        _longitude_pelabuhan_asal = maps['data']['longitude'];
        namapelabuhanpengirim = maps['data']['namapelabuhan'];
        globals.merchantid = maps['data']['merchant_id'];
        globals.merchantpassword = maps['data']['merchant_password'];
        location = false;
        setState(() {
          Asal.kInitialPosition = LatLng(double.parse(maps['data']['latitude']),
              double.parse(maps['data']['longitude']));
        });
      }
      setState(() {
        _destinationController.text = '${result.formattedAddress}';
        _placeidasal = result.placeId;
        Asal.kInitialPosition =
            LatLng(result.geometry.location.lat, result.geometry.location.lng);
        _latitude_place_asal = result.geometry.location.lat;
        _longitude_place_asal = result.geometry.location.lng;
      });
      if (_originController == "") {
        _dialog.hide();
        Navigator.of(context).pop();
      } else {
        setDirection(_originController, _destinationController.text);
      }
    } catch (e) {
      print("error response");
      print(e.toString());
    }
  }

  void setDirection(
      String originController, String destinationController) async {
    var directions = await LocationService().getDirections(
      originController,
      destinationController,
    );
    _goToPlace(
      directions['start_location']['lat'],
      directions['start_location']['lng'],
      directions['end_location']['lat'],
      directions['end_location']['lng'],
      directions['distance']['text'],
      directions['duration']['text'],
      directions['bounds_ne'],
      directions['bounds_sw'],
    );
    _dialog.hide();
    Navigator.of(context).pop();
    setState(() {});
  }

  Future<void> _goToPlace(
    double lat_origin,
    double lng_origin,
    double lat_destination,
    double lng_destination,
    String totalDistance,
    String totalDuration,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    setState(() {
      distance = totalDistance;
      duration = totalDuration;
    });
  }

  void updateDataDariFavorites(Object data_favorites) async {
    setState(
      () {
        _placeidasal =
            jsonDecode(jsonEncode(data_favorites))['_placeid'].toString();
        _pelabuhanidasal =
            jsonDecode(jsonEncode(data_favorites))['_pelabuhanid'].toString();
        _destinationController.text =
            jsonDecode(jsonEncode(data_favorites))['alamat'].toString();
        _selectedpengirim.text =
            jsonDecode(jsonEncode(data_favorites))['customer'].toString();
        _selectednotelppengirim.text =
            jsonDecode(jsonEncode(data_favorites))['notelp'].toString();
        _latitude_place_asal =
            jsonDecode(jsonEncode(data_favorites))['latitude_place'].toString();
        _longitude_place_asal =
            jsonDecode(jsonEncode(data_favorites))['longitude_place']
                .toString();
        namapelabuhanpengirim =
            jsonDecode(jsonEncode(data_favorites))['namapelabuhan'].toString();
        _selectednotepengirim.text =
            jsonDecode(jsonEncode(data_favorites))['note'].toString();
        location = false;
      },
    );

    setPelabuhan(_pelabuhanidasal);
    if (_destinationController.text.isNotEmpty &&
        _selectedpengirim.text.isNotEmpty &&
        _selectednotelppengirim.text.isNotEmpty) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }
}
