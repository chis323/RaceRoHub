import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message.dart';
import '../services/auth_service.dart';
import '../services/message_service.dart';
import '../widgets/footer_menu.dart';

class ChatPage extends StatefulWidget {
  final int partnerId;
  final String partnerName;

  const ChatPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final MessageService _messageService;
  late final AuthService _authService;

  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  int? _currentUserId;
  bool _isLoading = true;

  // footer index: Messages tab
  static const int _footerIndex = 2;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _messageService = MessageService(_authService);
    _init();
  }

  Future<void> _init() async {
    // read current user id from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('userId') ?? 102; // fallback dev user

    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final msgs = await _messageService.getConversation(widget.partnerId);
      setState(() {
        _messages
          ..clear()
          ..addAll(msgs);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    _controller.clear();
    final msg = await _messageService.sendMessage(widget.partnerId, text);
    setState(() {
      _messages.add(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final me = _currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.partnerName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      final isMe = me != null && m.senderId == me;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.redAccent
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            m.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FooterMenu(currentIndex: _footerIndex),
    );
  }
}
