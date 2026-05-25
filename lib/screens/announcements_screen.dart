import 'package:flutter/material.dart';
import '../theme/wefly_theme.dart';
import '../models/announcement.dart';
import '../services/api_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final ApiService _apiService = ApiService();
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 🔥 Apuntamos a tu endpoint real con PathVariable y QueryParam
      // Simulamos: Vuelo IB3110 y Usuario 2 (Mila)
      const String flightCode = "IB3110";
      const int currentUserId = 2; 

      // Usamos el servicio unificado
      final announcements = await _apiService.getAnnouncements(flightCode, currentUserId);
      
      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e.toString().contains("denegado") || e.toString().contains("403")) {
          _errorMessage = "Acceso denegado: Debes verificar tu vuelo para ver el tablón.";
        } else {
          _errorMessage = "Error al conectar con el tablón del vuelo.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Comunidad WeFly', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: WeFlyTheme.orangePrimary),
            onPressed: _fetchAnnouncements,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: WeFlyTheme.orangePrimary))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _announcements.isEmpty
                  ? const Center(child: Text('No hay anuncios publicados para tus vuelos.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _announcements.length,
                      itemBuilder: (context, index) {
                        final ann = _announcements[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- ENCABEZADO: AUTOR Y VUELO ---
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: (ann.authorPhoto?.isNotEmpty ?? false) 
                                        ? NetworkImage(ann.authorPhoto!) 
                                        : null,
                                    child: (ann.authorPhoto?.isEmpty ?? true) ? const Icon(Icons.person) : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ann.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text('Vuelo: ${ann.flightNumber}', style: const TextStyle(color: WeFlyTheme.orangePrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      ann.type ?? 'GENERAL', 
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              
                              // --- CUERPO DEL ANUNCIO ---
                              Text(ann.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(ann.description, style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4)),
                              const SizedBox(height: 20),
                              
                              // --- PIE DE TARJETA ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.event_seat, size: 18, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text('${ann.seatsAvailable} plazas libres', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Aquí irá la acción para contactar o unirse al plan
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    ),
                                    child: const Text('Unirme', style: TextStyle(fontWeight: FontWeight.bold)),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}