import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/wefly_theme.dart';

class ChatScreen extends StatefulWidget {
  final int announcementId;
  final String title;

  const ChatScreen({
    super.key, 
    required this.announcementId, 
    required this.title
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // 1. Declaramos la variable para guardar la referencia del Provider
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    // Inicializamos el chat al entrar: historial + conexión WebSocket
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId ?? 0;

      // Aquí también puedes usar _chatProvider ya que el callback corre después del primer frame
      _chatProvider.initChat(widget.announcementId, userId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 2. Guardamos la referencia de forma segura mientras el árbol de widgets está activo
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // 3. Usamos la referencia guardada previamente. ¡Ya NO genera error!
    _chatProvider.disconnect();
    
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Función optimizada para hacer scroll automático al final
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId ?? 0;
    final userName = authProvider.userName ?? "Usuario";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Chat de grupo", 
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // --- ÁREA DE MENSAJES (Tiempo Real) ---
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Disparamos el scroll al final en el próximo frame tras recibir un mensaje
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return Column(
                  children: [
                    // Alerta visual si se pierde el WebSocket de forma temporal
                    if (chatProvider.isReconnecting)
                      Container(
                        color: Colors.amber.shade700,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: const Text(
                          "Conexión perdida. Reconectando...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    
                    // Listado de burbujas
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chatProvider.messages[index];
                          final bool isMe = msg['senderId'] == userId;

                          return _buildMessageBubble(msg, isMe);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // --- CAJA DE ENTRADA DE TEXTO ---
          _buildInputArea(userId, userName),
        ],
      ),
    );
  }

  // Widget para las burbujas de chat estilo mensajería moderna
  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    String time = "";
    if (msg['timestamp'] != null) {
      DateTime dt = DateTime.parse(msg['timestamp']);
      time = DateFormat('HH:mm').format(dt);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? WeFlyTheme.orangePrimary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg['senderName'] ?? "Usuario",
                  style: const TextStyle(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    color: WeFlyTheme.orangePrimary,
                  ),
                ),
              ),
            Text(
              msg['content'] ?? "",
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente inferior para escribir y enviar
  Widget _buildInputArea(int userId, String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12, 
            blurRadius: 10, 
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: "Escribe un mensaje...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: WeFlyTheme.orangePrimary,
              radius: 25,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isEmpty) return;
                  
                  // Aprovechamos la variable de clase '_chatProvider' aquí también
                  _chatProvider.sendMessage(
                    widget.announcementId, 
                    userId, 
                    userName, 
                    text,
                  );
                  
                  // Limpieza inmediata de la caja de texto y reajuste de vista
                  _messageController.clear();
                  _scrollToBottom();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}