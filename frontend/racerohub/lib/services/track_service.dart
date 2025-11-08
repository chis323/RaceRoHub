import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';
import '../constants.dart';

class TrackService {
  const TrackService();

  Future<List<Track>> fetchTracks() async {
    final res = await http.get(Uri.parse('$kApiBaseUrl/api/track'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load tracks: ${res.statusCode}');
    }
    final data = json.decode(res.body);
    if (data is List) {
      return data
          .map((e) => Track.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response');
  }
}
