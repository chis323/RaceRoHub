import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/message.dart';
import 'auth_service.dart';

class MessageService {
  final AuthService authService;

  MessageService(this.authService);

  Future<int> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 102; // fallback dev user
  }

  Future<List<Message>> getConversation(int partnerId) async {
    final userId = await _getCurrentUserId();
    final uri = Uri.parse('$kApiBaseUrl/api/messages/with/$partnerId');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': userId.toString(),
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load messages: ${res.statusCode}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Message> sendMessage(int partnerId, String content) async {
    final userId = await _getCurrentUserId();
    final uri = Uri.parse('$kApiBaseUrl/api/messages');

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': userId.toString(),
      },
      body: jsonEncode({
        'receiverId': partnerId,
        'content': content,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to send message: ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return Message.fromJson(json);
  }

  Future<List<Message>> getAllMessages() async {
    final userId = await _getCurrentUserId();
    final uri = Uri.parse('$kApiBaseUrl/api/messages');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': userId.toString(),
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load all messages: ${res.statusCode}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
