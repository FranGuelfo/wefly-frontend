import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/wefly_theme.dart';
import '../providers/flight_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/announcement_provider.dart';
import 'profile_screen.dart';
import '../models/announcement.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class FlightDetailScreen extends StatefulWidget {
  final Announcement announcement;

  const FlightDetailScreen({super.key, required this.announcement});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  Key _requestsKey = UniqueKey();
  final ApiService _apiService = ApiService();

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

  // Comprueba de forma concurrente el estado de registro del usuario actual
  Future<String> _checkUserStatus(int flightId, int currentUserId, String token) async {
    if (currentUserId == 0 || token.isEmpty) return 'none';
    try {
      final fProvider = Provider.of<FlightProvider>(context, listen: false);
      
      // Consultamos ambas listas al mismo tiempo para optimizar rendimiento
      final results = await Future.wait([
        fProvider.getConfirmedBookings(flightId, token),
        fProvider.getPendingBookings(flightId, token),
      ]);

      final confirmed = results[0];
      final pending = results[1];

      if (confirmed.any((request) => request['userId'] == currentUserId)) {
        return 'accepted';
      }
      if (pending.any((request) => request['userId'] == currentUserId)) {
        return 'pending';
      }
    } catch (_) {
      // En caso de error de red, permitimos el flujo por defecto por seguridad
    }
    return 'none';
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
          orElse: () => widget.announcement, // Si no lo encuentra, usa el inicial por seguridad
        );

        // --- PLAZAS EN TIEMPO REAL ---
        int plazasActuales = announcement.seatsAvailable;

        final String origen = announcement.origin;
        final String destino = announcement.destination;
        final String tipoTransporte = announcement.category;
        final String plazasText = "$plazasActuales plazas";
        final String fechaLlegada = announcement.dateStr;

        final String creadorNombre = announcement.authorName;
        final String telefonoContacto = announcement.authorPhone ?? "+34600000000";
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
            actions: [
              FutureBuilder<int>(
                future: _apiService.getUnreadCount(
                  announcement.id,
                  authProvider.userId ?? 0,
                ),
                builder: (context, snapshot) {
                  final int unreadCount = snapshot.data ?? 0;

                  return IconButton(
                    icon: unreadCount > 0
                        ? Badge(
                            backgroundColor: Colors.red,
                            label: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                            ),
                          )
                        : const Icon(Icons.chat_bubble_outline_rounded),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            announcementId: announcement.id,
                            title: "Chat $origen - $destino",
                          ),
                        ),
                      ).then((_) {
                        // Al regresar del chat, refrescamos el contador de no leídos
                        setState(() {});
                      });
                    },
                  );
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BLOQUE: PERFIL (CORREGIDO) ---
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

                // --- INTEGRANTES CONFIRMADOS del viaje ---
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
                  FutureBuilder<String>(
                    key: ValueKey(_requestsKey.toString() + "_action_btn"),
                    future: _checkUserStatus(
                      flightId, 
                      authProvider.userId ?? 0, 
                      authProvider.token ?? ""
                    ),
                    builder: (context, statusSnapshot) {
                      final String userStatus = statusSnapshot.data ?? 'none';
                      final bool isLoadingStatus = statusSnapshot.connectionState == ConnectionState.waiting;

                      VoidCallback? onPressedAction;
                      Widget buttonChild;
                      Color buttonColor = WeFlyTheme.orangePrimary;

                      if (isLoadingStatus) {
                        onPressedAction = null;
                        buttonChild = const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            color: Colors.white
                          ),
                        );
                      } else if (userStatus == 'accepted') {
                        onPressedAction = null;
                        buttonColor = Colors.green.shade600;
                        buttonChild = const Text(
                          "¡YA FORMAS PARTE DEL VIAJE! 🚗",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      } else if (userStatus == 'pending') {
                        onPressedAction = null;
                        buttonColor = Colors.grey.shade500;
                        buttonChild = const Text(
                          "SOLICITUD ENVIADA (PENDIENTE)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      } else {
                        if (plazasActuales == 0) {
                          onPressedAction = null;
                          buttonChild = const Text(
                            "PLAZAS AGOTADAS",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        } else {
                          onPressedAction = () async {
                            final TextEditingController codeController = TextEditingController();

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
                                        : (flightProvider.errorMessage ?? 'Error'),
                                  ),
                                  backgroundColor: exito ? Colors.green : Colors.redAccent,
                                ),
                              );
                              if (exito) {
                                setState(() {
                                  _requestsKey = UniqueKey();
                                });
                              }
                            }
                          };
                          buttonChild = const Text(
                            "SOLICITAR UNIRSE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }
                      }

                      return SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: flightProvider.isLoading ? null : onPressedAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            disabledBackgroundColor: buttonColor, 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: buttonChild,
                        ),
                      );
                    },
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "No hay solicitudes pendientes.",
            style: TextStyle(color: Colors.grey),
          );
        }

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
                    builder: (context) => ProfileScreen(userId: request['userId']),
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
                          setState(() => _requestsKey = UniqueKey());

                          await Provider.of<AnnouncementProvider>(
                            context,
                            listen: false,
                          ).fetchAnnouncements(
                            flightNumber,
                            authProvider.userId ?? 0,
                          );

                          if (!context.mounted) return;

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
                        bool confirm = await showDialog(
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
                          bool exito = await Provider.of<FlightProvider>(
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

  Widget _buildConfirmedRequestsList(BuildContext context, int flightId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder<List<dynamic>>(
      key: ValueKey(_requestsKey.toString() + "_confirmed"),
      future: Provider.of<FlightProvider>(
        context,
        listen: false,
      ).getConfirmedBookings(flightId, authProvider.token ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            "Aún no hay compañeros confirmados.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final request = snapshot.data![index];
            final String name = request['userName'] ?? "Pasajero WeFly";

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: Colors.green.shade50,
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: request['userId']),
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