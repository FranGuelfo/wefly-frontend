import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  WebSocketChannel? _channel;
  
  List<dynamic> _messages = [];
  bool _isLoading = false;
  
  // --- NUEVAS VARIABLES PARA LA AUTO-RECONEXIÓN ---
  bool _intentionallyDisconnected = false;
  bool _isReconnecting = false;
  Timer? _reconnectTimer;
  int _currentAnnouncementId = 0;

  List<dynamic> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isReconnecting => _isReconnecting;

  /// Inicializa el chat: Carga historial por primera vez y lanza la conexión WS
  Future<void> initChat(int announcementId, int userId) async {
    _isLoading = true;
    _messages = [];
    _intentionallyDisconnected = false;
    _currentAnnouncementId = announcementId;
    notifyListeners();

    // 1. Cargamos el historial por HTTP REST una sola vez
    final history = await _apiService.getChatHistory(announcementId);
    _messages = history;
    _isLoading = false;
    notifyListeners();

    await _apiService.markChatAsRead(announcementId, userId);

    // 2. Conectamos al WebSocket por primera vez
    _connectWebSocket();
  }

  /// Gestiona la conexión y escucha del WebSocket
  void _connectWebSocket() {
    if (_intentionallyDisconnected) return;

    final String wsUrl = "ws://localhost:8081/chat/$_currentAnnouncementId";
    log("Intentando conectar al WebSocket en: $wsUrl");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isReconnecting = false;
      notifyListeners();
      
      // Nos quedamos escuchando el flujo
      _channel!.stream.listen(
        (messageJson) {
          log("Nuevo mensaje recibido: $messageJson");
          final newMessage = jsonDecode(messageJson);
          _messages.add(newMessage);
          notifyListeners();
        },
        onError: (error) {
          log("Error detectado en el stream del WebSocket: $error");
          _handleConnectionLoss();
        },
        onDone: () {
          log("El stream del WebSocket se ha cerrado (onDone).");
          _handleConnectionLoss();
        },
      );
    } catch (e) {
      log("Excepción al intentar conectar al WebSocket: $e");
      _handleConnectionLoss();
    }
  }

  /// Se activa cuando la conexión se cae inesperadamente
  void _handleConnectionLoss() {
    // Si el usuario se fue de la pantalla a propósito, no hacemos nada
    if (_intentionallyDisconnected) return;

    // Si ya hay un proceso de reconexión activo, no duplicamos temporizadores
    if (_isReconnecting) return;

    _isReconnecting = true;
    notifyListeners();
    log("⚠️ Conexión perdida. Activando modo auto-reconexión en 5 segundos...");

    // Cancelamos cualquier timer previo por seguridad
    _reconnectTimer?.cancel();

    // Intentamos reconectar cada 5 segundos de forma indefinida hasta que vuelva
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_intentionallyDisconnected) {
        timer.cancel();
        return;
      }
      
      log("🔄 Reintentando conectar al chat de grupo...");
      _connectWebSocket();
    });
  }

  /// Envía un mensaje al servidor en formato JSON
  void sendMessage(int announcementId, int senderId, String senderName, String content) {
    if (_channel == null || content.trim().isEmpty) {
      log("No se pudo enviar el mensaje: WebSocket desconectado o mensaje vacío.");
      return;
    }

    final messageMap = {
      "senderId": senderId,
      "senderName": senderName,
      "content": content.trim(),
    };

    try {
      _channel!.sink.add(jsonEncode(messageMap));
    } catch (e) {
      log("Error al empujar el mensaje al sink", error: e);
      _handleConnectionLoss(); // Si falla al enviar, es que la conexión ha muerto
    }
  }

  /// Cierra el grifo por completo cuando salimos de la pantalla (dispose)
  void disconnect() {
    _intentionallyDisconnected = true;
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _messages = [];
    log("🛑 WebSocket y temporizadores cancelados limpiamente por el usuario.");
  }
}