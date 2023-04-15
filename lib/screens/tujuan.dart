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

class Tujuan extends StatefulWidget {
  final bool loggedIn;
  static var kInitialPosition = LatLng(-33.8567844, 151.213108);
  final String selectedlatitudeplacetujuan;
  final String selectedlongitudeplacetujuan;
  final String selectedpelabuhanidtujuan;
  final String selectedalamattujuan;
  final String selectedalamatpenerima;
  final String selectedpenerima;
  final String selectednotelppenerima;
  final String selectedplaceidtujuan;
  final String selectednotepenerima;
  final String selectednamapelabuhanpenerima;

  const Tujuan({
    Key key,
    this.loggedIn,
    this.selectedlatitudeplacetujuan,
    this.selectedlongitudeplacetujuan,
    this.selectedpelabuhanidtujuan,
    this.selectedalamattujuan,
    this.selectedalamatpenerima,
    this.selectedpenerima,
    this.selectednotelppenerima,
    this.selectedplaceidtujuan,
    this.selectednotepenerima,
    this.selectednamapelabuhanpenerima,
  }) : super(key: key);
  @override
  State<Tujuan> createState() => _TujuanState();
}

class _TujuanState extends State<Tujuan> {
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
  bool _isTextButtonDisabled = true;

  TextEditingController _favoritescontroller = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selectedpelabuhanidtujuan != null) {
      _placeidtujuan = widget.selectedplaceidtujuan;
      _pelabuhanidtujuan = widget.selectedpelabuhanidtujuan;
      _destinationController.text = widget.selectedalamattujuan;
      _selectedpenerima.text = widget.selectedpenerima;
      _selectednotelppenerima.text = widget.selectednotelppenerima;
      location = false;
      _latitude_place_tujuan = widget.selectedlatitudeplacetujuan;
      _longitude_place_tujuan = widget.selectedlongitudeplacetujuan;
      namapelabuhanpenerima = widget.selectednamapelabuhanpenerima;
      _selectednotepenerima.text = widget.selectednotepenerima;
      setPelabuhan(_pelabuhanidtujuan);
    }
    if (_destinationController.text.isNotEmpty &&
        _selectedpenerima.text.isNotEmpty &&
        _selectednotelppenerima.text.isNotEmpty) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      _isButtonDisabled = true;
    }
  }

  void setPelabuhan(String pelabuhanidTujuan) async {
    var response = await http.get(
        Uri.parse(
            "${globals.url}/api-orderemkl/public/api/pelabuhan/combonamapelabuhan?id=$pelabuhanidTujuan"),
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
    Tujuan.kInitialPosition = LatLng(double.parse(_latitude_place_tujuan),
        double.parse(_longitude_place_tujuan));
    await setEditedMap();
  }

  void setEditedMap() async {
    print(_originController);
    print(_destinationController.text);
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

  // Data tujuan
  var _placeidtujuan;
  var _latitude_place_tujuan;
  var _longitude_place_tujuan;
  var _pelabuhanidtujuan;
  var _latitude_pelabuhan_tujuan;
  var _longitude_pelabuhan_tujuan;
  var namapelabuhanpenerima = "-";
  TextEditingController _selectedpenerima = new TextEditingController();
  TextEditingController _selectednotelppenerima = new TextEditingController();
  TextEditingController _selectednotepenerima = new TextEditingController();

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
                                  color: Color(0xFFE95555),
                                ),
                                border: OutlineInputBorder(),
                                labelText: 'Lokasi Bongkar',
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
                                        initialPosition:
                                            Tujuan.kInitialPosition,
                                        useCurrentLocation: location,
                                        selectInitialPosition: true,

                                        //usePlaceDetailSearch: true,
                                        onPlacePicked: (result) {
                                          showPlacePicker(result);
                                          if (_destinationController
                                                  .text.isNotEmpty &&
                                              _selectedpenerima
                                                  .text.isNotEmpty &&
                                              _selectednotelppenerima
                                                  .text.isNotEmpty) {
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
                          fontSize: 13.0,
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
                        controller: _selectednotepenerima,
                        textCapitalization: TextCapitalization.sentences),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 17.0, right: 17.0),
                    child: SizedBox(
                      height: 36.0,
                      child: TextFormField(
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 15.0),
                            labelText: 'Penerima',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.text,
                          controller: _selectedpenerima,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (val) {
                            if (_destinationController.text.isNotEmpty &&
                                _selectedpenerima.text.isNotEmpty &&
                                _selectednotelppenerima.text.isNotEmpty) {
                              setState(() {
                                _isButtonDisabled = false;
                              });
                            } else {
                              _isButtonDisabled = true;
                            }
                          }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 17.0, right: 17.0),
                    child: SizedBox(
                      height: 36.0,
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 13.0,
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
                        controller: _selectednotelppenerima,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(13),
                        ],
                        onChanged: (val) {
                          if (_destinationController.text.isNotEmpty &&
                              _selectedpenerima.text.isNotEmpty &&
                              _selectednotelppenerima.text.isNotEmpty) {
                            setState(() {
                              _isButtonDisabled = false;
                            });
                          } else {
                            _isButtonDisabled = true;
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
                          child: Text('$namapelabuhanpenerima',
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
                                                  "placeid": _placeidtujuan,
                                                  "userId": globals.loggedinId,
                                                  "pelabuhanid":
                                                      _pelabuhanidtujuan,
                                                  "alamat":
                                                      _destinationController
                                                          .text,
                                                  "customer":
                                                      _selectedpenerima.text,
                                                  "notelpcustomer":
                                                      _selectednotelppenerima
                                                          .text,
                                                  "latitudeplace":
                                                      _latitude_place_tujuan,
                                                  "longitudeplace":
                                                      _longitude_place_tujuan,
                                                  "namapelabuhan":
                                                      namapelabuhanpenerima,
                                                  "note": _selectednotepenerima
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
                        Navigator.pop(context, {
                          '_placeidtujuan': _placeidtujuan,
                          '_latitude_place_tujuan': _latitude_place_tujuan,
                          '_longitude_place_tujuan': _longitude_place_tujuan,
                          '_pelabuhanidtujuan': _pelabuhanidtujuan,
                          '_latitude_pelabuhan_tujuan':
                              _latitude_pelabuhan_tujuan,
                          '_longitude_pelabuhan_tujuan':
                              _longitude_pelabuhan_tujuan,
                          '_jarak_tujuan': distance,
                          '_waktu_tujuan': duration,
                          '_alamattujuan': _destinationController.text,
                          'penerima': _selectedpenerima.text,
                          'notelppenerima': _selectednotelppenerima.text,
                          'notepenerima': _selectednotepenerima.text,
                          'namapelabuhanpenerima': namapelabuhanpenerima,
                        });
                      },
                child: Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 12, bottom: 12),
                    child: Text("Next", style: TextStyle(fontSize: 14.0))),
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
              backgroundColor: Colors.white,
              child: Text(
                '1',
                style: TextStyle(
                  color: Color(0xFFA5A5A5),
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
              backgroundColor: Color(0xFF5599E9),
              child: Text(
                '2',
                style: TextStyle(
                  color: Colors.white,
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

  Widget dropdowntujuan() {
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
                          child: Text("Tujuan",
                              style: TextStyle(
                                  color: NowUIColors.text,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 10),
                      //   child: SizedBox(
                      //     height: 40,
                      //     child: DropdownSearch<MasterPelabuhan>(
                      //       showAsSuffixIcons: true,
                      //       selectedItem: _selectedpelabuhan,
                      //       mode: Mode.BOTTOM_SHEET,
                      //       dropdownSearchDecoration: InputDecoration(
                      //         labelText: "Kota",
                      //         contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                      //         border: OutlineInputBorder(),
                      //       ),
                      //       onFind: (String filter) async {
                      //         var response = await Dio().get(
                      //           "${globals.url}/api-orderemkl/public/api/pelabuhan/combonamapelabuhan",
                      //         );
                      //         var models = MasterPelabuhan.fromJsonList(
                      //             response.data['data']);
                      //         return models;
                      //       },
                      //       onChanged: (data) async {
                      //         // print(data);
                      //         _originController =
                      //             '${data.latitude}, ${data.longitude}';
                      //         _pelabuhanidtujuan = data.id;
                      //         _latitude_pelabuhan_tujuan = data.latitude;
                      //         _longitude_pelabuhan_tujuan = data.longitude;
                      //         location = false;
                      //         setState(() {
                      //           tujuan.kInitialPosition = LatLng(
                      //               double.parse(data.latitude),
                      //               double.parse(data.longitude));
                      //         });
                      //         if (_destinationController.text == "") {
                      //           return false;
                      //         } else {
                      //           var directions =
                      //               await LocationService().getDirections(
                      //             _originController,
                      //             _destinationController.text,
                      //           );
                      //           _goToPlace(
                      //             directions['start_location']['lat'],
                      //             directions['start_location']['lng'],
                      //             directions['end_location']['lat'],
                      //             directions['end_location']['lng'],
                      //             directions['distance']['text'],
                      //             directions['duration']['text'],
                      //             directions['bounds_ne'],
                      //             directions['bounds_sw'],
                      //           );
                      //         }
                      //       },
                      //       showSearchBox: true,
                      //       searchFieldProps: TextFieldProps(
                      //         decoration: InputDecoration(
                      //           border: OutlineInputBorder(),
                      //           contentPadding:
                      //               EdgeInsets.fromLTRB(12, 12, 8, 0),
                      //           labelText: "Cari Pelabuhan",
                      //         ),
                      //       ),
                      //       popupTitle: Container(
                      //         height: 50,
                      //         decoration: BoxDecoration(
                      //           color: Theme.of(context).primaryColorDark,
                      //           borderRadius: BorderRadius.only(
                      //             topLeft: Radius.circular(0),
                      //             topRight: Radius.circular(0),
                      //           ),
                      //         ),
                      //         child: Center(
                      //           child: Text(
                      //             'Pelabuhan',
                      //             style: TextStyle(
                      //               fontSize: 24,
                      //               fontWeight: FontWeight.bold,
                      //               color: Colors.white,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       popupShape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(0),
                      //           topRight: Radius.circular(0),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                                    initialPosition: Tujuan.kInitialPosition,
                                    useCurrentLocation: location,
                                    selectInitialPosition: true,

                                    //usePlaceDetailSearch: true,
                                    onPlacePicked: (result) {
                                      showPlacePicker(result);
                                      if (_destinationController
                                              .text.isNotEmpty &&
                                          _selectedpenerima.text.isNotEmpty &&
                                          _selectednotelppenerima
                                              .text.isNotEmpty) {
                                        setState(() {
                                          _isButtonDisabled = false;
                                        });
                                      } else {
                                        _isButtonDisabled = true;
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
                          child: TextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Alamat Tujuan',
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
                            controller: _selectednotepenerima,
                            textCapitalization: TextCapitalization.sentences),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SizedBox(
                          height: 50,
                          child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Penerima',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.text,
                              controller: _selectedpenerima,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: (val) {
                                if (_destinationController.text.isNotEmpty &&
                                    _selectedpenerima.text.isNotEmpty &&
                                    _selectednotelppenerima.text.isNotEmpty) {
                                  setState(() {
                                    _isButtonDisabled = false;
                                  });
                                } else {
                                  _isButtonDisabled = true;
                                }
                              }),
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
                            controller: _selectednotelppenerima,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                            ],
                            onChanged: (val) {
                              if (_destinationController.text.isNotEmpty &&
                                  _selectedpenerima.text.isNotEmpty &&
                                  _selectednotelppenerima.text.isNotEmpty) {
                                setState(() {
                                  _isButtonDisabled = false;
                                });
                              } else {
                                _isButtonDisabled = true;
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
                          // Visibility(
                          //     visible: false,
                          //     child: Container(
                          //         margin: EdgeInsets.only(top: 50, bottom: 30),
                          //         child: CircularProgressIndicator())),
                          // visible
                          //     ? Container(
                          //         margin: EdgeInsets.only(top: 50, bottom: 30),
                          //         child: CircularProgressIndicator())
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            // child: Align(
                            // alignment: Alignment.centerLeft,
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
                                    '${namapelabuhanpenerima}',
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
                      //           labelText: 'Alamat tujuan',
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
        print(maps);
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
        namapelabuhanpenerima = maps['data']['namapelabuhan'];
        location = false;
        setState(() {
          Tujuan.kInitialPosition = LatLng(
              double.parse(maps['data']['latitude']),
              double.parse(maps['data']['longitude']));
        });
      }
      setState(() {
        _destinationController.text = '${result.formattedAddress}';
        _placeidtujuan = result.placeId;
        Tujuan.kInitialPosition =
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

  void setDirection(
      String originController, String destinationController) async {
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
        _placeidtujuan =
            jsonDecode(jsonEncode(data_favorites))['_placeid'].toString();
        _pelabuhanidtujuan =
            jsonDecode(jsonEncode(data_favorites))['_pelabuhanid'].toString();
        _destinationController.text =
            jsonDecode(jsonEncode(data_favorites))['alamat'].toString();
        _selectedpenerima.text =
            jsonDecode(jsonEncode(data_favorites))['customer'].toString();
        _selectednotelppenerima.text =
            jsonDecode(jsonEncode(data_favorites))['notelp'].toString();
        _latitude_place_tujuan =
            jsonDecode(jsonEncode(data_favorites))['latitude_place'].toString();
        _longitude_place_tujuan =
            jsonDecode(jsonEncode(data_favorites))['longitude_place']
                .toString();
        namapelabuhanpenerima =
            jsonDecode(jsonEncode(data_favorites))['namapelabuhan'].toString();
        _selectednotepenerima.text =
            jsonDecode(jsonEncode(data_favorites))['note'].toString();
        location = false;
      },
    );
    setPelabuhan(_pelabuhanidtujuan);
    if (_destinationController.text.isNotEmpty &&
        _selectedpenerima.text.isNotEmpty &&
        _selectednotelppenerima.text.isNotEmpty) {
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
