import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/screens/CekOngkir/map_asal.dart';
import 'package:now_ui_flutter/services/LocationService.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart'
    as Marker;
import 'package:http/http.dart' as http;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:now_ui_flutter/globals.dart' as globals;

class Asal_Ongkir extends StatefulWidget {
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
  final String selectednamapelabuhan;

  const Asal_Ongkir(
      {Key key,
      this.loggedIn,
      this.selectedlatitudeplaceasal,
      this.selectedlongitudeplaceasal,
      this.selectedpelabuhanidasal,
      this.selectedalamatasal,
      this.selectedalamatpengirim,
      this.selectedpengirim,
      this.selectednotelppengirim,
      this.selectedplaceidasal,
      this.selectednamapelabuhan})
      : super(key: key);
  @override
  State<Asal_Ongkir> createState() => _Asal_OngkirState();
}

class _Asal_OngkirState extends State<Asal_Ongkir> {
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

  String _namapelabuhan = '';
  // List<Marker> myMarker = [];
  bool _isButtonDisabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.selectedpelabuhanidasal != null) {
      setPelabuhan();
      _placeidasal = widget.selectedplaceidasal;
      _pelabuhanidasal = widget.selectedpelabuhanidasal;
      _destinationController.text = widget.selectedalamatasal;
      _selectedalamatpengirim.text = widget.selectedalamatpengirim;
      location = false;
      _latitude_place_asal = widget.selectedlatitudeplaceasal;
      _longitude_place_asal = widget.selectedlongitudeplaceasal;
      _namapelabuhan = widget.selectednamapelabuhan;
    }
    if (_destinationController.text.isNotEmpty) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      _isButtonDisabled = true;
    }
  }

  void setPelabuhan() async {
    var response = await http.get(
      Uri.parse(
          "${globals.url}/api-orderemkl/public/api/pelabuhan/combonamapelabuhan?id=${widget.selectedpelabuhanidasal}"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${globals.accessToken}',
      },
    );
    var pelabuhan = await jsonDecode(response.body);
    // print(pelabuhan['data'][0]);
    setState(() {
      _selectedpelabuhan = MasterPelabuhan.fromJson(pelabuhan['data'][0]);
      _latitude_pelabuhan_asal = _selectedpelabuhan.latitude;
      _longitude_pelabuhan_asal = _selectedpelabuhan.longitude;
      _originController =
          '$_latitude_pelabuhan_asal, $_longitude_pelabuhan_asal';
    });
    Asal_Ongkir.kInitialPosition = LatLng(
        double.parse(widget.selectedlatitudeplaceasal),
        double.parse(widget.selectedlongitudeplaceasal));
    setEditedMap();
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
  TextEditingController _selectedalamatpengirim = new TextEditingController();

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
          SizedBox(height: 30.0),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dropdownasal(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            top: 8.0, bottom: 8.0, left: 17.0, right: 17.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              color: NowUIColors.white,
            ),
            backgroundColor: Color(0xFF5599E9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          onPressed: _isButtonDisabled
              ? null
              : () {
                  if (mounted) {
                    Navigator.pop(
                      context,
                      {
                        '_placeidasal': _placeidasal,
                        '_latitude_place_asal': _latitude_place_asal,
                        '_longitude_place_asal': _longitude_place_asal,
                        '_pelabuhanidasal': _pelabuhanidasal,
                        '_latitude_pelabuhan_asal': _latitude_pelabuhan_asal,
                        '_longitude_pelabuhan_asal': _longitude_pelabuhan_asal,
                        '_jarak_asal': distance,
                        '_waktu_asal': duration,
                        '_alamatasal': _destinationController.text,
                        '_nama_pelabuhan_asal': _namapelabuhan,
                      },
                    );
                  }
                },
          child: Padding(
              padding:
                  EdgeInsets.only(left: 16.0, right: 16.0, top: 12, bottom: 12),
              child: Text("Kirim", style: TextStyle(fontSize: 14.0))),
        ),
      ),
    );
  }

  Widget dropdownasal() {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, bottom: 8.0, left: 17.0, right: 17.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: TextField(
              readOnly: true,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 15.0),
                suffixIcon: Icon(
                  Icons.pin_drop,
                  color: Color(0xFF5599E9),
                ),
                border: OutlineInputBorder(),
                label: Text('Lokasi Muat'),
                labelStyle: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              controller: _destinationController,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PlacePicker(
                        apiKey: "${globals.apikey}",
                        initialPosition: Asal_Ongkir.kInitialPosition,
                        useCurrentLocation: location,
                        selectInitialPosition: true,
                        //usePlaceDetailSearch: true,
                        onPlacePicked: (result) async {
                          await showPlacePicker(result);
                          if (_destinationController.text.isNotEmpty) {
                            setState(() {
                              _isButtonDisabled = false;
                            });
                          } else {
                            _isButtonDisabled = true;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 17.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Jarak",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Nunito-Medium')),
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
                padding:
                    const EdgeInsets.only(top: 15.0, bottom: 50.0, left: 17.0),
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
                padding:
                    const EdgeInsets.only(top: 15.0, bottom: 50.0, right: 17.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('$_namapelabuhan',
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
    );
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
    _showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
    print(result.placeId);
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
        _namapelabuhan = maps['data']['namapelabuhan'];
        location = false;
        setState(() {
          Asal_Ongkir.kInitialPosition = LatLng(
              double.parse(maps['data']['latitude']),
              double.parse(maps['data']['longitude']));
        });
      } else {
        print(response.headers);
      }
      setState(() {
        _destinationController.text = '${result.formattedAddress}';
        _selectedalamatpengirim.text = '${result.formattedAddress}';
        _placeidasal = result.placeId;
        Asal_Ongkir.kInitialPosition =
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

  Widget protect(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text + ' Harus Diisi')),
    );
  }

  // ignore: missing_return
}
