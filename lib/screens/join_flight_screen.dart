import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'board_screen.dart';

class JoinFlightScreen extends StatefulWidget {
  const JoinFlightScreen({super.key});

  @override
  State<JoinFlightScreen> createState() => _JoinFlightScreenState();
}

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081/api/v1'));

  // ESTA ES LA "TRAMPA" PARA LA PRUEBA RÁPIDA
  Future<void> _simulateAdminVerification() async {
    try {
      // Asumimos que la reserva de Mila es la ID 2 (puedes ajustarlo según tu DB)
      await _dio.put('/flights/verify/2');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚀 ¡Simulación exitosa! Reserva confirmada."),
          ),
        );
      }
    } catch (e) {
      print("Error en simulación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verificación en curso")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time_filled,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              "Tu reserva está siendo procesada...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Botón normal de la App
            ElevatedButton(
              onPressed: () {
                // Al pulsar, navegamos a la pantalla que muestra los anuncios
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const BoardScreen(flightNumber: "IB3110", userId: 2),
                  ),
                );
              },
              child: const Text("Reintentar Acceso"),
            ),

            const SizedBox(height: 100),

            // BOTÓN DE DESARROLLADOR (SÓLO PARA PRUEBAS)
            TextButton.icon(
              onPressed: _simulateAdminVerification,
              icon: const Icon(Icons.bug_report, color: Colors.red),
              label: const Text(
                "SIMULAR VERIFICACIÓN (ADMIN)",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinFlightScreenState extends State<JoinFlightScreen> {
  final _flightController = TextEditingController();
  final _reservaController = TextEditingController();
  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081/api/v1'));
  bool _isLoading = false;

  Future<void> _join() async {
    setState(() => _isLoading = true);
    try {
      // Simulamos que somos el usuario ID 2 (Mila)
      await _dio.post(
        '/flights/join',
        queryParameters: {
          'userId': 2,
          'flightNumber': _flightController.text.toUpperCase(),
          'reservationCode': _reservaController.text.toUpperCase(),
        },
      );

      if (mounted) {
        // Navegamos a la pantalla de estado
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VerificationStatusScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error al unirse: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar mi Vuelo")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.airplane_ticket, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            TextField(
              controller: _flightController,
              decoration: const InputDecoration(
                labelText: "Número de Vuelo (ej: IB3110)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _reservaController,
              decoration: const InputDecoration(
                labelText: "Código de Reserva",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _join,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Unirme al Vuelo"),
                  ),
          ],
        ),
      ),
    );
  }
}
