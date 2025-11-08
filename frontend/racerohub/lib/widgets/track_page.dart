import 'package:flutter/material.dart';
import '../models/track.dart';
import '../services/track_service.dart';
import './track_list.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  late final TrackService _service;
  late Future<List<Track>> _future;

  @override
  void initState() {
    super.initState();
    _service = const TrackService();
    _future = _service.fetchTracks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracks')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Tracks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: FutureBuilder<List<Track>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load tracks\n\n${snap.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final tracks = snap.data ?? const <Track>[];
          if (tracks.isEmpty) {
            return const Center(child: Text('No tracks yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: tracks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => TrackList(track: tracks[i]),
          );
        },
      ),
    );
  }
}
