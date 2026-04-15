import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  final String flightNumber;
  final int userId;

  const CreateAnnouncementScreen({super.key, required this.flightNumber, required this.userId});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'TO_AIRPORT';
  int _seats = 3;
  bool _isLoading = false;

  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081/api/v1'));

  Future<void> _submit() async {
  setState(() => _isLoading = true);
  try {
    await _dio.post('/announcements', 
      queryParameters: {'userId': widget.userId},
      data: {
        'title': _titleController.text,
        'description': _descController.text,
        'category': _category, 
        'type': 'TRANSPORT',
        'seatsAvailable': _seats,
        'flightNumber': widget.flightNumber,
      }
    );
    if (mounted) Navigator.pop(context);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear el anuncio: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Anuncio")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Título (Ej: Busco Taxi)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Descripción", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              const Text("Categoría:"),
              DropdownButton<String>(
                value: _category,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'TO_AIRPORT', child: Text("Ir al Aeropuerto")),
                  DropdownMenuItem(value: 'FROM_AIRPORT', child: Text("Salir del Aeropuerto")),
                  DropdownMenuItem(value: 'LEISURE', child: Text("Planes de Ocio")),
                ],
          onChanged: (val) => setState(() => _category = val!),
                ),
              const SizedBox(height: 20),
              Text("Plazas disponibles: $_seats"),
              Slider(
                value: _seats.toDouble(),
                min: 1, max: 4, divisions: 3,
                onChanged: (val) => setState(() => _seats = val.toInt()),
              ),
              const SizedBox(height: 30),
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Publicar Anuncio"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}