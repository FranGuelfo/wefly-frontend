import 'dart:developer';
import 'package:universal_html/html.dart' as html; // Web seguro y multi-plataforma
import 'package:dio/dio.dart';
import '../models/announcement.dart';
import '../models/user_model.dart';
import '../models/flight.dart';

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

          return handler.next(options); // Convertido en return para evitar bloqueos
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

  Future<List<Announcement>> getAnnouncements(String flight, int userId) async {
    try {
      final response = await _dio.get(
        '/announcements/flight/$flight',
        queryParameters: {'userId': userId},
      );
      return (response.data as List)
          .map((e) => Announcement.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? "Error de conexión";
    }
  }

  Future<UserProfile> getUserProfile(int userId) async {
    final response = await _dio.get('/users/$userId');
    return UserProfile.fromJson(response.data);
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

  Future<void> createAnnouncement(int userId, Map<String, dynamic> data) async {
    try {
      await _dio.post(
        '/announcements',
        queryParameters: {'userId': userId},
        data: data,
      );
    } catch (e) {
      throw Exception("Error al crear anuncio");
    }
  }

  Future<void> updateAnnouncement(int announcementId, int userId, Map<String, dynamic> data) async {
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
        'http://localhost:8081/api/v1/flights/join',
        queryParameters: {
          'userId': userId,
          'flightNumber': flightNumber,
          'reservationCode': reservationCode,
        },
      );
      return response.statusCode == 200;
    } catch (e, st) {
      log("Error al unirse al vuelo", error: e, stackTrace: st);
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
} // <- Solo una llave final cerrando la clase ApiService