import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  List<Booking> get pendingBookings => 
    _bookings.where((b) => b.status == 'pending').toList();
  
  List<Booking> get confirmedBookings => 
    _bookings.where((b) => b.status == 'confirmed').toList();

  Future<void> fetchBookings(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/mobile/bookings/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _bookings = data.map((item) => Booking.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus(String token, String bookingId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/mobile/bookings/$bookingId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        // Update local state
        final index = _bookings.indexWhere((b) => b.id == bookingId);
        if (index != -1) {
          final updatedBooking = Booking(
            id: _bookings[index].id,
            customerName: _bookings[index].customerName,
            customerMobile: _bookings[index].customerMobile,
            serviceName: _bookings[index].serviceName,
            servicePrice: _bookings[index].servicePrice,
            date: _bookings[index].date,
            startTime: _bookings[index].startTime,
            status: status,
          );
          _bookings[index] = updatedBooking;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }
}
