import 'package:dio/dio.dart';
import '../models/announcement.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8081/api/v1', // Tu IP si pruebas en móvil real
    connectTimeout: const Duration(seconds: 5),
  ));

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
      // Aquí capturarás el "Acceso denegado" del Backend
      throw e.response?.data['message'] ?? "Error de conexión";
    }
  }
}