import 'package:flutter/material.dart';
import '../theme/wefly_theme.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  
  String _name = "";
  String _bio = "";
  String _photoUrl = "";
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userData = await _apiService.getUserProfile(widget.userId);
      setState(() {
        _name = userData.name;
        _bio = userData.bio ?? 'Sin biografía disponible.';
        _photoUrl = userData.profilePictureUrl ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al conectar con el servidor";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Extraemos la inicial exactamente igual que en la pantalla de edición
    final String firstLetter = _name.trim().isNotEmpty ? _name.trim()[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: WeFlyTheme.orangePrimary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchUserProfile,
                        child: const Text("Reintentar"),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- ENCABEZADO CON DEGRADADO ---
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: WeFlyTheme.mainGradient,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 140,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.grey[200],
                                child: ClipOval(
                                  child: _photoUrl.trim().isNotEmpty
                                      ? Image.network(
                                          _photoUrl.trim(),
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.cover,
                                          // 🔥 Si el navegador bloquea la imagen por CORS, cargamos la inicial
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Text(
                                                firstLetter,
                                                style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.indigo),
                                              ),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: Text(
                                            firstLetter,
                                            style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 80),

                      // --- INFO DE USUARIO DINÁMICA ---
                      Text(
                        _name,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                      const Text(
                        "Viajera Verificada",
                        style: TextStyle(color: WeFlyTheme.orangePrimary, fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 30),

                      // --- SECCIÓN BIOGRAFÍA DINÁMICA (CARD) ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sobre mí",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _bio,
                                style: TextStyle(color: Colors.grey[800], fontSize: 16, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- BOTÓN EDITAR ---
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                userId: widget.userId,
                                currentName: _name,
                                currentBio: _bio,
                                currentPhotoUrl: _photoUrl,
                              ),
                            ),
                          );

                          if (result == true) {
                            _fetchUserProfile();
                          }
                        },
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text("EDITAR PERFIL"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WeFlyTheme.orangePrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 3,
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
    );
  }
}