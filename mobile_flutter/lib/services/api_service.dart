import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barber.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost, 
  // or your machine's IP for physical devices.
  static const String baseUrl = 'http://10.0.2.2:5000';

  Future<List<Barber>> fetchBarbers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mobile/barbers'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Barber.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load barbers');
      }
    } catch (e) {
      print('Error fetching barbers: $e');
      return [];
    }
  }

  String getFullImageUrl(String? path) {
    if (path == null) return '';
    return '$baseUrl$path';
  }
}
