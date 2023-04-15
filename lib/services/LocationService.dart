import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:now_ui_flutter/globals.dart' as globals;

class LocationService {
  final String key = 'AIzaSyDBc9RaIaig6eEiiCKpEf1qYKpEyyKgpe4';
  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';
    print(url);
    var response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${globals.accessToken}',
    });
    var json = convert.jsonDecode(response.body);

    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'distance': json['routes'][0]['legs'][0]['distance'],
      'duration': json['routes'][0]['legs'][0]['duration'],
      'polyline_decoded': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };

    return results;
  }
}
