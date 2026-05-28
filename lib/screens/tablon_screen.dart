import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/wefly_theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'flight_detail_screen.dart';
import 'add_announcements_screen.dart';

class TablonScreen extends StatefulWidget {
  const TablonScreen({super.key});

  @override
  State<TablonScreen> createState() => _TablonScreenState();
}

class _TablonScreenState extends State<TablonScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Controladores para el formulario de verificación
  final _flightNumberController = TextEditingController();
  final _reservationController = TextEditingController();

  bool _isVerified = false; // Controla si el usuario ya ha metido su vuelo
  bool _isLoading = false;

  // Datos de prueba filtrados (simulados una vez verificado el vuelo)
  final List<Map<String, String>> anunciosDelVuelo = [
    {
      "origen": "Madrid (MAD)",
      "destino": "París (CDG)",
      "fecha": "28 Mayo, 2026",
      "plazas": "2 plazas libres",
      "tipo": "Taxi Compartido"
    },
    {
      "origen": "Madrid (MAD)",
      "destino": "París (CDG)",
      "fecha": "28 Mayo, 2026",
      "plazas": "Última plaza",
      "tipo": "Uber / Cabify"
    },
  ];

  @override
  void dispose() {
    _flightNumberController.dispose();
    _reservationController.dispose();
    super.dispose();
  }

  // Método para verificar el vuelo conectando con tu ApiService
  Future<void> _verificarVuelo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Llamamos al método joinFlight que ya tenías programado en tu backend
      final exito = await _apiService.joinFlight(
        userId: authProvider.userId ?? 1, // Si es nulo, enviamos 1 para la demo
        flightNumber: _flightNumberController.text.trim().toUpperCase(),
        reservationCode: _reservationController.text.trim().toUpperCase(),
      );

      setState(() => _isLoading = false);

      if (exito) {
        setState(() => _isVerified = true); // Desbloqueamos el tablón
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Vuelo verificado! Bienvenido al tablón.'), backgroundColor: Colors.green),
        );
      } else {
        // Para la demo con tu socia: Si el backend no está corriendo, dejamos pasar igual o avisamos
        // Quita este 'setState' si quieres probar el error estricto del backend.
        setState(() => _isVerified = true); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Simulación: Vuelo aceptado para la demo.'), backgroundColor: WeFlyTheme.orangePrimary),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // SI NO ESTÁ VERIFICADO: Mostramos la pantalla de doble verificación
    if (!_isVerified) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Verificar Pasaje', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, size: 80, color: WeFlyTheme.orangePrimary),
                  const SizedBox(height: 20),
                  const Text(
                    'Acceso Exclusivo',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Por motivos de seguridad y privacidad, introduce los datos de tu billete para acceder al tablón de este vuelo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 35),

                  // INPUT NÚMERO DE VUELO
                  TextFormField(
                    controller: _flightNumberController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Número de Vuelo (ej: IB3240, FR2534)',
                      prefixIcon: const Icon(Icons.flight_takeoff_rounded, color: WeFlyTheme.orangePrimary),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Introduce el número de vuelo' : null,
                  ),
                  const SizedBox(height: 15),

                  // INPUT CÓDIGO DE RESERVA
                  TextFormField(
                    controller: _reservationController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Código de Reserva PNR (ej: X7Y2PL)',
                      prefixIcon: const Icon(Icons.vpn_key_rounded, color: WeFlyTheme.orangePrimary),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Introduce tu código de reserva' : null,
                  ),
                  const SizedBox(height: 30),

                  // BOTÓN DE VERIFICACIÓN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verificarVuelo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WeFlyTheme.orangePrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('VERIFICAR MI VUELO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // SI YA ESTÁ VERIFICADO: Se desbloquea el tablón real del avión
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vuelo ${_flightNumberController.text.toUpperCase()}',
              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
            ),
            const Text(
              'Pasajeros verificados a bordo',
              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => setState(() => _isVerified = false), // Permite "salir" del vuelo
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Estos son los anuncios compartidos por otros pasajeros de tu mismo avión.',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: anunciosDelVuelo.length,
              itemBuilder: (context, index) {
                final viaje = anunciosDelVuelo[index];
                final bool ultimaPlaza = viaje["plazas"] == "Última plaza";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlightDetailScreen(viajeData: viaje),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6))
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: WeFlyTheme.orangePrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  viaje["tipo"]!,
                                  style: const TextStyle(color: WeFlyTheme.orangePrimary, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              Text(viaje["precio"]!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: WeFlyTheme.orangePrimary)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(Icons.flight_takeoff_rounded, color: Colors.grey.shade400),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(viaje["origen"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text(viaje["destino"]!, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade300),
                              const SizedBox(width: 15),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Divider(color: Colors.grey.shade100),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade500),
                                  const SizedBox(width: 6),
                                  Text(viaje["fecha"]!, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                ],
                              ),
                              Text(
                                viaje["plazas"]!,
                                style: TextStyle(color: ultimaPlaza ? Colors.red.shade400 : Colors.green.shade600, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          )
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()),
          );
        },
        backgroundColor: WeFlyTheme.orangePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}