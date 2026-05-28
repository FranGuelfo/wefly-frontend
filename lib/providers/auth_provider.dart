import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_response.dart';

class UsuarioWeFly {
  final int id;
  final String nombre;
  final String email;
  final String rango;
  final double puntuacion;
  final int viajesCompartidos;
  final String? telefono;

  UsuarioWeFly({
    required this.id,
    required this.nombre,
    required this.email,
    this.rango = "Viajero Frecuente",
    this.puntuacion = 4.8,
    this.viajesCompartidos = 24,
    this.telefono,
  });

  // 1. FACTORY: Para convertir el JSON que viene del servidor a un objeto
  factory UsuarioWeFly.fromJson(Map<String, dynamic> json) {
    return UsuarioWeFly(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Usuario',
      email: json['email'] ?? '',
      rango: json['rango'] ?? 'Viajero Frecuente',
      // Aseguramos que puntuacion sea double (por si el JSON trae un int)
      puntuacion: (json['puntuacion'] ?? 4.8).toDouble(),
      viajesCompartidos: json['viajesCompartidos'] ?? 0,
      telefono: json['telefono'],
    );
  }

  // 2. TOJSON: Para convertir el objeto a Map y enviarlo al servidor si editas el perfil
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rango': rango,
      'puntuacion': puntuacion,
      'viajesCompartidos': viajesCompartidos,
      'telefono': telefono,
    };
  }
}

class AuthProvider extends ChangeNotifier {
  // Configuración de llamadas HTTP apuntando a tu backend Spring Boot
  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081/api/v1'));
  
  // Storage blindado con WebOptions para evitar el await infinito en navegadores
  final _storage = const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'WeFlyAuth',
      publicKey: 'WeFlySecretKey',
    ),
  );
  
  // Configuración de Google Sign-In para entornos nativos/web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  String? _token;
  int? _userId;
  String? _userName;
  String? _userEmail;
  String? _userPhone; // Añadido para EditProfileScreen
  bool _isLoading = false;

  // Variables de estadísticas para que no estén estáticas en la UI
  String _userRange = "Viajero Frecuente";
  double _userRating = 4.8;
  int _userTrips = 24;

  // Getters para exponer el estado en tiempo real a la UI
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  /// 🔥 EL GETTER CLAVE: Resuelve el error de la pantalla ProfileScreen
  UsuarioWeFly? get usuarioActual {
    if (_token == null || _userId == null) return null;
    return UsuarioWeFly(
      id: _userId!,
      nombre: _userName ?? "Usuario WeFly",
      email: _userEmail ?? "",
      rango: _userRange,
      puntuacion: _userRating,
      viajesCompartidos: _userTrips,
      telefono: _userPhone,
    );
  }

  // 1. Verificar si ya existe una sesión guardada al iniciar la aplicación
  Future<bool> checkLoginStatus() async {
    try {
      _token = await _storage.read(key: 'auth_token');
      final savedId = await _storage.read(key: 'user_id');
      _userName = await _storage.read(key: 'user_name');
      _userEmail = await _storage.read(key: 'user_email');
      _userPhone = await _storage.read(key: 'user_phone'); // Leemos teléfono si existe

      if (_token != null && savedId != null) {
        _userId = int.tryParse(savedId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error leyendo el almacenamiento persistente: $e");
    }
    return false;
  }

  // 2. Login Tradicional (Email y Contraseña)
  Future<bool> loginWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final authData = AuthResponse.fromJson(response.data);
        await _saveSession(authData);
        return true;
      }
    } catch (e) {
      debugPrint("Error en login tradicional: $e");
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // 3. Registro Tradicional
  Future<bool> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true; 
      }
    } catch (e) {
      debugPrint("Error en registro: $e");
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // 4. Login / Registro con Google
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) return false;

      final response = await _dio.post('/auth/google', data: {
        'idToken': idToken,
      });

      if (response.statusCode == 200) {
        final authData = AuthResponse.fromJson(response.data);
        await _saveSession(authData);
        return true;
      }
    } catch (e) {
      debugPrint("Error en Google Sign-In: $e");
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // Para que EditProfileScreen guarde los cambios en local y backend
  Future<bool> actualizarPerfil({required String nombre, required String telefono}) async {
    _setLoading(true);
    try {
      // Opcional: Si tienes el endpoint listo en Spring Boot, quita los comentarios de abajo
      /*
      final response = await _dio.put('/users/$_userId', 
        data: {'name': nombre, 'phone': telefono},
        options: Options(headers: {'Authorization': 'Bearer $_token'})
      );
      */

      // Guardamos localmente el estado modificado
      _userName = nombre;
      _userPhone = telefono;

      await _storage.write(key: 'user_name', value: nombre);
      await _storage.write(key: 'user_phone', value: telefono);

      notifyListeners(); // Esto redibuja instantáneamente ProfileScreen con los datos nuevos
      return true;
    } catch (e) {
      debugPrint("Error actualizando perfil: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 5. Cerrar Sesión por Completo
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _storage.deleteAll();
      
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
    } catch (e) {
      debugPrint("Error desconectando Google en logout: $e");
    } finally {
      _token = null;
      _userId = null;
      _userName = null;
      _userEmail = null;
      _userPhone = null;
      _setLoading(false);
    }
  }

  // Métodos privados auxiliares
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _saveSession(AuthResponse authData) async {
    _token = authData.token;
    _userId = authData.userId;
    _userName = authData.name;
    _userEmail = authData.email;
    _userPhone = ""; // Inicialmente vacío hasta que complete su perfil

    await _storage.write(key: 'auth_token', value: _token);
    await _storage.write(key: 'user_id', value: _userId.toString());
    await _storage.write(key: 'user_name', value: _userName);
    await _storage.write(key: 'user_email', value: _userEmail);
    await _storage.write(key: 'user_phone', value: _userPhone);
    
    notifyListeners();
  }
}