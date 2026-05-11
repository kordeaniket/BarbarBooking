import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  String? _userName;
  String? _role;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get userName => _userName;
  String? get name => _userName;
  String? get role => _role;
  String? get userId => _userId;

  Future<bool> login(String email, String password, {bool isBarber = false}) async {
    final endpoint = isBarber ? '/api/mobile/auth/barber/login' : '/api/mobile/auth/customer/login';
    
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['_id'];
        _userName = data['name'];
        _role = data['role'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userId', _userId!);
        await prefs.setString('userName', _userName!);
        await prefs.setString('role', _role!);
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String mobile, {
    bool isBarber = false,
    String? shopName,
    String? city,
    String? address,
    String? shopNumber,
    String? businessLicense,
  }) async {
    try {
      final endpoint = isBarber ? '/api/mobile/auth/barber/register' : '/api/mobile/auth/customer/register';
      
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'password': password,
        'mobile': mobile,
      };

      if (isBarber) {
        body.addAll({
          'shopName': shopName,
          'location': {'city': city, 'address': address},
          'shopNumber': shopNumber,
          'businessLicense': businessLicense,
        });
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        // Redirect to login for all roles after registration as per user request
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _role = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;
    
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _role = prefs.getString('role');
    notifyListeners();
  }
}
