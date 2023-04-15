import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:material_dialogs/widgets/buttons/icon_outline_button.dart';
import 'package:now_ui_flutter/api/pdf_api.dart';
import 'package:now_ui_flutter/api/s&k/pdf_sk_api.dart';
import 'package:now_ui_flutter/providers/services.dart';
import 'package:now_ui_flutter/screens/CekOngkir/map_asal.dart';
import 'package:now_ui_flutter/services/LocationService.dart';
import 'package:provider/provider.dart';
import 'package:now_ui_flutter/constants/Theme.dart';
import 'package:now_ui_flutter/models/dart_models.dart';
import 'package:now_ui_flutter/screens/bayar.dart';
import 'package:dio/dio.dart';
import 'package:now_ui_flutter/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart'
    as Marker;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class Total extends StatefulWidget {
  final String origincontroller;
  final String placeidasal;
  final String pelabuhanidasal;
  final String latitude_pelabuhan_asal;
  final String longitude_pelabuhan_asal;
  final String jarakasal;
  final String waktuasal;
  final String namapengirim;
  final String notelppengirim;
  final String alamatdetailpengirim;
  final String notepengirim;
  //
  final String destinationcontroller;
  final String placeidtujuan;
  final String pelabuhanidtujuan;
  final String latitude_pelabuhan_tujuan;
  final String longitude_pelabuhan_tujuan;
  final String jaraktujuan;
  final String waktutujuan;
  final String namapenerima;
  final String notelppenerima;
  final String alamatdetailpenerima;
  final String notepenerima;
  final int container_id;
  final String nilaibarang;
  final String nilaibarang_asuransi;
  final String harga;
  final String qty;
  final String jenisbarang;
  final String namabarang;
  final String hargasatuan;
  final String keterangantambahan;

  const Total({
    Key key,
    this.origincontroller,
    this.destinationcontroller,
    this.harga,
    this.jarakasal,
    this.jaraktujuan,
    this.waktuasal,
    this.waktutujuan,
    this.placeidasal,
    this.pelabuhanidasal,
    this.latitude_pelabuhan_asal,
    this.longitude_pelabuhan_asal,
    this.namapengirim,
    this.notelppengirim,
    this.alamatdetailpengirim,
    this.placeidtujuan,
    this.pelabuhanidtujuan,
    this.latitude_pelabuhan_tujuan,
    this.longitude_pelabuhan_tujuan,
    this.namapenerima,
    this.notelppenerima,
    this.alamatdetailpenerima,
    this.container_id,
    this.nilaibarang,
    this.nilaibarang_asuransi,
    this.qty,
    this.jenisbarang,
    this.namabarang,
    this.hargasatuan,
    this.keterangantambahan,
    this.notepengirim,
    this.notepenerima,
  }) : super(key: key);
  @override
  _TotalState createState() => _TotalState();
}

class _TotalState extends State<Total> {
  Completer<GoogleMapController> _controller = Completer();
  SimpleFontelicoProgressDialog _dialog;
  Set<Marker.Marker> _markers_origin = {};
  // Set<Marker> _markers_origin = Set<Marker>();
  Set<Polygon> _polygon = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polygonLatLngs = <LatLng>[];
  // int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  String distance = '0 km';
  String duration = '0 day';

  String _selectedpembayaran;
  int isSyarat = 0;
  //bool syarat
  bool _isSyarat = false;

  bool _isButtondisabled = true;

  String payment;

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

  void initState() {
    super.initState();
    // setMap();
  }

  void setMap(String origin, String destination) async {
    var directions = await LocationService().getDirections(
      origin,
      destination,
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

    _setPolyline(directions['polyline_decoded']);
  }

  @override
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
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: "Distance: $distance",
            snippet: "Duration: $duration",
          ),
        ),
      );
    });
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 5,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  Future<bool> checkOrderan(var user_id) async {
    var data = {"id": user_id};
    var encode = jsonEncode(data);
    final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/pesanan/validasiorderan?data=$encode'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });

    return jsonDecode(response.body)['data'].length > 0;
    // if (response.statusCode == 200) {
    //   final result = jsonDecode(response.body);
    //   if (result['data'] != null) {
    //     return false;
    //   }
    // } else {
    //   throw Exception();
    // }
  }

  void getPembayaran(String payment_code) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${globals.url}/api-orderemkl/public/api/faspay/listofpayment'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        },
      );
      final result = jsonDecode(response.body);
      List<dynamic> pg_data = result['payment_channel'];
      List<dynamic> payment_name =
          pg_data.where((el) => el['pg_code'] == payment_code).toList();
      payment = payment_name[0]['pg_name'];
      print(payment);
      // pg_data.map((title) {
      //   if (title['pg_code'] == widget.payment_code) {
      //     print('berhasil');
      //   } else {
      //     print("ngga ada");
      //   }
      // });
    } catch (e) {
      print(e.toString());
    }
  }

  void BayarFunction(
    placeidasal,
    pelabuhanidasal,
    latitude_pelabuhan_asal,
    longitude_pelabuhan_asal,
    jarakasal,
    waktuasal,
    namapengirim,
    notelppengirim,
    alamatdetailpengirim,
    placeidtujuan,
    pelabuhanidtujuan,
    latitude_pelabuhan_tujuan,
    longitude_pelabuhan_tujuan,
    jaraktujuan,
    waktutujuan,
    namapenerima,
    notelppenerima,
    alamatdetailpenerima,
    container_id,
    nilaibarang_asuransi,
    harga,
    qty,
    jenisbarang,
    namabarang,
    keterangantambahan,
    selectedpembayaran,
    loggedinId,
    notepengirim,
    notepenerima,
    isSyarat,
  ) async {
    final harga_format =
        int.parse(harga.substring(2).replaceAll('.', '')).toString();
    Map<String, dynamic> data = {
      "placeidasal": placeidasal,
      "pelabuhanidasal": pelabuhanidasal,
      "latitude_pelabuhan_asal": latitude_pelabuhan_asal,
      "longitude_pelabuhan_asal": longitude_pelabuhan_asal,
      "jarakasal": jarakasal,
      "waktuasal": waktuasal,
      "namapengirim": namapengirim,
      "notelppengirim": notelppengirim,
      "alamatdetailpengirim": alamatdetailpengirim,
      "placeidtujuan": placeidtujuan,
      "pelabuhanidtujuan": pelabuhanidtujuan,
      "latitude_pelabuhan_tujuan": latitude_pelabuhan_tujuan,
      "longitude_pelabuhan_tujuan": longitude_pelabuhan_tujuan,
      "jaraktujuan": jaraktujuan,
      "waktutujuan": waktutujuan,
      "namapenerima": namapenerima,
      "notelppenerima": notelppenerima,
      "alamatdetailpenerima": alamatdetailpenerima,
      "container_id": container_id,
      "nilaibarang_asuransi": nilaibarang_asuransi,
      "harga": harga_format,
      "qty": qty,
      "jenisbarang": jenisbarang,
      "namabarang": namabarang,
      "keterangantambahan": keterangantambahan,
      "payment_code": selectedpembayaran,
      "user_id": loggedinId,
      "key": "${globals.apikey}",
      "note_pengirim": notepengirim,
      "note_penerima": notepenerima,
      "fcmToken": globals.fcmToken,
      "ischeck": isSyarat,
      "accessToken": globals.accessToken,
      "merchantid": globals.merchantid,
      "merchantpassword": globals.merchantpassword,
      "time": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      "utc": DateTime.now().toUtc().toLocal().timeZoneOffset.inHours,
    };
    // print('semuanya');
    // print(harga);
    List<dynamic> sk = await createPdfSyarat();
    await Provider.of<MasterProvider>(context, listen: false)
        .addPembayaran(
            data, sk, alamatdetailpengirim, alamatdetailpenerima, harga)
        .then((value) async {
      await getPembayaran(value.payment_name);
      _dialog.hide();
      await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Bayar(
                    lokasiMuat: value.lokasiMuat,
                    lokasiBongkar: value.lokasiBongkar,
                    harga_bayar: value.harga,
                    noVA: value.noVA,
                    payment_name: payment,
                    waktu_bayar: value.waktu_bayar,
                    bill_no: value.bill_no,
                    endDate: value.endDate,
                    link: 'Orderan',
                    nobukti: value.nobukti,
                  )));
    });
  }

  Future<List<dynamic>> createPdfSyarat() async {
    final response = await http.get(
        Uri.parse(
            'http://web.transporindo.com/api-orderemkl/public/api/syaratdanketentuan/getdatasyaratdanketentuan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${globals.accessToken}',
        });

    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return result['data'];
    } else {
      _dialog.hide();
      await globals.alertBerhasilPesan(
          context,
          "Mohon cek kembali koneksi internet WiFi/Data anda",
          'Tidak ada koneksi',
          'assets/imgs/no-internet.json');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFB7B7B7),
            )),
        title: Text(
          "Total Harga",
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
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 15.0),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Lokasi Muat',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              widget.origincontroller,
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Note',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              widget.notepengirim == ""
                                                  ? "Tidak ada"
                                                  : widget.notepengirim,
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Nama Pengirim',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              widget.namapengirim,
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'No. Telepon',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              widget.notelppengirim,
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Pelabuhan',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (widget.pelabuhanidasal == '1') ...[
                                        Expanded(
                                            child: Text(
                                          "Belawan",
                                          style: TextStyle(
                                            fontFamily: 'Nunito-Medium',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        )),
                                      ] else if (widget.pelabuhanidasal ==
                                          '2') ...[
                                        Expanded(
                                          child: Text(
                                            "Tanjung Priok",
                                            style: TextStyle(
                                              fontFamily: 'Nunito-Medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ] else if (widget.pelabuhanidasal ==
                                          '3') ...[
                                        Expanded(
                                          child: Text(
                                            "Tanjung Perak",
                                            style: TextStyle(
                                              fontFamily: 'Nunito-Medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ] else if (widget.pelabuhanidasal ==
                                          '4') ...[
                                        Expanded(
                                            child: Text(
                                          "Soekarno Hatta",
                                          style: TextStyle(
                                            fontFamily: 'Nunito-Medium',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        )),
                                      ],
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Jarak',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.jarakasal,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Lokasi Bongkar',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              widget.destinationcontroller,
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Note',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              widget.notepenerima == ""
                                                  ? "Tidak ada"
                                                  : widget.notepenerima,
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Nama Penerima',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              widget.namapenerima,
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'No. Telepon',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              // setMap(
                                              //     '${widget.latitude_pelabuhan_asal},${widget.longitude_pelabuhan_asal}',
                                              //     widget.origincontroller);
                                              // setState(() {
                                              //   distance = widget.jarakasal;
                                              //   duration = widget.waktuasal;
                                              // });
                                            },
                                            // Then wrap your text widget with expanded
                                            child: Text(
                                              widget.notelppenerima,
                                              style: TextStyle(
                                                fontFamily: 'Nunito-Medium',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Pelabuhan',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (widget.pelabuhanidtujuan == '1') ...[
                                        Expanded(
                                            child: Text(
                                          "Belawan",
                                          style: TextStyle(
                                            fontFamily: 'Nunito-Medium',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        )),
                                      ] else if (widget.pelabuhanidtujuan ==
                                          '2') ...[
                                        Expanded(
                                          child: Text(
                                            "Tanjung Priok",
                                            style: TextStyle(
                                              fontFamily: 'Nunito-Medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ] else if (widget.pelabuhanidtujuan ==
                                          '3') ...[
                                        Expanded(
                                          child: Text(
                                            "Tanjung Perak",
                                            style: TextStyle(
                                              fontFamily: 'Nunito-Medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ] else if (widget.pelabuhanidtujuan ==
                                          '4') ...[
                                        Expanded(
                                            child: Text(
                                          "Soekarno Hatta",
                                          style: TextStyle(
                                            fontFamily: 'Nunito-Medium',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        )),
                                      ],
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Jarak',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.jaraktujuan,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.0),
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Container',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (widget.container_id == 1) ...[
                                        Expanded(
                                            child: Text(
                                          "20 ft",
                                          style: TextStyle(
                                            fontFamily: 'Nunito-Medium',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        )),
                                      ] else if (widget.container_id == 2) ...[
                                        Expanded(
                                          child: Text(
                                            "40 ft",
                                            style: TextStyle(
                                              fontFamily: 'Nunito-Medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Nilai Barang (Asuransi)',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.nilaibarang,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Jenis Barang',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.jenisbarang,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Nama Barang',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.namabarang,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Keterangan Tambahan',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.keterangantambahan == ""
                                            ? "Tidak ada"
                                            : widget.keterangantambahan,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Qty',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.qty,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Harga Satuan',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.hargasatuan,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(width: 0.0),
                              Expanded(
                                  // Wrap this column inside an expanded widget so that framework allocates max width for this column inside this row
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Color(0xFF666666),
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Text(
                                        widget.harga,
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Medium',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      )),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: SizedBox(
                          height: 40,
                          child: DropdownSearch<Pembayaran>(
                            showAsSuffixIcons: true,
                            mode: Mode.BOTTOM_SHEET,
                            // items: _datacontainer,
                            dropdownSearchDecoration: InputDecoration(
                              hintText: "Pembayaran",
                              hintStyle: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixIcon: Icon(
                                Icons.credit_card_rounded,
                                color: Color(0xFF5599E9),
                              ),
                              contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                              border: OutlineInputBorder(),
                            ),
                            dropdownBuilder: (context, _selectedpembayaran) {
                              return Text(
                                _selectedpembayaran == null
                                    ? "Pembayaran"
                                    : _selectedpembayaran.toString(),
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedpembayaran == null
                                      ? Color.fromARGB(255, 114, 114, 114)
                                      : Colors.black,
                                ),
                              );
                            },
                            onFind: (String filter) async {
                              final url =
                                  '${globals.url}/api-orderemkl/public/api/faspay/listofpayment';
                              var response = await Dio().get(
                                url,
                                queryParameters: {"filter": filter},
                                options: Options(
                                  headers: {
                                    'Accept': 'application/json',
                                    'Content-type': 'application/json',
                                    'Authorization':
                                        'Bearer ${globals.accessToken}',
                                  },
                                ),
                              );
                              // print(jsonDecode(response.data)['payment_channel']);
                              var models = Pembayaran.fromJsonList(
                                  jsonDecode(response.data)['payment_channel']);
                              return models;
                            },
                            onChanged: (data) {
                              _selectedpembayaran = data.pg_code;
                              // if (_selectedpembayaran != null && isSyarat != 0) {
                              //   setState(() {
                              //     _isButtondisabled = false;
                              //   });
                              // } else {
                              //   _isButtondisabled = true;
                              // }
                            },
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 12, 8, 0),
                                labelText: "Cari Pembayaran",
                              ),
                            ),
                            popupTitle: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorDark,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Pembayaran',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            popupShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: Checkbox(
                        activeColor: Color(0xFF5599E9),
                        value: _isSyarat,
                        onChanged: (bool value) {
                          setState(() {
                            _isSyarat = value;
                            if (value == false) {
                              setState(() {
                                isSyarat = 0;
                              });
                            } else {
                              setState(() {
                                isSyarat = 1;
                              });
                            }
                            // if (_selectedpembayaran != null && isSyarat != 0) {
                            //   setState(() {
                            //     _isButtondisabled = false;
                            //   });
                            // } else {
                            //   _isButtondisabled = true;
                            // }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 2.0, bottom: 15.0, right: 8.0, left: 0.0),
                        child: RichText(
                          text: TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      'Dengan menyetujui pesanan sesuai dengan data informasi yang benar, anda setuju untuk '),
                              TextSpan(
                                  text: '',
                                  style: const TextStyle(
                                      color: Color(0xFF5599E9),
                                      decoration: TextDecoration.underline),
                                  children: [
                                    new TextSpan(
                                      text:
                                          'Syarat dan Ketentuan dan Pernyataan Privasi ',
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () => alert(),
                                    )
                                  ]),
                              TextSpan(text: 'kami.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
        // ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Container(
          height: 40.0,
          padding:
              EdgeInsets.only(left: 8.0, bottom: 5.0, top: 0.0, right: 8.0),
          child: ElevatedButton(
            onPressed: () async {
              //  && isSyarat != 0
              if (_selectedpembayaran == null) {
                await globals.alert(context, 'Pembayaran tidak boleh kosong');
              } else if (isSyarat == 0) {
                await globals.alert(
                    context, 'Mohon menyetujui syarat dan ketentuan');
              } else {
                // print("asdf");
                _showDialog(context, SimpleFontelicoProgressDialogType.normal,
                    'Normal');
                Future.delayed(const Duration(milliseconds: 2000), () {
                  // Navigator.pushNamed(context, '/payment_success');
                  BayarFunction(
                    widget.placeidasal,
                    widget.pelabuhanidasal,
                    widget.latitude_pelabuhan_asal,
                    widget.longitude_pelabuhan_asal,
                    widget.jarakasal,
                    widget.waktuasal,
                    widget.namapengirim,
                    widget.notelppengirim,
                    widget.origincontroller,
                    widget.placeidtujuan,
                    widget.pelabuhanidtujuan,
                    widget.latitude_pelabuhan_tujuan,
                    widget.longitude_pelabuhan_tujuan,
                    widget.jaraktujuan,
                    widget.waktutujuan,
                    widget.namapenerima,
                    widget.notelppenerima,
                    widget.destinationcontroller,
                    widget.container_id,
                    widget.nilaibarang_asuransi,
                    widget.harga,
                    widget.qty,
                    widget.jenisbarang,
                    widget.namabarang,
                    widget.keterangantambahan,
                    _selectedpembayaran,
                    globals.loggedinId,
                    widget.notepengirim,
                    widget.notepenerima,
                    isSyarat,
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5599E9),
            ),
            child: Text(
              "Pesan",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Nunito-Medium',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
            Text("Pesan", style: TextStyle(fontSize: 14.0)),
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
        Container(
          width: 5.0,
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
            Text("Total", style: TextStyle(fontSize: 14.0)),
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
        Container(
          width: 5.0,
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
            Text("Bayar", style: TextStyle(fontSize: 14.0)),
          ],
        ),
      ],
    );
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
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];
    // double totalDistance = 0;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat_origin, lng_origin),
      zoom: 12,
    )));

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25));
    setState(() {
      distance = totalDistance;
      duration = totalDuration;
    });
    _setMarker(LatLng(lat_origin, lng_origin),
        LatLng(lat_destination, lng_destination), distance);
    // _setMarkerDestination(LatLng(lat_destination, lng_destination));
  }

  Widget alertBerhasilPesan() {
    Dialogs.materialDialog(
        color: Colors.white,
        msg:
            'Anda belum bisa melakukan pemesanan orderan,silahkan menyelesaikan pembayaran yang sebelum terlebih dahulu',
        title: 'Gagal',
        lottieBuilder: Lottie.asset(
          'assets/imgs/updated-transaction.json',
          fit: BoxFit.contain,
        ),
        context: context,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.pop(context);
            },
            text: 'Ok',
            iconData: Icons.done,
            color: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);
  }

  Widget alert() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.9,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(100.0),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 15.0,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Syarat dan Ketentuan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Last Updated 12 Juli 2022",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey,
                            fontFamily: 'Nunito-Medium',
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(0.0),
                    child: Divider(
                      color: Color.fromARGB(255, 145, 145, 145),
                      indent: 0,
                      endIndent: 0,
                      height: 10.0,
                    ),
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Adapun Harga tersebut diatas berlaku dengan kondisi sebagai berikut:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "1. HARGA BELUM TERMASUK BIAYA KAWAL (JIKA ADA)",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "2. BELUM TERMASUK BIAYA BONGKAR MUAT DI LOKASI STUFFING / STRIPPING",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "3. BERLAKU UNTUK LOKASI YANG DAPAT MASUK CONTAINER ATAU TRAILER TANPA ADA LARANGAN (TIDAK TERMASUK UANG KAWAL)",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "4. MUATAN MAKSIMUM PETI KEMAS BESERTA ISINYA (BRUTTO) ADALAH 23 TON (20') & 26 TON (40').",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "5. FREETIME STORAGE DAN DEMURRAGE ADALAH 3 (TIGA) HARI DI TEMPAT TUJUAN (PEMBONGKARAN), APABILA LEBIH DARI 3 (TIGA) HARI MAKA SEGALA BIAYA DILUAR TANGGUNG JAWAB EKSPEDISI.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "6. EKSPEDISI TIDAK BERTANGGUNG JAWAB ATAS KERUGIAN AKIBAT FORCE MAJEUR (BENCANA ALAM), HURU - HARA, PERAMPOKAN, KERUSUHAN, PENJARAHAN / PEMBAJAKAN.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "7. EKSPEDISI TIDAK BERTANGGUNG JAWAB ATAS KEHILANGAN BARANG, KEKURANGAN, JIKA SEAL / PENGAMAN DALAM KEADAAN BAGUS.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "8. EKSPEDISI TIDAK BERTANGGUNG JAWAB ATAS PERUBAHAN KUALITAS BARANG DIKARENAKAN OLEH SIFAT BARANG ITU.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "9. DIANJURKAN PIHAK SHIPPER UNTUK MENGASURANSIKAN BARANGNYA DALAM KEADAAN ALL RISK WARE HOUSE TO WARE HOUSE.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "10. MUATAN TIDAK BOLEH BERAT SEBELAH, APABILA TERJADI MAKA SEGALA BIAYA DITANGGUNG PEMILIK BARANG.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "11.PEMILIK BARANG BERTANGGUNG JAWAB TERHADAP ISI MUATAN DARI AKIBAT HUKUM YANG TIMBUL DENGAN MEMBEBASKAN PERUSAHAAN PENGANGKUTAN DARI SEGALA INSTANSI YANG BERSANGKUTAN DAN BERSEDIA MENANGGUNG SEGALA BIAYA KERUGIAN YANG TIMBUL.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "12. PELUNASAN JASA EKSPEDISI PALING LAMBAT 1 (SATU) BULAN DARI TANGGAL KAPAL BERANGKAT SESUAI YANG TERCANTUM DI BL PELAYARAN.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "13. HARGA TIDAK MENGIKAT SEWAKTU WAKTU DAPAT BERUBAH.",
                                    style: TextStyle(
                                      fontFamily: 'Nunito-Medium',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
