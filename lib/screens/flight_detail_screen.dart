import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/wefly_theme.dart';
import '../providers/flight_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/announcement_provider.dart'; // Importante escuchar este provider ahora
import 'profile_screen.dart';
import '../models/announcement.dart';

class FlightDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const FlightDetailScreen({super.key, required this.announcement});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  Key _requestsKey = UniqueKey();

  Future<void> _abrirWhatsApp(
    BuildContext context,
    String telefono,
    String origen,
    String destino,
  ) async {
    final String mensaje =
        "¡Hola! Te he visto en WeFly para compartir el transporte desde el aeropuerto en el vuelo con origen $origen y destino a $destino. ¡Me interesa unirme al plan! ✈️";
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$telefono?text=${Uri.encodeComponent(mensaje)}",
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir el enlace de WhatsApp';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir WhatsApp.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final flightProvider = Provider.of<FlightProvider>(context, listen: false);

    // Escuchamos de forma reactiva al AnnouncementProvider para enterarnos si cambian las plazas
    return Consumer<AnnouncementProvider>(
      builder: (context, announcementProvider, child) {
        // Buscamos el anuncio actualizado dentro del provider global
        final announcement = announcementProvider.announcements.firstWhere(
          (a) => a.id == widget.announcement.id,
          orElse: () => widget
              .announcement, // Si no lo encuentra, usa el inicial por seguridad
        );

        // --- PLAZAS EN TIEMPO REAL ---
        int plazasActuales = announcement
            .seatsAvailable; // Cambiará a 0 automáticamente al refrescar el provider

        final String origen = announcement.origin;
        final String destino = announcement.destination;
        final String tipoTransporte = announcement.category;
        final String plazasText = "$plazasActuales plazas";
        final String fechaLlegada = announcement.dateStr;

        final String creadorNombre = announcement.authorName;
        final String telefonoContacto =
            announcement.authorPhone ?? "+34600000000";
        final int flightId = announcement.id;
        final int creadorId = announcement.authorId;

        final bool esCreador = authProvider.userId == creadorId;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Detalles del Grupo',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
              ),
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
                // --- BLOQUE: PERFIL ---
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: creadorId),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(5),
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
                              Text(
                                creadorNombre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                              const Text(
                                "Pasajero Verificado",
                                style: TextStyle(
                                  color: WeFlyTheme.orangePrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // --- BLOQUE: RUTA ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: WeFlyTheme.mainGradient,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          origen,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          destino,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // --- GESTIÓN DE SOLICITUDES (Solo Creador) ---
                if (esCreador) ...[
                  const Text(
                    "Solicitudes Pendientes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPendingRequestsList(
                    context,
                    flightId,
                    announcement.flightNumber,
                  ),
                  const SizedBox(height: 25),
                ],

                // --- NUEVA SECCIÓN: INTEGRANTES CONFIRMADOS del viaje ---
                const Text(
                  "Pasajeros en el coche",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                  ),
                ),
                const SizedBox(height: 12),
                _buildConfirmedRequestsList(context, flightId),
                const SizedBox(height: 25),

                // --- INFO DETALLADA ---
                _buildDetailTile(
                  icon: Icons.directions_car_rounded,
                  title: "Medio de transporte",
                  value: tipoTransporte,
                ),
                _buildDetailTile(
                  icon: Icons.event_seat_rounded,
                  title: "Plazas libres",
                  value: plazasText,
                ),
                _buildDetailTile(
                  icon: Icons.schedule_rounded,
                  title: "Fecha de encuentro",
                  value: fechaLlegada,
                ),

                const SizedBox(height: 40),

                // --- BOTONES DE ACCIÓN (Si no eres el creador) ---
                if (!esCreador) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      // Si está cargando O no quedan plazas, el botón se deshabilita (null)
                      onPressed: flightProvider.isLoading || plazasActuales == 0
                          ? null
                          : () async {
                              final TextEditingController codeController =
                                  TextEditingController();

                              String? code = await showDialog<String>(
                                context: context,

                                builder: (ctx) => AlertDialog(
                                  title: const Text("Código de Reserva"),

                                  content: TextField(
                                    controller: codeController,
                                    decoration: const InputDecoration(
                                      hintText: "Introduce tu localizador",
                                    ),
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text("Cancelar"),
                                    ),

                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(
                                        ctx,
                                        codeController.text,
                                      ),
                                      child: const Text("Confirmar"),
                                    ),
                                  ],
                                ),
                              );

                              if (code == null || code.isEmpty) return;

                              bool exito = await flightProvider.joinFlight(
                                flightId,
                                authProvider.userId ?? 0,
                                code,
                                authProvider.token ?? "",
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      exito
                                          ? '¡Te has unido al viaje!'
                                          : (flightProvider.errorMessage ??
                                                'Error'),
                                    ),

                                    backgroundColor: exito
                                        ? Colors.green
                                        : Colors.redAccent,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        // Si no hay plazas, se pinta gris automáticamente por Flutter al ser onPressed null
                        backgroundColor: WeFlyTheme.orangePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      // Cambiamos el texto dinámicamente según las plazas
                      child: Text(
                        plazasActuales == 0
                            ? "PLAZAS AGOTADAS"
                            : "SOLICITAR UNIRSE",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () => _abrirWhatsApp(
                        context,
                        telefonoContacto,
                        origen,
                        destino,
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.green,
                      ),
                      label: const Text(
                        "CONTACTAR POR WHATSAPP",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Lista de solicitudes Pendientes
  Widget _buildPendingRequestsList(
    BuildContext context,
    int flightId,
    String flightNumber,
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder<List<dynamic>>(
      key: _requestsKey,
      future: Provider.of<FlightProvider>(
        context,
        listen: false,
      ).getPendingBookings(flightId, authProvider.token ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Text(
            "No hay solicitudes pendientes.",
            style: TextStyle(color: Colors.grey),
          );

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final request = snapshot.data![index];
            final String name = request['userName'] ?? "Usuario";

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userId: request['userId']),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Localizador: ${request['reservationCode']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        final fProvider = Provider.of<FlightProvider>(
                          context,
                          listen: false,
                        );
                        bool exito = await fProvider.approveBooking(
                          request['id'],
                          authProvider.token ?? "",
                        );
                        if (exito && mounted) {
                          // 1. Forzar recarga de los FutureBuilders de las listas internas
                          setState(() => _requestsKey = UniqueKey());
                          // 2. ¡CRUCIAL! Volvemos a pedir al backend que refresque los anuncios globales
                          await Provider.of<AnnouncementProvider>(
                            context,
                            listen: false,
                          ).fetchAnnouncements(
                            flightNumber,
                            authProvider.userId ?? 0,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Pasajero aprobado y plazas actualizadas",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      onPressed: () async {
                        bool confirm =
                            await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Rechazar solicitud"),
                                content: const Text(
                                  "¿Seguro que quieres rechazar a este pasajero?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text("Rechazar"),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                        if (confirm) {
                          bool exito =
                              await Provider.of<FlightProvider>(
                                context,
                                listen: false,
                              ).rejectBooking(
                                request['id'],
                                authProvider.token ?? "",
                              );
                          if (exito && mounted) {
                            setState(() {
                              _requestsKey = UniqueKey();
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // NUEVO WIDGET: Muestra las personas ya aceptadas del viaje
  Widget _buildConfirmedRequestsList(BuildContext context, int flightId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder<List<dynamic>>(
      key: ValueKey(
        _requestsKey.toString() + "_confirmed",
      ), // Se refresca coordinado con los cambios
      future: Provider.of<FlightProvider>(
        context,
        listen: false,
      ).getConfirmedBookings(flightId, authProvider.token ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Text(
            "Aún no hay compañeros confirmados.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          );

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final request = snapshot.data![index];
            final String name = request['userName'] ?? "Pasajero WeFly";

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.green.shade50, // Color distintivo de aceptado
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(userId: request['userId']),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade200,
                  child: const Icon(Icons.check, color: Colors.green),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "Pasajero confirmado",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: WeFlyTheme.orangePrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
