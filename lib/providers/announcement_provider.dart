import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/announcement.dart'; // Importa tu modelo

class AnnouncementProvider with ChangeNotifier {
  final _apiService = ApiService();
  
  // 🔥 Ahora la lista es de tipo List<Announcement>
  List<Announcement> _announcements = [];
  bool _isLoading = false;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;

  // Cargar anuncios de la BBDD
  Future<void> fetchAnnouncements(String flightNumber, int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 🔥 Ahora el servicio debe devolver List<Announcement> 
      // (ajustaremos el servicio abajo para que coincida)
      _announcements = await _apiService.getAnnouncements(flightNumber, userId);
    } catch (e) {
      _announcements = [];
      debugPrint("Error al obtener anuncios: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enviar anuncio y recargar la lista automáticamente
  Future<bool> addAnnouncement({
    required String origin,
    required String destination,
    required String dateStr,
    required String plazas,
    required String tipo,
    required String flightNumber,
    required int userId,
  }) async {
    final success = await _apiService.createAnnouncement(
      origin: origin,
      destination: destination,
      dateStr: dateStr,
      plazas: plazas,
      tipo: tipo,
      flightNumber: flightNumber,
      userId: userId,
    );

    if (success) {
      await fetchAnnouncements(flightNumber, userId);
    }
    return success;
  }
}