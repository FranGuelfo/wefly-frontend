import 'dart:developer';
import 'package:universal_html/html.dart' as html;
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/flight.dart';
import '../models/announcement.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8081/api/v1',
      connectTimeout: const Duration(seconds: 5),
    ),
  );

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = html.window.localStorage['auth_token'];

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(
            options,
          ); // Convertido en return para evitar bloqueos
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            log('⚠️ Error 401: Token no válido o expirado.');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<Flight>> getFlights() async {
    try {
      final response = await _dio.get('/flights');
      return (response.data as List).map((e) => Flight.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Error al cargar vuelos");
    }
  }

  // Añade esta URL arriba junto a las demás
  final String _usersUrl = "/users";

  // Método para obtener los datos del creador del anuncio
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _dio.get("$_usersUrl/$userId");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          "Error al obtener perfil del usuario: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error de red al obtener perfil: $e");
    }
  }

  Future<UserProfile> updateUserProfile(
    int userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('/users/$userId', data: data);
      return UserProfile.fromJson(response.data);
    } catch (e) {
      throw Exception("Error al actualizar perfil");
    }
  }

  Future<void> updateAnnouncement(
    int announcementId,
    int userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _dio.patch(
        '/announcements/$announcementId',
        queryParameters: {'userId': userId},
        data: data,
      );
    } catch (e) {
      throw Exception("Error al editar anuncio");
    }
  }

  Future<bool> joinFlight({
    required int userId,
    required String flightNumber,
    required String reservationCode,
  }) async {
    try {
      final response = await _dio.post(
        '/flights/join',
        data: {
          "userId": userId,
          "flightNumber": flightNumber,
          "reservationCode": reservationCode,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, st) {
      log("Error al unirse al vuelo con Dio", error: e, stackTrace: st);
      return false;
    }
  }

  Future<void> deleteAnnouncement(int id, int userId) async {
    try {
      await _dio.delete(
        '/announcements/$id',
        queryParameters: {'userId': userId},
      );
    } catch (e) {
      throw Exception("No se pudo eliminar el anuncio: $e");
    }
  }

  Future<List<UserProfile>> getUsersByFlight(String flightNumber) async {
    try {
      final response = await _dio.get('/flights/$flightNumber/users');
      return (response.data as List)
          .map((e) => UserProfile.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception("Error al cargar usuarios del vuelo");
    }
  }

  // Base path para anuncios (usa el mismo baseUrl de Dio)
  final String _announcementsPath = "/announcements";

  // 1. Guardar anuncio en la BBDD de Spring Boot usando Dio
  Future<bool> createAnnouncement({
    required String origin,
    required String destination,
    required String dateStr,
    required String plazas,
    required String tipo,
    required String flightNumber,
    required int userId,
  }) async {
    try {
      final response = await _dio.post(
        '$_announcementsPath/create',
        data: {
          'origin': origin,
          'destination': destination,
          'dateStr': dateStr,
          'plazas': plazas,
          'tipo': tipo,
          'flightNumber': flightNumber,
          'userId': userId,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 2. Recuperar la lista de anuncios reales de un vuelo usando Dio
  Future<List<Announcement>> getAnnouncements(
    String flightNumber,
    int userId,
  ) async {
    try {
      final response = await _dio.get(
        '$_announcementsPath/flight/$flightNumber',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        // Convertimos el JSON directamente a una lista de objetos Announcement
        final List<dynamic> data = response.data;
        return data.map((json) => Announcement.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<bool> rejectBooking(int bookingId) async {
    try {
      // Apunta a /bookings/reject/{id} usando DELETE
      final response = await _dio.delete('/bookings/reject/$bookingId');
      
      return response.statusCode == 200;
    } catch (e, st) {
      log("Error al rechazar la reserva con Dio", error: e, stackTrace: st);
      return false;
    }
  }
}
