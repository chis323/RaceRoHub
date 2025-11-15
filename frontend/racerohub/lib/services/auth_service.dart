import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/user.dart';
import '../models/user_dto.dart';
import 'auth_exceptions.dart';

class AuthService {
  final http.Client _client;
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<User> login(UserDto dto) async {
    final uri = Uri.parse(kApiBaseUrl).replace(path: '/api/users/auth/login');

    final resp = await _client.post(
      uri,
      headers: const {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return _parseUser(resp.body);
    }

    if (resp.statusCode == 401) {
      throw InvalidPasswordException();
    }
    if (resp.statusCode == 404) {
      throw UserNotFoundException();
    }

    throw HttpException(
      'Login failed: ${resp.statusCode} ${resp.reasonPhrase}\n${resp.body}',
    );
  }

  Future<User> register(UserDto dto) async {
    final uri = Uri.parse(kApiBaseUrl).replace(path: '/api/users');

    final resp = await _client.post(
      uri,
      headers: const {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return _parseUser(resp.body);
    }

    if (resp.statusCode == 409) {
      throw UserConflictException();
    }

    throw HttpException(
      'Register failed: ${resp.statusCode} ${resp.reasonPhrase}\n${resp.body}',
    );
  }

  Future<User> getUserById(int id) async {
    final uri = Uri.parse(kApiBaseUrl).replace(path: '/api/users/$id');

    final resp = await _client.get(
      uri,
      headers: const {HttpHeaders.acceptHeader: 'application/json'},
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return _parseUser(resp.body);
    }

    throw HttpException(
      'Get user failed: ${resp.statusCode} ${resp.reasonPhrase}\n${resp.body}',
    );
  }

  User _parseUser(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    return User.fromJson(data);
  }
}
