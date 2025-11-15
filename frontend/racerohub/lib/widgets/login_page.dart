import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../models/user_dto.dart';
import '../models/user.dart';
import '../services/auth_exceptions.dart';
import 'track_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    final dto = UserDto(
      name: _nameCtrl.text.trim(),
      password: _passCtrl.text,
    );

    try {
      User user;

      try {
        
        user = await _auth.register(dto);
      } on UserConflictException {
        
        try {
          user = await _auth.login(dto); 
        } on InvalidPasswordException {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid password')),
          );
          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id);
      await prefs.setString('userName', user.name);
      await prefs.setString('userRole', user.role);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${user.name}!')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TrackPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('RaceRoHub • Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome back',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    enabled: !_loading,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                  ),
                  spacing,
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    enabled: !_loading,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty)
                            ? 'Please enter your password'
                            : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(_loading ? 'Signing in…' : 'Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
