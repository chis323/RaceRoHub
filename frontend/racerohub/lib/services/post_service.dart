import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:racerohub/constants.dart';
import '../models/post.dart';

class PostService {
  Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('$kApiBaseUrl/posts');
    final resp = await http.get(uri);

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        'Failed to load posts (${resp.statusCode}): ${resp.body}',
      );
    }

    final List<dynamic> data = jsonDecode(resp.body);
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }
}
