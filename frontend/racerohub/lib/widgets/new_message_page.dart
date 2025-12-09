import 'package:flutter/material.dart';
import 'package:racerohub/models/user.dart';
import 'package:racerohub/services/auth_service.dart';

import 'chat_page.dart';

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({super.key});

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  List<User> _results = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _doSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _authService.searchUsers(q);
      setState(() {
        _results = users;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search users: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openChat(User u) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          partnerId: u.id,
          partnerName: u.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New message'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search user by name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _doSearch,
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_results.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No users found'),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final u = _results[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        u.name.isNotEmpty
                            ? u.name[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(u.name),
                    subtitle: Text('User ID: ${u.id}'),
                    onTap: () => _openChat(u),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
