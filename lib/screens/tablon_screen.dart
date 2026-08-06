import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/wefly_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/announcement_provider.dart';
import '../services/api_service.dart';
import '../models/announcement.dart';
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

  final _flightNumberController = TextEditingController();
  final _reservationController = TextEditingController();

  bool _isVerified = false;
  bool _isCheckingFlight = false;

  @override
  void dispose() {
    _flightNumberController.dispose();
    _reservationController.dispose();
    super.dispose();
  }

  Future<void> _verificarVuelo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isCheckingFlight = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final announcementProvider = Provider.of<AnnouncementProvider>(context, listen: false);

      final String vNum = _flightNumberController.text.trim().toUpperCase();
      final String resCode = _reservationController.text.trim().toUpperCase();
      final int uId = authProvider.userId ?? 1;

      final exito = await _apiService.joinFlight(
        userId: uId,
        flightId: vNum,
        reservationCode: resCode,
      );

      if (exito) {
        await announcementProvider.fetchAnnouncements(vNum, uId);
        setState(() {
          _isCheckingFlight = false;
          _isVerified = true;
        });
      } else {
        await announcementProvider.fetchAnnouncements(vNum, uId);
        setState(() {
          _isCheckingFlight = false;
          _isVerified = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Acceso Exclusivo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  const SizedBox(height: 10),
                  const Text('Por motivos de seguridad, introduce los datos de tu billete.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 35),
                  TextFormField(
                    controller: _flightNumberController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Número de Vuelo',
                      prefixIcon: const Icon(Icons.flight_takeoff_rounded, color: WeFlyTheme.orangePrimary),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Introduce el número de vuelo' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _reservationController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Código de Reserva PNR',
                      prefixIcon: const Icon(Icons.vpn_key_rounded, color: WeFlyTheme.orangePrimary),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Introduce tu código de reserva' : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isCheckingFlight ? null : _verificarVuelo,
                      style: ElevatedButton.styleFrom(backgroundColor: WeFlyTheme.orangePrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: _isCheckingFlight ? const CircularProgressIndicator(color: Colors.white) : const Text('VERIFICAR MI VUELO'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final currentFlightNum = _flightNumberController.text.toUpperCase().trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Vuelo $currentFlightNum'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => setState(() => _isVerified = false)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => Provider.of<AnnouncementProvider>(context, listen: false).fetchAnnouncements(currentFlightNum, authProvider.userId ?? 0),
          )
        ],
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.announcements.isEmpty) return const Center(child: Text("No hay anuncios disponibles"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final Announcement viaje = provider.announcements[index];
              final bool ultimaPlaza = viaje.seatsAvailable <= 1;

              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FlightDetailScreen(announcement: viaje)));
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(viaje.category, style: const TextStyle(fontWeight: FontWeight.bold, color: WeFlyTheme.orangePrimary)),
                        Text(viaje.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(viaje.description),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Por ${viaje.authorName}"),
                            Text("${viaje.seatsAvailable} plazas", style: TextStyle(color: ultimaPlaza ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddAnnouncementScreen(flightNumber: currentFlightNum))),
        backgroundColor: WeFlyTheme.orangePrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}