import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../theme/wefly_theme.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;
  final Map<String, dynamic>? viajeData;

  const ProfileScreen({super.key, this.userId, this.viajeData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Si estamos viendo el perfil de otro, lo cargamos
    if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        Provider.of<UserProvider>(context, listen: false)
            .fetchUserProfile(widget.userId!, auth.token ?? "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final bool esMiPerfil = widget.userId == null || widget.userId == authProvider.userId;
    
    // Si es mi perfil, tomo los datos del AuthProvider, si no, del UserProvider
    final userData = esMiPerfil 
        ? authProvider.usuarioActual?.toJson() 
        : userProvider.userProfile;
        
    final bool isLoading = !esMiPerfil && userProvider.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(esMiPerfil ? 'Mi Perfil WeFly' : 'Perfil de Usuario', 
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (esMiPerfil)
            IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.black87),
              onPressed: () => _mostrarMenuConfiguracion(context),
            ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: WeFlyTheme.orangePrimary))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(userData, esMiPerfil),
                const SizedBox(height: 25),
                if (esMiPerfil) _buildRecompensas(userData),
                _buildResenasSection(esMiPerfil),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? data, bool esMiPerfil) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(28), 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 45, backgroundColor: WeFlyTheme.orangePrimary, child: Icon(Icons.person_rounded, size: 50, color: Colors.white)),
          const SizedBox(height: 15),
          Text(data?["name"] ?? "Usuario WeFly", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 15),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("Puntuación", "${data?["puntuacion"] ?? 4.8}", Icons.star_rounded, Colors.amber),
              _buildStat(esMiPerfil ? "Viajes" : "Creados", "${data?["viajesCompartidos"] ?? 0}", Icons.flight_takeoff_rounded, WeFlyTheme.orangePrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(children: [
      Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]);
  }

  Widget _buildRecompensas(Map<String, dynamic>? data) {
    return Column(
      children: [
        const Align(alignment: Alignment.centerLeft, child: Text("Mis Recompensas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(22)),
          child: Row(
            children: [
              const Icon(Icons.card_membership_rounded, color: Colors.amber, size: 35),
              const SizedBox(width: 16),
              Expanded(child: Text("¡Tienes un 10% dto. activo por ser '${data?["rango"] ?? "Viajero Frecuente"}'!", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildResenasSection(bool esMiPerfil) {
    return Column(
      children: [
        Align(alignment: Alignment.centerLeft, child: Text(esMiPerfil ? "Opiniones de la comunidad" : "Opiniones sobre este usuario", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'))),
        const SizedBox(height: 12),
        // Aquí podrías mapear tus reseñas reales más adelante
        const Center(child: Text("No hay reseñas todavía", style: TextStyle(color: Colors.grey))),
      ],
    );
  }

  void _mostrarMenuConfiguracion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: WeFlyTheme.orangePrimary),
              title: const Text('Editar Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}