import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/wefly_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/announcement_provider.dart';

class AddAnnouncementScreen extends StatefulWidget {
  final String flightNumber; // Recibe el vuelo del tablón actual

  const AddAnnouncementScreen({super.key, required this.flightNumber});

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  
  String _selectedTipo = 'Taxi Compartido';
  String _selectedPlazas = '2 plazas libres';
  bool _isSaving = false;

  final List<String> _tiposDeTransporte = ['Taxi Compartido', 'Uber / Cabify', 'Vehículo Propio', 'Coche Alquilado'];
  final List<String> _opcionesPlazas = ['Última plaza', '2 plazas libres', '3 plazas libres', '4+ plazas libres'];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _publicarAnuncio() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final announcementProvider = Provider.of<AnnouncementProvider>(context, listen: false);

      // Usamos la fecha de hoy formateada de manera amigable
      final String dateFormatted = "${DateTime.now().day} Mayo, ${DateTime.now().year}";

      final exito = await announcementProvider.addAnnouncement(
        origin: _originController.text.trim(),
        destination: _destinationController.text.trim(),
        dateStr: dateFormatted,
        plazas: _selectedPlazas,
        tipo: _selectedTipo,
        flightNumber: widget.flightNumber,
        userId: authProvider.userId ?? 1,
      );

      setState(() => _isSaving = false);

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Anuncio publicado con éxito! ✈️'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Regresa automáticamente al tablón refrescado
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Publicar Trayecto', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Cómo te vas a mover desde el aeropuerto de destino de tu vuelo ${widget.flightNumber}?',
                style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 30),

              // INPUT ORIGEN
              TextFormField(
                controller: _originController,
                decoration: InputDecoration(
                  labelText: 'Punto de Origen (ej: Aeropuerto CDG)',
                  prefixIcon: const Icon(Icons.location_on_rounded, color: WeFlyTheme.orangePrimary),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Introduce el punto de partida' : null,
              ),
              const SizedBox(height: 15),

              // INPUT DESTINO
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: '¿A dónde vas? (ej: Hotel Centro París)',
                  prefixIcon: const Icon(Icons.flag_rounded, color: WeFlyTheme.orangePrimary),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Introduce el destino final' : null,
              ),
              const SizedBox(height: 25),

              // DESPLEGABLE TIPO
              const Text('Tipo de Transporte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                items: _tiposDeTransporte.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedTipo = val!),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // DESPLEGABLE PLAZAS
              const Text('Plazas Disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPlazas,
                items: _opcionesPlazas.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => _selectedPlazas = val!),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),

              // BOTÓN GUARDAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _publicarAnuncio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WeFlyTheme.orangePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('PUBLICAR ANUNCIO REAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}