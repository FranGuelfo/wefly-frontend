import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/announcement.dart';
import 'create_announcement_screen.dart';

class BoardScreen extends StatefulWidget {
  final String flightNumber;
  final int userId;

  const BoardScreen({
    super.key,
    required this.flightNumber,
    required this.userId,
  });

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final ApiService apiService = ApiService();

  // Función para dar color según la categoría
  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'TO_AIRPORT':
        return Colors.blue.shade400;
      case 'FROM_AIRPORT':
        return Colors.green.shade400;
      case 'LEISURE':
        return Colors.purple.shade400;
      default:
        return Colors.orange.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Vuelo ${widget.flightNumber}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      // BOTÓN PARA CREAR ANUNCIO
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Navegamos y esperamos a que vuelva
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAnnouncementScreen(
                flightNumber: widget.flightNumber,
                userId: widget.userId,
              ),
            ),
          );
          // Al volver, refrescamos la pantalla
          setState(() {});
        },
      ),
      body: FutureBuilder<List<Announcement>>(
        future: apiService.getAnnouncements(widget.flightNumber, widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final announcements = snapshot.data ?? [];

          if (announcements.isEmpty) {
            return const Center(
              child: Text("No hay anuncios para este vuelo. ¡Sé el primero!"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final ann = announcements[index];
              final cardColor = _getCategoryColor(ann.category);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cardColor,
                        child: Text(
                          ann.authorName[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        ann.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Publicado por ${ann.authorName}"),
                      trailing: Chip(
                        label: Text(ann.category),
                        backgroundColor: cardColor.withValues(alpha: 0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          ann.description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("💺 ${ann.seatsAvailable} plazas libres"),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text("Contactar"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_person, size: 80, color: Colors.redAccent),
          const SizedBox(height: 20),
          Text(
            "ACCESO RESTRINGIDO",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(error, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
