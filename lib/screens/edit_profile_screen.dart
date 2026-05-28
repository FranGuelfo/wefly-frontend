import 'package:flutter/material.dart';
import '../theme/wefly_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores con los datos actuales del usuario para editarlos
  final _nombreController = TextEditingController(text: "Carlos Mendoza");
  final _telefonoController = TextEditingController(text: "+34 600 00 00 00");
  final _emailController = TextEditingController(text: "carlos.mendoza@email.com");

  bool _isSaving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 🔥 NUEVA FUNCIÓN: Despliega el selector inferior para cambiar la foto
  void _cambiarFotoPerfil() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 35,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: WeFlyTheme.orangePrimary),
              title: const Text("Elegir de la Galería", style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Acceso a la galería simulado con éxito 📸")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: WeFlyTheme.orangePrimary),
              title: const Text("Hacer Foto con la Cámara", style: TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Acceso a la cámara simulado con éxito 📸")),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _guardarPerfil() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      // Simulamos la petición al ApiService.updateUserProfile
      await Future.delayed(const Duration(seconds: 1)); 

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Perfil actualizado correctamente! ✨'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volvemos al perfil
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: WeFlyTheme.orangePrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 🔥 CONECTADO: Ahora al pulsar el avatar se abre el selector de fotos
                    GestureDetector(
                      onTap: _cambiarFotoPerfil,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: WeFlyTheme.orangePrimary,
                            child: Icon(Icons.person_rounded, size: 55, color: Colors.white),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: WeFlyTheme.orangePrimary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    // CAMPO NOMBRE
                    _buildEditField(
                      controller: _nombreController,
                      label: "Nombre completo",
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 15),

                    // CAMPO TELÉFONO
                    _buildEditField(
                      controller: _telefonoController,
                      label: "Número de teléfono (Para WhatsApp)",
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    // CAMPO EMAIL
                    _buildEditField(
                      controller: _emailController,
                      label: "Correo electrónico",
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 40),

                    // BOTÓN GUARDAR
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _guardarPerfil,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WeFlyTheme.orangePrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text("GUARDAR CAMBIOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        floatingLabelStyle: const TextStyle(color: WeFlyTheme.orangePrimary),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Este campo no puede quedar vacío' : null,
    );
  }
}