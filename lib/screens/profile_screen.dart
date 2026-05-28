import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/wefly_theme.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // 🔥 Función para desplegar el menú inferior nativo
  void _mostrarMenuConfiguracion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 10.0,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Hace que el panel ocupe solo lo necesario
              children: [
                // Barra gris superior que simula una pestaña de arrastre (Estilo iOS/Android Premium)
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 25),

                // OPCIÓN 1: EDITAR PERFIL
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WeFlyTheme.orangePrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: WeFlyTheme.orangePrimary,
                    ),
                  ),
                  title: const Text(
                    'Editar Perfil',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: const Text('Cambiar nombre, foto o teléfono'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    ); // 🔥 1. Cierra el menú inferior que sube desde abajo

                    // 🔥 2. Abre de forma fluida la pantalla de edición que acabamos de crear
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(
                  indent: 70,
                ), // Línea divisoria elegante alineada con el texto
                // OPCIÓN 2: SEGURIDAD Y PRIVACIDAD
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.blue),
                  ),
                  title: const Text(
                    'Seguridad y Privacidad',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: const Text('Verificaciones de pasaje y cuenta'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.pop(context); // Cierra el menú

                    // Mostramos un diálogo pop-up explicando la política estrella de WeFly
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: Colors.green,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Tu Cuenta está Segura",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        content: const Text(
                          "En WeFly, tus datos de vuelo y código PNR están encriptados. Solo los pasajeros que superen la doble verificación de pasaje de tu mismo avión pueden ver tus anuncios publicados.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "ENTENDIDO",
                              style: TextStyle(
                                color: WeFlyTheme.orangePrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(indent: 70),

                // OPCIÓN 3: CERRAR SESIÓN
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  onTap: () {
                    // 1. Cierra el menú inferior desplegable
                    Navigator.pop(context);

                    // 2. 🔥 LIMPIEZA TOTAL: Llamamos al método logout del provider para resetear estados internos e isLoading
                    Provider.of<AuthProvider>(context, listen: false).logout();

                    // 3. Volvemos al login de forma limpia
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const String nombreUsuario = "Carlos Mendoza";
    const String rangoUsuario = "Viajero Frecuente";
    const double puntuacion = 4.8;
    const int viajesCompartidos = 24;

    final List<Map<String, String>> resenas = [
      {
        "autor": "Ana R.",
        "comentario":
            "Súper puntual y muy simpático. Compartimos un Cabify en París y ahorramos un montón.",
        "estrellas": "5",
      },
      {
        "autor": "Javier M.",
        "comentario":
            "Todo perfecto. Coordinamos el taxi desde Barajas sin problemas. Muy recomendable.",
        "estrellas": "4",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil WeFly',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.black87),
            onPressed: () =>
                _mostrarMenuConfiguracion(context), // 🔥 Conectamos el botón
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- TARJETA DE IDENTIDAD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: WeFlyTheme.orangePrimary,
                    child: Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    nombreUsuario,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),

                  // BADGE DE RANGO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: WeFlyTheme.orangePrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      rangoUsuario,
                      style: TextStyle(
                        color: WeFlyTheme.orangePrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),

                  // ESTADÍSTICAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$puntuacion',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Puntuación",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$viajesCompartidos',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Viajes compartidos",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- SECCIÓN: CLUB DE DESCUENTOS ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Mis Recompensas Club WeFly",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF111827), Color(0xFF1F2937)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.card_membership_rounded,
                    color: Colors.amber,
                    size: 35,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "¡Tienes un 10% dto. activo!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Por ser '$rangoUsuario', disfruta de rebajas en tu próximo Cabify/Uber en el aeropuerto.",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- SECCIÓN: RESEÑAS DE OTROS VIAJEROS ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Opiniones de la comunidad",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: resenas.length,
              itemBuilder: (context, index) {
                final item = resenas[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item["autor"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              int.parse(item["estrellas"]!),
                              (index) => const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item["comentario"]!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
