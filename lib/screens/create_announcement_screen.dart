import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/announcement.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final String flightNumber;
  final int userId;
  final Announcement? announcement; // Si viene un anuncio, estamos editando

  const CreateAnnouncementScreen({
    super.key, 
    required this.flightNumber, 
    required this.userId, 
    this.announcement
  });

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  // Usamos late para inicializarlos en el initState
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _category;
  late int _seats;
  bool _isLoading = false;

  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081/api/v1'));

  @override
  void initState() {
    super.initState();
    // Detectamos si es edición o creación para rellenar los campos
    final existing = widget.announcement;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descController = TextEditingController(text: existing?.description ?? '');
    _category = existing?.category ?? 'TO_AIRPORT';
    _seats = existing?.seatsAvailable ?? 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final isEditing = widget.announcement != null;
    
    try {
      if (isEditing) {
        // RUTA PARA EDITAR (PATCH)
        await _dio.patch(
          '/announcements/${widget.announcement!.id}',
          queryParameters: {'userId': widget.userId},
          data: {
            'title': _titleController.text,
            'description': _descController.text,
            'category': _category,
            'seatsAvailable': _seats,
          },
        );
      } else {
        // RUTA PARA CREAR (POST)
        await _dio.post(
          '/announcements',
          queryParameters: {'userId': widget.userId},
          data: {
            'title': _titleController.text,
            'description': _descController.text,
            'category': _category,
            'type': 'TRANSPORT',
            'seatsAvailable': _seats,
            'flightNumber': widget.flightNumber,
          },
        );
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el anuncio: $e')),
        );
      }
    }
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.announcement != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Anuncio" : "Nuevo Anuncio"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Título (Ej: Busco Taxi compartido)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descripción y detalles",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 25),
              const Text("¿Cuál es el plan?", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'TO_AIRPORT', child: Text("Ir al Aeropuerto")),
                  DropdownMenuItem(value: 'FROM_AIRPORT', child: Text("Salir del Aeropuerto")),
                  DropdownMenuItem(value: 'LEISURE', child: Text("Planes de Ocio")),
                ],
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 25),
              const Text("Plazas disponibles:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCounterButton(Icons.remove, () {
                      if (_seats > 1) setState(() => _seats--);
                    }),
                    Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: Text("$_seats",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    _buildCounterButton(Icons.add, () {
                      if (_seats < 6) setState(() => _seats++);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isEditing ? "GUARDAR CAMBIOS" : "PUBLICAR ANUNCIO",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}