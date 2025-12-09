import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_page.dart';
import 'new_message_page.dart';
import 'package:racerohub/widgets/footer_menu.dart';

import 'package:racerohub/services/auth_service.dart';
import 'package:racerohub/services/message_service.dart';
import 'package:racerohub/models/message.dart';
import 'package:racerohub/models/user.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  static const int _footerIndex = 2;

  late final AuthService _authService;
  late final MessageService _messageService;

  int? _currentUserId;
  Future<List<_ConversationItem>>? _futureConversations;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _messageService = MessageService(_authService);
    _initUserAndConversations();
  }

  Future<void> _initUserAndConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');

    // fallback for dev if not logged in correctly
    _currentUserId = id ?? 102;

    _loadConversations();
  }

  void _loadConversations() {
    if (_currentUserId == null) return;
    setState(() {
      _futureConversations = _fetchConversations(_currentUserId!);
    });
  }

  Future<List<_ConversationItem>> _fetchConversations(int currentUserId) async {
    // 1. Get all messages from backend
    final List<Message> messages = await _messageService.getAllMessages();
    if (messages.isEmpty) return [];

    // 2. Group by partnerId (the other user in each conversation)
    final Map<int, _ConversationItem> byPartner = {};

    for (final m in messages) {
      final bool isMeSender = m.senderId == currentUserId;
      final bool isMeReceiver = m.receiverId == currentUserId;

      // Ignore messages that don't involve this user at all
      if (!isMeSender && !isMeReceiver) continue;

      final int partnerId = isMeSender ? m.receiverId : m.senderId;

      final existing = byPartner[partnerId];
      if (existing == null || m.createdAt.isAfter(existing.lastMessageTime)) {
        byPartner[partnerId] = _ConversationItem(
          partnerId: partnerId,
          partnerName: 'User $partnerId', // temp, will be replaced with real name
          lastMessage: m.content,
          lastMessageTime: m.createdAt,
        );
      }
    }

    if (byPartner.isEmpty) return [];

    // 3. Fetch real partner names from backend
    final List<int> partnerIds = byPartner.keys.toList();
    final Map<int, String> idToName = {};

    for (final pid in partnerIds) {
      try {
        final User u = await _authService.getUserById(pid);
        idToName[pid] = u.name;
      } catch (_) {
        // fall back to "User <id>" if fetch fails
        idToName[pid] = 'User $pid';
      }
    }

    // 4. Apply real names
    final list = byPartner.values
        .map(
          (c) => _ConversationItem(
            partnerId: c.partnerId,
            partnerName: idToName[c.partnerId] ?? c.partnerName,
            lastMessage: c.lastMessage,
            lastMessageTime: c.lastMessageTime,
          ),
        )
        .toList();

    // 5. Sort by last message time desc
    list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return list;
  }

  Future<void> _openNewMessage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewMessagePage()),
    );
    // when we come back from "new message", reload conversations
    _loadConversations();
  }

  Future<void> _openChat(_ConversationItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          partnerId: item.partnerId,
          partnerName: item.partnerName,
        ),
      ),
    );
    // when we come back from chat, reload (for new messages)
    _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New message',
            onPressed: _openNewMessage,
          ),
        ],
      ),
      body: _currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<_ConversationItem>>(
              future: _futureConversations,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load messages:\n${snap.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _loadConversations,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final convos = snap.data ?? [];

                if (convos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'No messages yet',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _openNewMessage,
                          icon: const Icon(Icons.add),
                          label: const Text('Send a new message'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: convos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = convos[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          item.partnerName.isNotEmpty
                              ? item.partnerName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(
                        item.partnerName,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(item.lastMessage),
                      onTap: () => _openChat(item),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: const FooterMenu(currentIndex: _footerIndex),
    );
  }
}

class _ConversationItem {
  final int partnerId;
  final String partnerName;
  final String lastMessage;
  final DateTime lastMessageTime;

  _ConversationItem({
    required this.partnerId,
    required this.partnerName,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}