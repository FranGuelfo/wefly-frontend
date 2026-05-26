import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/wefly_theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AddAnnouncementScreen extends StatefulWidget {
  const AddAnnouncementScreen({super.key});

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Controladores para capturar el texto
  final _origenController = TextEditingController();
  final _destinoController = TextEditingController();
  final _precioController = TextEditingController();
  final _plazasController = TextEditingController();
  String _tipoSeleccionado = 'Vuelo Directo';

  bool _isSaving = false;

  @override
  void dispose() {
    _origenController.dispose();
    _destinoController.dispose();
    _precioController.dispose();
    _plazasController.dispose();
    super.dispose();
  }

  Future<void> _submitAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        // Estructura de datos que espera tu Backend
        final Map<String, dynamic> data = {
          'origin': _origenController.text.trim(),
          'destination': _destinoController.text.trim(),
          'price': double.tryParse(_precioController.text) ?? 0.0,
          'availableSeats': int.tryParse(_plazasController.text) ?? 1,
          'type': _tipoSeleccionado,
          'createdAt': DateTime.now().toIso8601String(),
        };

        // Llamamos a tu método del ApiService
        await _apiService.createAnnouncement(authProvider.userId!, data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Anuncio publicado con éxito! ✈️'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Volvemos al tablón
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al publicar: ${e.toString()}'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nuevo Anuncio', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator(color: WeFlyTheme.orangePrimary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Detalles del Viaje", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // ORIGEN
                  _buildTextField(
                    controller: _origenController,
                    label: 'Origen (ej: Madrid MAD)',
                    icon: Icons.flight_takeoff_rounded,
                  ),
                  const SizedBox(height: 15),

                  // DESTINO
                  _buildTextField(
                    controller: _destinoController,
                    label: 'Destino (ej: París CDG)',
                    icon: Icons.flight_land_rounded,
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      // PRECIO
                      Expanded(
                        child: _buildTextField(
                          controller: _precioController,
                          label: 'Precio (€)',
                          icon: Icons.euro_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // PLAZAS
                      Expanded(
                        child: _buildTextField(
                          controller: _plazasController,
                          label: 'Plazas',
                          icon: Icons.event_seat_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // TIPO DE VUELO (Selector)
                  const Text("Tipo de Vuelo", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _tipoSeleccionado,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    items: ['Vuelo Directo', 'Con escala', 'Charter']
                        .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                        .toList(),
                    onChanged: (value) => setState(() => _tipoSeleccionado = value!),
                  ),

                  const SizedBox(height: 40),

                  // BOTÓN PUBLICAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WeFlyTheme.orangePrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 2,
                      ),
                      child: const Text("PUBLICAR ANUNCIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        floatingLabelStyle: const TextStyle(color: WeFlyTheme.orangePrimary),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Campo obligatorio' : null,
    );
  }
}