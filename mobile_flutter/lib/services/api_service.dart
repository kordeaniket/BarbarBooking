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

  Future<List<Barber>> fetchBarbers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/barbers'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Barber.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load barbers: ${response.statusCode}');
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

  Future<List<String>> fetchAvailableSlots(String token, String barberId, String date, String serviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/barbers/$barberId/slots?date=$date&serviceId=$serviceId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<String>();
      }
      return [];
    } catch (e) {
      print('Error fetching slots: $e');
      return [];
    }
  }

  Future<bool> createBooking(String token, Map<String, dynamic> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(bookingData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  Future<bool> createService(String token, Map<String, dynamic> serviceData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/barber/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(serviceData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating service: $e');
      return false;
    }
  }

  Future<List<Service>> fetchBarberServices(String token, String barberId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/barbers/$barberId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Barber Data: $data');
        final List<dynamic> servicesJson = data['services'] ?? [];
        return servicesJson.map((s) => Service.fromJson(s)).toList();
      }
      print('Failed to fetch barber services: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching barber services: $e');
      return [];
    }
  Future<bool> updateService(String token, String serviceId, Map<String, dynamic> serviceData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/mobile/barber/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(serviceData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  Future<bool> deleteService(String token, String serviceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/mobile/barber/services/$serviceId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }
}
