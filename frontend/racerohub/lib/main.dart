import 'package:flutter/material.dart';
import 'widgets/track_page.dart';

void main() => runApp(const RaceRoHubApp());

class RaceRoHubApp extends StatelessWidget {
  const RaceRoHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RaceRoHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const TrackPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
