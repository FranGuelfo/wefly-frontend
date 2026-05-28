import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final ApiService _apiService = ApiService();
  late Future<List<Announcement>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAnnouncements();
  }

  void _refreshAnnouncements() {
  setState(() {
    _announcementsFuture = _apiService.getAnnouncements(widget.flightNumber, widget.userId);
  });
}

  // --- ACCIONES DE UI ---

  Future<void> _abrirWhatsApp(String? telefono) async {
    if (telefono == null || telefono.isEmpty) return;
    final Uri whatsappUri = Uri.parse("https://wa.me/$telefono");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'TO_AIRPORT': return Colors.blue.shade400;
      case 'FROM_AIRPORT': return Colors.green.shade400;
      case 'LEISURE': return Colors.purple.shade400;
      default: return Colors.orange.shade400;
    }
  }

  // --- DIÁLOGOS ---

  void _confirmDelete(int announcementId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar anuncio?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.deleteAnnouncement(announcementId, widget.userId);
                if (mounted) {
                  _refreshAnnouncements();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Anuncio eliminado")));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Vuelo ${widget.flightNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshAnnouncements)],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAnnouncementScreen(flightNumber: widget.flightNumber, userId: widget.userId)),
          );
          if (result == true) _refreshAnnouncements();
        },
      ),
      body: FutureBuilder<List<Announcement>>(
        future: _announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
          
          final list = snapshot.data ?? [];
          if (list.isEmpty) return const Center(child: Text("No hay anuncios disponibles."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildAnnouncementCard(list[index]),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement ann) {
    final bool isOwner = widget.userId == ann.authorId;
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: _getCategoryColor(ann.category), child: Text(ann.authorName[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
            title: Text(ann.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Por ${ann.authorName}"),
            trailing: isOwner 
              ? PopupMenuButton(
                  onSelected: (val) => val == 'edit' ? null : _confirmDelete(ann.id), // Lógica de edición pendiente
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text("Editar")),
                    const PopupMenuItem(value: 'delete', child: Text("Eliminar", style: TextStyle(color: Colors.red))),
                  ],
                )
              : Chip(label: Text(ann.category), backgroundColor: _getCategoryColor(ann.category).withAlpha(50)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(ann.description),
          ),
          OverflowBar(
            children: [
              Text("💺 ${ann.seatsAvailable} plazas"),
              TextButton.icon(
                onPressed: () => _abrirWhatsApp(ann.authorPhone),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Contactar"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 60, color: Colors.red),
      Text(error),
    ]));
  }
}