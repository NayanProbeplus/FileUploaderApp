import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:multi_image_app/camera_screen.dart';
import 'package:multi_image_app/models/uploaded_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  List<UploadedImage> _uploadedImages = [];

  @override
  void initState() {
    super.initState();
    _loadUploads();
  }

  void _loadUploads() {
    final box = Hive.box('uploads');

    final data = box.values
        .map((e) => UploadedImage.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    setState(() {
      _uploadedImages = data;
    });
  }

  void _openDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enter details"),
        content: TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: "Prescription",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // if (_textController.text.isEmpty) return;

              Navigator.pop(context); // close dialog
              _openCamera(_textController.text);
              _textController.clear();
            },
            child: const Text("Open Camera"),
          ),
        ],
      ),
    );
  }

  void _openCamera(String description) async {
    final uploaded = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraScreen(description: description),
      ),
    );

    if (uploaded == true) {
      _loadUploads(); // 🔥 THIS WILL NOW RUN
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: _uploadedImages.isEmpty
          ? const Center(child: Text("No uploads yet"))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _uploadedImages.length,
              itemBuilder: (context, index) {
                final img = _uploadedImages[index];
                return Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(img.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      img.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
