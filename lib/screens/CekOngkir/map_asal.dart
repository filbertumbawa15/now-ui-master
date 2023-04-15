import 'dart:async';
// import 'package:api_google_app/bloc/application_blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:now_ui_flutter/services/LocationService.dart';
// import 'package:place_picker/place_picker.dart';

class MapAsal extends StatefulWidget {
  final String origincontroller;
  final String destinationcontroller;

  const MapAsal({
    Key key,
    this.origincontroller,
    this.destinationcontroller,
  }) : super(key: key);
  @override
  _MapAsalState createState() => _MapAsalState();
}

class _MapAsalState extends State<MapAsal> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers_origin = {};
  // Set<Marker> _markers_origin = Set<Marker>();
  Set<Polygon> _polygon = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polygonLatLngs = <LatLng>[];
  // int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  String distance = '';
  String duration = '';

  GoogleMapController controller;

  List<Marker> myMarker = [];
  @override
  void initState() {
    super.initState();
    setMap();
  }

  void setMap() async {
    var directions = await LocationService().getDirections(
      widget.origincontroller,
      widget.destinationcontroller,
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

  void _setMarker(LatLng point, LatLng destination, String distance) {
    setState(() {
      _markers_origin.add(
        Marker(
          markerId: MarkerId('marker_origin'),
          position: point,
          // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
          infoWindow: InfoWindow(
            title: "Distance: $distance",
          ),
        ),
      );
      _markers_origin.add(
        Marker(
          markerId: MarkerId('marker_destination'),
          position: destination,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: "Distance: $distance",
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

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_new
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jarak Map",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          child: Container(
            alignment: Alignment.center,
            color: Color(0xFFFFFFFF),
            constraints: BoxConstraints.expand(height: 56),
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      Text("Marker Lokasi"),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                      Text("Marker Pelabuhan"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          preferredSize: Size(50, 50),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFFB7B7B7),
            )),
        backgroundColor: Color(0xFFFFFFFF),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(children: [
              GoogleMap(
                mapType: MapType.normal,
                markers: _markers_origin,
                polygons: _polygon,
                polylines: _polylines,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    3.5803122929573736,
                    98.67475364293755,
                  ),
                  zoom: 18,
                ),
                // onTap: _handleTap,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ]),
          ),

          // ],
          // ),
        ],
      ),
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

  // double calculateDistance(lat1, lon1, lat2, lon2) {
  //   var p = 0.017453292519943295;
  //   var a = 0.5 -
  //       cos((lat2 - lat1) * p) / 2 +
  //       cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  //   return 12742 * asin(sqrt(a));
  // }
}
