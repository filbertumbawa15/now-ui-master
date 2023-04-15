import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/screens/CekOngkir/map_asal.dart';
import 'package:now_ui_flutter/services/LocationService.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: implementation_imports
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart'
    as Marker;
import 'package:http/http.dart' as http;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:now_ui_flutter/globals.dart' as globals;

class Tujuan_Ongkir extends StatefulWidget {
  final bool loggedIn;
  static var kInitialPosition = LatLng(-33.8567844, 151.213108);
  final String selectedlatitudeplacetujuan;
  final String selectedlongitudeplacetujuan;
  final String selectedpelabuhanidtujuan;
  final String selectedalamattujuan;
  final String selectedalamatpengirim;
  final String selectedpengirim;
  final String selectednotelppengirim;
  final String selectedplaceidtujuan;
  final String selectednamapelabuhan;

  const Tujuan_Ongkir(
      {Key key,
      this.loggedIn,
      this.selectedlatitudeplacetujuan,
      this.selectedlongitudeplacetujuan,
      this.selectedpelabuhanidtujuan,
      this.selectedalamattujuan,
      this.selectedalamatpengirim,
      this.selectedpengirim,
      this.selectednotelppengirim,
      this.selectedplaceidtujuan,
      this.selectednamapelabuhan})
      : super(key: key);
  @override
  State<Tujuan_Ongkir> createState() => _Tujuan_OngkirState();
}

class _Tujuan_OngkirState extends State<Tujuan_Ongkir> {
  PickResult selectedPlace;
  Completer<GoogleMapController> _controller = Completer();
  String _originController = '';
  TextEditingController _destinationController = TextEditingController();

  Set<Marker.Marker> _markers_origin = {};
  // Set<Marker> _markers_origin = Set<Marker>();
  Set<Polygon> _polygon = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polygonLatLngs = <LatLng>[];
  // int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  FocusNode _focus = FocusNode();

  GoogleMapController controller;

  bool location = true;

  String distance = '0.0 km';

  String duration = '0.0 min';

  MasterPelabuhan _selectedpelabuhan;

  SimpleFontelicoProgressDialog _dialog;

  // List<Marker> myMarker = [];
  bool _isButtonDisabled = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selectedpelabuhanidtujuan != null) {
      setPelabuhan();
      _placeidtujuan = widget.selectedplaceidtujuan;
      _pelabuhanidtujuan = widget.selectedpelabuhanidtujuan;
      _destinationController.text = widget.selectedalamattujuan;
      _selectedalamatpenerima.text = widget.selectedalamatpengirim;
      location = false;
      _latitude_place_tujuan = widget.selectedlatitudeplacetujuan;
      _longitude_place_tujuan = widget.selectedlongitudeplacetujuan;
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
            "${globals.url}/api-orderemkl/public/api/pelabuhan/combonamapelabuhan?id=${widget.selectedpelabuhanidtujuan}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });
    var pelabuhan = await jsonDecode(response.body);
    // print(pelabuhan['data'][0]);
    setState(() {
      _selectedpelabuhan = MasterPelabuhan.fromJson(pelabuhan['data'][0]);
      _latitude_pelabuhan_tujuan = _selectedpelabuhan.latitude;
      _longitude_pelabuhan_tujuan = _selectedpelabuhan.longitude;
      _originController =
          '$_latitude_pelabuhan_tujuan, $_longitude_pelabuhan_tujuan';
    });
    Tujuan_Ongkir.kInitialPosition = LatLng(
        double.parse(_latitude_place_tujuan),
        double.parse(_longitude_place_tujuan));
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

  // Data Tujuan
  var _placeidtujuan;
  var _latitude_place_tujuan;
  var _longitude_place_tujuan;
  var _pelabuhanidtujuan;
  var _latitude_pelabuhan_tujuan;
  var _longitude_pelabuhan_tujuan;
  TextEditingController _selectedalamatpenerima = new TextEditingController();
  var _namapelabuhan = '';

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
          "Data Bongkar (Penerima)",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            fontFamily: 'Nunito-Medium',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  dropdowntujuan(),
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
            shadowColor: NowUIColors.info,
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
                  //  else if (_selectedalamatpengirim.text == null) {
                  //   protect("Alamat Detail");
                  // }
                  if (mounted) {
                    Navigator.pop(context, {
                      '_placeidtujuan': _placeidtujuan,
                      '_latitude_place_tujuan': _latitude_place_tujuan,
                      '_longitude_place_tujuan': _longitude_place_tujuan,
                      '_pelabuhanidtujuan': _pelabuhanidtujuan,
                      '_latitude_pelabuhan_tujuan': _latitude_pelabuhan_tujuan,
                      '_longitude_pelabuhan_tujuan':
                          _longitude_pelabuhan_tujuan,
                      '_jarak_tujuan': distance,
                      '_waktu_tujuan': duration,
                      '_alamattujuan': _destinationController.text,
                      '_nama_pelabuhan_tujuan': _namapelabuhan,
                    });
                  }
                  // KirimDataTujuan(
                  //   _selectedprovinsitujuan,
                  //   _selectedkotatujuan,
                  //   _selectedkecamatantujuan,
                  //   _selectedkelurahantujuan,
                  //   _selectedpengirim.text,
                  //   _selectednotelppengirim.text,
                  //   _selectedalamatpengirim.text,
                  // );
                },
          child: Padding(
              padding:
                  EdgeInsets.only(left: 16.0, right: 16.0, top: 12, bottom: 12),
              child: Text("Kirim", style: TextStyle(fontSize: 14.0))),
        ),
      ),
    );
  }

  Widget dropdowntujuan() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 8.0, left: 16.0, right: 16.0),
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
                  color: Color(0xFFE95555),
                ),
                border: OutlineInputBorder(),
                label: Text('Lokasi Bongkar'),
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
                        apiKey: globals.apikey,
                        initialPosition: Tujuan_Ongkir.kInitialPosition,
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
                            setState(() {
                              _isButtonDisabled = true;
                            });
                          }
                        },
                        //forceSearchOnZoomChanged: true,
                        //automaticallyImplyAppBarLeading: false,
                        autocompleteLanguage: "id",
                        region: 'id',
                        //selectInitialPosition: true,
                        // selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
                        //   print("state: $state, isSearchBarFocused: $isSearchBarFocused");
                        //   return isSearchBarFocused
                        //       ? Container()
                        //       : FloatingCard(
                        //           bottomPosition: 0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                        //           leftPosition: 0.0,
                        //           rightPosition: 0.0,
                        //           width: 500,
                        //           borderRadius: BorderRadius.circular(12.0),
                        //           child: state == SearchingState.Searching
                        //               ? Center(child: CircularProgressIndicator())
                        //               : RaisedButton(
                        //                   child: Text("Pick Here"),
                        //                   onPressed: () {
                        //                     // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
                        //                     //            this will override default 'Select here' Button.
                        //                     print("do something with [selectedPlace] data");
                        //                     Navigator.of(context).pop();
                        //                   },
                        //                 ),
                        //         );
                        // },
                        // pinBuilder: (context, state) {
                        //   if (state == PinState.Idle) {
                        //     return Icon(Icons.favorite_border);
                        //   } else {
                        //     return Icon(Icons.favorite);
                        //   }
                        // },
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
        _pelabuhanidtujuan = maps['data']['pelabuhan_id'];
        _latitude_pelabuhan_tujuan = maps['data']['latitude'];
        _longitude_pelabuhan_tujuan = maps['data']['longitude'];
        _namapelabuhan = maps['data']['namapelabuhan'];
        location = false;
        setState(() {
          Tujuan_Ongkir.kInitialPosition = LatLng(
              double.parse(maps['data']['latitude']),
              double.parse(maps['data']['longitude']));
        });
      } else {
        print(response.headers);
      }
      setState(() {
        _destinationController.text = '${result.formattedAddress}';
        _selectedalamatpenerima.text = '${result.formattedAddress}';
        _placeidtujuan = result.placeId;
        Tujuan_Ongkir.kInitialPosition =
            LatLng(result.geometry.location.lat, result.geometry.location.lng);
        _latitude_place_tujuan = result.geometry.location.lat;
        _longitude_place_tujuan = result.geometry.location.lng;
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

  // void showPlacePicker(PickResult result) async {
  //   _showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
  //   // Handle the result in your way
  //   setState(() {
  //     _destinationController.text = '${result.formattedAddress}';
  //     _selectedalamatpengirim.text = '${result.formattedAddress}';
  //     _placeidtujuan = result.placeId;
  //     Tujuan_Ongkir.kInitialPosition =
  //         LatLng(result.geometry.location.lat, result.geometry.location.lng);
  //     _latitude_place_tujuan = result.geometry.location.lat;
  //     _longitude_place_tujuan = result.geometry.location.lng;
  //   });
  //   if (_originController == "") {
  //     _dialog.hide();
  //     Navigator.of(context).pop();
  //   } else {
  //     setDirection(_originController, _destinationController.text);
  //   }
  // }

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
