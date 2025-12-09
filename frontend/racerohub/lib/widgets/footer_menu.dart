import 'package:flutter/material.dart';
import './profile_page.dart';
import './track_page.dart';
import './message_page.dart';

class FooterMenu extends StatelessWidget {
  final int currentIndex;

  const FooterMenu({super.key, required this.currentIndex});

  void _onNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget target;

    switch (index) {
      case 0:
        target = const ProfilePage();
        break;
      case 1:
        target = const TrackPage();
        break;
      case 2:
        target = const MessagesPage();
        break;
      case 3:
        target = const ProfilePage();
        break;
      default:
        target = const TrackPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => _onNavTap(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.route),
          label: 'Tracks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
