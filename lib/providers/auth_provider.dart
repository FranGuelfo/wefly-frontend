import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_response.dart';

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
  bool _isLoading = false;

  // Getters para exponer el estado en tiempo real a la UI
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  // 1. Verificar si ya existe una sesión guardada al iniciar la aplicación
  Future<bool> checkLoginStatus() async {
    try {
      // CLAVES UNIFICADAS: Usamos siempre 'auth_token', 'user_id', etc.
      _token = await _storage.read(key: 'auth_token');
      final savedId = await _storage.read(key: 'user_id');
      _userName = await _storage.read(key: 'user_name');
      _userEmail = await _storage.read(key: 'user_email');

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
      // El bloque finally asegura que el spinner se apague SIEMPRE, falle o no la petición
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

      // Si el backend responde éxito, devolvemos true sin llamar a _saveSession
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
      // Disparar el flujo nativo/web de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // El usuario cerró la pestaña o canceló voluntariamente
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) return false;

      // Enviamos el idToken a Spring Boot (/auth/google) para recibir nuestro JWT corporativo
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

  // 5. Cerrar Sesión por Completo
  Future<void> logout() async {
    _setLoading(true);
    try {
      // Limpiamos los tokens guardados en el dispositivo
      await _storage.deleteAll();
      
      // Si estaba logueado con Google, liberamos la instancia
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.disconnect();
      }
    } catch (e) {
      debugPrint("Error desconectando Google en logout: $e");
    } finally {
      // Limpieza absoluta de las variables en memoria del estado central
      _token = null;
      _userId = null;
      _userName = null;
      _userEmail = null;
      _setLoading(false);
    }
  }

  // Métodos privados de ayuda (Auxiliares)
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _saveSession(AuthResponse authData) async {
    _token = authData.token;
    _userId = authData.userId;
    _userName = authData.name;
    _userEmail = authData.email;

    // Guardado unificado utilizando exactamente las mismas llaves de lectura
    await _storage.write(key: 'auth_token', value: _token);
    await _storage.write(key: 'user_id', value: _userId.toString());
    await _storage.write(key: 'user_name', value: _userName);
    await _storage.write(key: 'user_email', value: _userEmail);
    
    notifyListeners();
  }
}