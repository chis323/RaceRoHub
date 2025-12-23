import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:racerohub/constants.dart';

class NewPostPage extends StatefulWidget {
  final int userId;
  const NewPostPage({super.key, required this.userId});

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _picker = ImagePicker();
  XFile? _image;

  bool _submitting = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    setState(() => _image = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final uri = Uri.parse('$kApiBaseUrl/posts');

      final request = http.MultipartRequest('POST', uri);
      final postJson = jsonEncode({
        'title': _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'userId': widget.userId,
      });

      request.fields['post'] = postJson;

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _image!.path),
        );
      }

      final streamed = await request.send();
      final respBody = await streamed.stream.bytesToString();

      if (!mounted) return;

      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post created')));
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed (${streamed.statusCode}): $respBody')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageName = _image?.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  if (v.trim().length < 3) return 'Title too short';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Content is required';
                  if (v.trim().length < 5) return 'Content too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      _image == null ? 'Add image (optional)' : 'Change image',
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_image != null)
                    Expanded(
                      child: Text(
                        imageName ?? 'Selected image',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),

              if (_image != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_image!.path),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
