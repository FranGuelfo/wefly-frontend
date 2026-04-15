import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/join_flight_screen.dart';
void main() => runApp(const MaterialApp(home: JoinFlightScreen()));

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String status = "Presiona para buscar anuncios (Vuelo IB3110)";
  final ApiService _apiService = ApiService(); // Usamos tu clase ApiService

  void fetchAnnouncements() async {
    try {
      // Usamos el método de tu ApiService con el usuario 1 (Fran verificado)
      final results = await _apiService.getAnnouncements('IB3110', 1);
      
      setState(() {
        status = "✅ Éxito: ${results.length} anuncios encontrados";
      });
    } catch (e) {
      setState(() {
        status = "❌ Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WeFly Connect Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchAnnouncements, 
              child: const Text("Probar Conexión")
            ),
          ],
        ),
      ),
    );
  }
}