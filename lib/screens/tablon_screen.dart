import 'package:flutter/material.dart';
import '../theme/wefly_theme.dart';
import 'flight_detail_screen.dart';
import 'add_announcements_screen.dart';

class TablonScreen extends StatelessWidget {
  const TablonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de prueba para que la pantalla esté llena de contenido visual impactante
    final List<Map<String, String>> viajes = [
      {
        "origen": "Madrid (MAD)",
        "destino": "París (CDG)",
        "fecha": "28 Mayo, 2026",
        "precio": "45€",
        "plazas": "2 plazas libres",
        "tipo": "Vuelo Directo",
      },
      {
        "origen": "Barcelona (BCN)",
        "destino": "Roma (FCO)",
        "fecha": "02 Junio, 2026",
        "precio": "38€",
        "plazas": "Última plaza",
        "tipo": "Vuelo Directo",
      },
      {
        "origen": "Sevilla (SVQ)",
        "destino": "Londres (STN)",
        "fecha": "15 Junio, 2026",
        "precio": "52€",
        "plazas": "4 plazas libres",
        "tipo": "Con escala",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Tablón WeFly',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // --- BARRA DE BÚSQUEDA ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar vuelos o compañeros de viaje...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // --- LISTA DE PUBLICACIONES / VIAJES ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viajes.length,
              itemBuilder: (context, index) {
                final viaje = viajes[index];
                final bool ultimaPlaza = viaje["plazas"] == "Última plaza";

                // 🔥 Envolvemos cada tarjeta con GestureDetector para capturar el clic
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FlightDetailScreen(viajeData: viaje),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fila superior: Tipo de viaje y Precio
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: WeFlyTheme.orangePrimary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  viaje["tipo"]!,
                                  style: const TextStyle(
                                    color: WeFlyTheme.orangePrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                viaje["precio"]!,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: WeFlyTheme.orangePrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Fila intermedia: Origen -> Destino
                          Row(
                            children: [
                              Icon(
                                Icons.flight_takeoff_rounded,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      viaje["origen"]!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      viaje["destino"]!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(width: 15),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Fila inferior: Fecha y Estado de plazas
                          Divider(color: Colors.grey.shade100),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    viaje["fecha"]!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                viaje["plazas"]!,
                                style: TextStyle(
                                  color: ultimaPlaza
                                      ? Colors.red.shade400
                                      : Colors.green.shade600,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botón flotante para simular añadir una publicación
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 🔥 Ahora navegamos a la pantalla de creación
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAnnouncementScreen(),
            ),
          );
        },
        backgroundColor: WeFlyTheme.orangePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
