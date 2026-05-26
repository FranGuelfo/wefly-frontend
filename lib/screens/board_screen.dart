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
  
  // 🔥 Guardamos el Future en una variable para poder refrescarlo de verdad
  late Future<List<Announcement>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAnnouncements();
  }

  // 🔥 Función centralizada para cargar/actualizar los datos
  void _refreshAnnouncements() {
    setState(() {
      _announcementsFuture = apiService.getAnnouncements(widget.flightNumber, widget.userId);
    });
  }

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

  void _confirmDelete(BuildContext context, int announcementId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar anuncio?"),
        content: const Text("Esta acción no se puede deshacer y el anuncio desaparecerá del tablón."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                // 🔥 Usamos tu ApiService centralizado en lugar de instanciar otro Dio local
                // Asegúrate de tener implementado el método deleteAnnouncement en tu ApiService
                await apiService.deleteAnnouncement(announcementId, widget.userId);
                
                if (mounted) {
                  navigator.pop(); // Cierra el diálogo
                  _refreshAnnouncements(); // 🔥 Ahora sí refresca correctamente el FutureBuilder
                  messenger.showSnackBar(
                    const SnackBar(content: Text("Anuncio eliminado correctamente")),
                  );
                }
              } catch (e) {
                if (mounted) navigator.pop();
                messenger.showSnackBar(
                  SnackBar(content: Text("Error al eliminar: $e")),
                );
              }
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Vuelo ${widget.flightNumber}",
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshAnnouncements,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAnnouncementScreen(
                flightNumber: widget.flightNumber,
                userId: widget.userId,
              ),
            ),
          );
          // Si al volver del formulario nos devuelve un éxito, refrescamos
          _refreshAnnouncements();
        },
      ),
      body: FutureBuilder<List<Announcement>>(
        future: _announcementsFuture, // 🔥 Apunta a la variable del estado
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
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
                          ann.authorName.isNotEmpty ? ann.authorName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        ann.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Publicado por ${ann.authorName}"),
                      // 🔥 Corregido: Comparamos contra ann.authorId
                      trailing: widget.userId == ann.authorId
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateAnnouncementScreen(
                                        flightNumber: widget.flightNumber,
                                        userId: widget.userId,
                                        announcement: ann, 
                                      ),
                                    ),
                                  );
                                  _refreshAnnouncements();
                                } else if (value == 'delete') {
                                  _confirmDelete(context, ann.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit, size: 20),
                                    title: Text("Editar"),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete, color: Colors.red, size: 20),
                                    title: Text("Eliminar", style: TextStyle(color: Colors.red)),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            )
                          : Chip(
                              label: Text(ann.category),
                              backgroundColor: cardColor.withAlpha(50),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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