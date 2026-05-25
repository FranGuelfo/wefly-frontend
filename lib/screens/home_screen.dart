import 'package:flutter/material.dart';
import '../theme/wefly_theme.dart';
import '../models/flight.dart';
import '../services/api_service.dart';
import 'join_flight_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Flight> _flights = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final flights = await _apiService.getFlights();
      setState(() {
        _flights = flights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No se pudieron cargar los vuelos activos";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡BIENVENIDO A WEFLY!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = WeFlyTheme.mainGradient.createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                        ),
                      ),
                      const Text(
                        'Encuentra compañeros de trayecto hoy',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // --- SECCIÓN VUELOS DESTACADOS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vuelos Activos en la Comunidad',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _fetchFlights,
                    child: const Icon(
                      Icons.refresh,
                      color: WeFlyTheme.orangePrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Renderizado condicional según la petición API
              _isLoading
                  ? const SizedBox(
                      height: 140,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: WeFlyTheme.orangePrimary,
                        ),
                      ),
                    )
                  : _errorMessage != null
                  ? SizedBox(
                      height: 140,
                      child: Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : _flights.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          'Aún no hay vuelos registrados. ¡Sé el primero!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _flights.length,
                        // Busca el ListView.builder dentro de home_screen.dart y asegúrate de que el contenedor luzca así:
                        itemBuilder: (context, index) {
                          final flight = _flights[index];

                          // Extraemos solo la hora (HH:mm) del LocalDateTime que manda Spring Boot (ej: "2026-05-25T15:30:00")
                          String formattedTime = "Horario a validar";
                          if (flight.arrivalTime != null &&
                              flight.arrivalTime!.contains('T')) {
                            formattedTime = flight.arrivalTime!
                                .split('T')[1]
                                .substring(0, 5);
                          }

                          return Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      flight.flightNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.flight_takeoff,
                                      color: WeFlyTheme.orangePrimary,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                // Aquí pintará "ALC ➔ MAD"
                                Text(
                                  '${flight.origin} ➔ ${flight.destination}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Llegada: $formattedTime',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 35),

              // --- SECCIÓN ANUNCIOS / TAXI SHARING ---
              const Text(
                'Anuncios Populares',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: WeFlyTheme.mainGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Compartimos un Taxi?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Divide gastos de traslado al centro de la ciudad con otros pasajeros de tu mismo vuelo.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JoinFlightScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: WeFlyTheme.orangePrimary,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
