import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/barber.dart';

class ApiService {
  // Automatically switch between localhost (Web/iOS) and 10.0.2.2 (Android Emulator)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    return 'http://10.0.2.2:5000';
  }

  Future<List<Barber>> fetchBarbers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/mobile/barbers'));

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
