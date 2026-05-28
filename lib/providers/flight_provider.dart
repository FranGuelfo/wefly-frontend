import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class FlightProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _currentFlight;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentFlight => _currentFlight;
  String? get errorMessage => _errorMessage;

  // Nota: Usa '10.0.2.2' si estás en el emulador oficial de Android, o tu IP local (ej: 192.168.1.X) si pruebas con móvil real.
  final String _baseUrl = "http://localhost:8081/api/v1/flights";

  Future<bool> verifyAndLoadFlight(String flightCode, String authToken) async {
    _isLoading = true;
    _errorMessage = null;
    _currentFlight = null;
    notifyListeners();

    try {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse('$_baseUrl/$flightCode'));
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $authToken',
        );

        final response = await request.close().timeout(
          const Duration(seconds: 10),
        );

        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          final data = json.decode(body);

          // Extraemos el objeto 'flight' tal y como lo escupe tu Spring Boot
          _currentFlight = data['flight'];

          _isLoading = false;
          notifyListeners();
          return true;
        } else if (response.statusCode == 404) {
          _errorMessage = "No se pudo verificar el vuelo en este momento.";
        } else {
          _errorMessage = "Error en el servidor (${response.statusCode})";
        }
      } finally {
        client.close(force: true);
      }
    } catch (e) {
      _errorMessage = "No se pudo conectar con el servidor central de WeFly";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> joinFlight(int flightId, int userId, String reservationCode, String authToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final body = json.encode({
      "flightId": flightId, 
      "userId": userId,
      "reservationCode": reservationCode
    });
    
    print("ENVIANDO A API: $body"); 

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: body,
      );

      // ¡AÑADE ESTO!
      print("RESPUESTA DEL SERVIDOR: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Manejo de errores del servidor
        final Map<String, dynamic> errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? "Error al unirse al plan";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Error de conexión: No se pudo contactar con el servidor";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 1. Obtener la lista de solicitudes pendientes para el dueño del anuncio
  Future<List<dynamic>> getPendingBookings(int flightId, String authToken) async {
    try {
      // Ajusta la URL según la ruta que definimos en el Controller: /api/bookings/pending/{flightId}
      final response = await http.get(
        Uri.parse('http://localhost:8081/api/v1/bookings/pending/$flightId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      print("Error obteniendo pendientes: $e");
      return [];
    }
  }

  // 2. Aprobar una solicitud específica
  Future<bool> approveBooking(int bookingId, String authToken) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8081/api/v1/bookings/approve/$bookingId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error al aprobar: $e");
      return false;
    }
  }

  // 3. Rechazar una solicitud específica
  Future<bool> rejectBooking(int bookingId, String authToken) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8081/api/v1/bookings/reject/$bookingId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error al rechazar: $e");
      return false;
    }
  }
}
