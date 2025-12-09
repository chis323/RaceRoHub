import 'package:flutter/material.dart';
import 'package:racerohub/models/car.dart';
import 'package:racerohub/models/user.dart';
import 'package:racerohub/services/auth_service.dart';
import 'package:racerohub/services/car_service.dart';
import 'package:racerohub/widgets/car_card.dart';
import 'package:racerohub/widgets/car_form.dart';
import 'package:racerohub/widgets/footer_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _svc = AuthService();
  final CarService _carService = CarService();

  Future<User>? _futureUser;
  Future<Car>? _futureCar;

  // footer index: 0 = Home, 1 = Tracks, 2 = Messages, 3 = Profile
  static const int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    if (id == null) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }
    setState(() {
      _futureUser = _svc.getUserById(id);
      _futureCar = _carService.fetchCar(id);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userRole');

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      bottomNavigationBar: const FooterMenu(currentIndex: _currentIndex),
      body: FutureBuilder<User>(
        future: _futureUser,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load profile:\n${snap.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadUser,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // top card with avatar + name + id
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('User ID: ${user.id}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // details + car
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Name'),
                      subtitle: Text(user.name),
                    ),
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.verified_user_outlined),
                      title: const Text('Role'),
                      subtitle: Text(user.role),
                    ),
                    const Divider(height: 0),
                    FutureBuilder<Car>(
                      future: _futureCar,
                      builder: (context, carSnap) {
                        if (carSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (carSnap.hasError || !carSnap.hasData) {
                          // show form if no car yet
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: CarForm(
                              userId: user.id,
                              onSaved: (car) {
                                setState(() {
                                  _futureCar = Future.value(car);
                                });
                              },
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: CarCard(car: carSnap.data!),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
