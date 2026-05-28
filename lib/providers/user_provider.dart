import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String _baseUrl = "http://localhost:8081/api/v1/users";

  Future<void> fetchUserProfile(int userId, String authToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        _userProfile = json.decode(response.body);
      } else {
        _errorMessage = "No se pudo cargar el perfil";
      }

         if (response.statusCode == 200) {
  final data = json.decode(response.body);
  print("DEBUG: Datos recibidos del backend: $data"); // Mira esto en la consola
  _userProfile = data;
}
    } catch (e) {
      _errorMessage = "Error de conexión con el servidor";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }
}