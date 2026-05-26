import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/wefly_theme.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Datos del proveedor centralizados
    final String name = authProvider.userName ?? "Usuario WeFly";
    final String email = authProvider.userEmail ?? "usuario@wefly.com";
    
    // NOTA: Si aún no tienes estas variables en tu AuthProvider, las simulamos 
    // para que la pantalla compile perfectamente ante tu socia.
    final String bio = "¡Viajando por el mundo con WeFly! ✈️"; 
    final String photoUrl = ""; 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: WeFlyTheme.orangePrimary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- CABECERA EN DEGRADADO CON AVATAR ---
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: WeFlyTheme.mainGradient,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: const SafeArea(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Text(
                                "Mi Perfil",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.17,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: WeFlyTheme.orangePrimary.withOpacity(0.2),
                            // Si hay foto la pintamos, si no, mostramos la inicial
                            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                            child: photoUrl.isEmpty
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : "U",
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: WeFlyTheme.orangePrimary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 70),

                  // --- NOMBRE Y EMAIL ---
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // --- 🔥 NUEVO: BOTÓN EDITAR PERFIL ---
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Viajamos a tu pantalla pasándole los datos requeridos
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            userId: authProvider.userId ?? 0,
                            currentName: name,
                            currentBio: bio,
                            currentPhotoUrl: photoUrl,
                          ),
                        ),
                      );

                      // Si el usuario guardó cambios con éxito (devolvió true)
                      if (updated == true) {
                        // Aquí en el futuro llamaremos a un método para recargar el provider:
                        // authProvider.refreshUser();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18, color: WeFlyTheme.orangePrimary),
                    label: const Text(
                      "Editar Perfil",
                      style: TextStyle(color: WeFlyTheme.orangePrimary, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: WeFlyTheme.orangePrimary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- TARJETAS DE INFORMACIÓN ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildProfileCard(
                          icon: Icons.person_outline,
                          title: "Nombre Completo",
                          subtitle: name,
                        ),
                        const SizedBox(height: 15),
                        _buildProfileCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: "Biografía",
                          subtitle: bio,
                        ),
                        const SizedBox(height: 15),
                        _buildProfileCard(
                          icon: Icons.email_outlined,
                          title: "Correo Electrónico",
                          subtitle: email,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --- BOTÓN DE CERRAR SESIÓN ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await authProvider.logout();
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        label: const Text(
                          "CERRAR SESIÓN",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: WeFlyTheme.orangePrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}