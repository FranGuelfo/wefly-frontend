import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../theme/wefly_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final int userId;
  final String currentName;
  final String currentBio;
  final String currentPhotoUrl;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentBio,
    required this.currentPhotoUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081/api/v1'));
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _photoController; 
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(text: widget.currentBio);
    _photoController = TextEditingController(text: widget.currentPhotoUrl);

    // Escuchamos los cambios en el input de la foto para refrescar la vista previa
    _photoController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // 🔥 Ahora el PATCH viaja al puerto correcto y añade también el 'profilePictureUrl'
      final response = await _dio.patch(
        '/users/${widget.userId}',
        data: {
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'profilePictureUrl': _photoController.text.trim(), // Ajusta esta clave al nombre exacto de tu DTO en Java
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Perfil actualizado con éxito!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Volvemos al perfil avisando que hay cambios
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar los cambios: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String firstLetter = _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AVATAR CON VISTA PREVIA EN TIEMPO REAL Y CONTROL DE ERRORES (CORS/URL ROTA) ---
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: _photoController.text.isNotEmpty
                            ? Image.network(
                                _photoController.text.trim(),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                // 🔥 Si da error de CORS o la URL es mala, muestra la inicial del usuario
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      firstLetter,
                                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  firstLetter,
                                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: WeFlyTheme.orangePrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.link,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- INPUT NOMBRE (EDITABLE) ---
            const Text(
              'Nombre de usuario',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintText: "Tu nombre",
              ),
            ),
            const SizedBox(height: 25),

            // --- INPUT URL DE FOTO (EDITABLE CON VISTA PREVIA) ---
            const Text(
              'Enlace de la Foto de Perfil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _photoController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                prefixIcon: const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintText: "http://ejemplo.com/foto.jpg",
              ),
            ),
            const SizedBox(height: 25),

            // --- INPUT BIOGRAFÍA (EDITABLE) ---
            const Text(
              'Biografía',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                hintText: "Cuéntanos sobre ti...",
              ),
            ),
            const SizedBox(height: 40),

            // --- BOTÓN GUARDAR ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WeFlyTheme.orangePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GUARDAR CAMBIOS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}