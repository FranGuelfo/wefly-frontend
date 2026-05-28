import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/announcement_provider.dart'; 
import 'theme/wefly_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/user_provider.dart';
import 'providers/flight_provider.dart';

void main() {
  // Inicialización limpia estándar de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FlightProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeFly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Urbanist',
      ),
      home: const AuthWrapper(), 
    );
  }
}

// Widget optimizado sin FutureBuilder que evita bucles infinitos en la UI
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    // Comprobamos el estado del login UNA SOLA VEZ al montar el widget
    _initAuth();
  }

  Future<void> _initAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();
    if (mounted) {
      setState(() {
        _isChecking = false; // Apagamos la carga inicial
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Mientras lee el almacenamiento (o procesa el inicio), muestra carga central corporativa
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: WeFlyTheme.orangePrimary), // 3. 🎨 Spinner con vuestro color corporativo
        ),
      );
    }

    // 2. Si está autenticado, directo a la navegación principal
    if (authProvider.isAuthenticated) {
      return const MainNavigationScreen(); 
    }

    // 3. Si no está autenticado, va directo al Login limpio
    return const LoginScreen();
  }
}