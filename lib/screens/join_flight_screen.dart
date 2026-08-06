import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/wefly_theme.dart';

class JoinFlightScreen extends StatefulWidget {
  const JoinFlightScreen({super.key});

  @override
  State<JoinFlightScreen> createState() => _JoinFlightScreenState();
}

class _JoinFlightScreenState extends State<JoinFlightScreen> {
  final ApiService _apiService = ApiService();
  final _flightController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _flightController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitJoin() async {
    if (_flightController.text.isEmpty || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulamos que somos Mila (ID 2) solicitando entrar al vuelo
    final success = await _apiService.joinFlight(
      userId: 2, 
      flightId: _flightController.text.trim().toUpperCase(),
      reservationCode: _codeController.text.trim().toUpperCase(),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('¡Solicitud Enviada!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            content: const Text('Tu solicitud está pendiente de verificación. (Recuerda que en el backend debes confirmar el Booking).'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra Dialog
                  Navigator.pop(context, true); // Vuelve al Home avisando del éxito
                },
                child: const Text('Entendido', style: TextStyle(color: WeFlyTheme.orangePrimary)),
              )
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar la solicitud.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Añadir mi Vuelo', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verifica tu billete de avión',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Introduce tus datos para desbloquear el tablón de anuncios exclusivo de tu comunidad de pasajeros.',
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 40),

            // --- INPUT CÓDIGO VUELO ---
            const Text('Número de Vuelo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _flightController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                prefixIcon: const Icon(Icons.flight_takeoff, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                hintText: "Ej: IB3110",
              ),
            ),
            const SizedBox(height: 25),

            // --- INPUT LOCALIZADOR ---
            const Text('Código de Reserva (Localizador)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                prefixIcon: const Icon(Icons.qr_code_scanner, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                hintText: "Ej: XY1234",
              ),
            ),
            const SizedBox(height: 40),

            // --- BOTÓN DE ENVÍO ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WeFlyTheme.orangePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('VERIFICAR MI VUELO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}