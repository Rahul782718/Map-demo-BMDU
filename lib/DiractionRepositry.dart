import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '.env.dart';
import 'Directions.dart';

class DiractionRepositry{


  static const String _baseUrl = "https://maps.googleapis.com/maps/api/directions/json?";

   final Dio _dio;

   DiractionRepositry({ Dio? dio}) : _dio = dio ?? Dio();


  Future<Directions?> getDiractions({required LatLng origin, required LatLng destination}) async {
    try {
      final response = await _dio.get(_baseUrl, queryParameters: {
        "origin": "${origin.latitude},${origin.longitude}",
        "destination": "${destination.latitude},${destination.longitude}",
        "key": googleApiKey, // Key must be lowercase
      });



      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          print("Route fetched successfully.");
          return Directions.fromMap(data);
        } else {
          throw Exception("Google Maps API error: ${data['status']}");
        }
      } else {
        throw Exception("HTTP error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Direction API error: $e");
      rethrow;
    }
  }


}