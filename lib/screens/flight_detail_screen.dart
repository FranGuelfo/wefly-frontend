import 'package:flutter/material.dart';
import 'package:universal_html/html.dart'
    as html; // 🔥 Para abrir WhatsApp en Flutter Web sin fallos
import '../theme/wefly_theme.dart';

class FlightDetailScreen extends StatelessWidget {
  final Map<String, String> viajeData;

  const FlightDetailScreen({super.key, required this.viajeData});

  // 🔥 Función mágica para abrir WhatsApp con un mensaje automático personalizado
  void _abrirWhatsApp(String telefono, String origen, String destino) {
    final String mensaje = Uri.encodeComponent(
      "¡Hola! Te he visto en WeFly para compartir el transporte desde el aeropuerto en el vuelo de $origen a $destino. ¡Me interesa unirme al plan! ✈️",
    );
    final String url = "https://wa.me/$telefono?text=$mensaje";

    // Abre la URL de forma segura tanto en Web como en móvil
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    // Simulamos datos premium del creador del anuncio basándonos en tu idea de reseñas
    const String creadorNombre = "Alejandro Ruiz";
    const double creadorEstrellas = 4.9;
    const String creadorRango = "Piloto Experto";
    const String telefonoContacto =
        "+34600000000"; // Aquí iría el teléfono del backend

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Detalles del Grupo',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
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
            // --- BLOQUE 1: PERFIL DEL ANFITRIÓN (TU IDEA DE RESEÑAS) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: WeFlyTheme.orangePrimary,
                    child: Icon(
                      Icons.person_rounded,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          creadorNombre,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: WeFlyTheme.orangePrimary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                creadorRango,
                                style: TextStyle(
                                  color: WeFlyTheme.orangePrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '$creadorEstrellas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- BLOQUE 2: TARJETA DE RUTA ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: WeFlyTheme.mainGradient,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      viajeData["tipo"]!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ORIGEN",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            viajeData["origen"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "DESTINO DE LLEGADA",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            viajeData["destino"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- BLOQUE 3: DETALLES DEL TRANSPORTE ---
            const Text(
              "Información del trayecto",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildDetailTile(
              icon: Icons.directions_car_rounded,
              title: "Medio de transporte elegido",
              value:
                  viajeData["tipo"]!, // Mostrará si es Taxi, Uber/Cabify, etc.
            ),
            _buildDetailTile(
              icon: Icons.event_seat_rounded,
              title: "Plazas disponibles actualmente",
              value: viajeData["plazas"]!,
              valueColor: viajeData["plazas"] == "Última plaza"
                  ? Colors.red.shade600
                  : Colors.green.shade600,
            ),
            _buildDetailTile(
              icon: Icons.schedule_rounded,
              title: "Fecha estimada de llegada",
              value: viajeData["fecha"]!,
            ),
            _buildDetailTile(
              icon: Icons.near_me_rounded,
              title: "Zona de destino final en la ciudad",
              value: "Centro urbano / Zona de hoteles",
            ),

            const SizedBox(height: 40),

            // --- BOTÓN DE ACCIÓN 1: SOLICITAR UNIRSE (BLABLACAR STYLE) ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '¡Solicitud enviada al creador! Esperando aprobación... ⏳',
                      ),
                      backgroundColor: WeFlyTheme.orangePrimary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WeFlyTheme.orangePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "SOLICITAR UNIRSE AL PLAN",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- BOTÓN DE ACCIÓN 2: CONTACTAR POR WHATSAPP (FLEXIBLE Y RÁPIDO) ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () => _abrirWhatsApp(
                  telefonoContacto,
                  viajeData["origen"]!,
                  viajeData["destino"]!,
                ),
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.green,
                  size: 22,
                ),
                label: const Text(
                  "HABLAR POR WHATSAPP",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: WeFlyTheme.orangePrimary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
