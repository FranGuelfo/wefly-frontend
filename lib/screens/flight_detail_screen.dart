import 'package:flutter/material.dart';
import '../theme/wefly_theme.dart';

class FlightDetailScreen extends StatelessWidget {
  final Map<String, String> viajeData;

  const FlightDetailScreen({super.key, required this.viajeData});

  @override
  Widget build(BuildContext context) {
    final bool ultimaPlaza = viajeData["plazas"] == "Última plaza";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Detalles del Vuelo',
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TARJETA PRINCIPAL DE RUTA ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: WeFlyTheme.mainGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: WeFlyTheme.orangePrimary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        viajeData["tipo"]!.toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        viajeData["precio"]!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ORIGEN", style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(viajeData["origen"]!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("DESTINO", style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(viajeData["destino"]!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- CARACTERÍSTICAS DEL VUELO ---
            const Text(
              "Características del viaje",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),

            _buildDetailTile(
              icon: Icons.calendar_today_rounded,
              title: "Fecha de salida",
              value: viajeData["fecha"]!,
            ),
            _buildDetailTile(
              icon: Icons.event_seat_rounded,
              title: "Disponibilidad",
              value: viajeData["plazas"]!,
              valueColor: ultimaPlaza ? Colors.red.shade600 : Colors.green.shade600,
            ),
            _buildDetailTile(
              icon: Icons.luggage_rounded,
              title: "Equipaje permitido",
              value: "Maleta de mano incluida (Máx. 10kg)",
            ),
            _buildDetailTile(
              icon: Icons.verified_user_rounded,
              title: "Seguridad WeFly",
              value: "Comunidad de viajeros verificados",
            ),

            const SizedBox(height: 40),

            // --- BOTÓN DE ACCIÓN PRINCIPAL ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí se ejecutará en el futuro tu método apiService.joinFlight(...)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('¡Te has unido con éxito al vuelo ${viajeData["origen"]}! 🎉'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WeFlyTheme.orangePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 3,
                ),
                child: const Text(
                  "SOLICITAR UNIRSE AL VUELO",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: WeFlyTheme.orangePrimary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}