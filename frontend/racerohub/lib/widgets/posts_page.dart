import 'package:flutter/material.dart';
import 'package:racerohub/constants.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/footer_menu.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final _postService = PostService();
  late Future<List<Post>> _futurePosts;

  static const int _footerIndex = 0;

  @override
  void initState() {
    super.initState();
    _futurePosts = _postService.fetchPosts();
  }

  Future<void> _reload() async {
    setState(() {
      _futurePosts = _postService.fetchPosts();
    });
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
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
                      'Failed to load posts:\n${snap.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final posts = (snap.data ?? const <Post>[]).toList();
          if (posts.isEmpty) {
            return const Center(child: Text('No posts yet.'));
          }

          posts.sort(
            (a, b) => (b.date ?? DateTime.fromMillisecondsSinceEpoch(0))
                .compareTo(a.date ?? DateTime.fromMillisecondsSinceEpoch(0)),
          );

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = posts[i];

                final imageUrl = (p.image == null || p.image!.isEmpty)
                    ? null
                    : '$kApiBaseUrl/uploads/${p.image}';

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (p.authorName != null || p.date != null)
                          Text(
                            [
                              if (p.authorName != null) 'by ${p.authorName}',
                              if (p.date != null) _formatDate(p.date),
                            ].join(' • '),
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(p.content),
                        if (imageUrl != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Failed to load image'),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const FooterMenu(currentIndex: _footerIndex),
    );
  }
}
