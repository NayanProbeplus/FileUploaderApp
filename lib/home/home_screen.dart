import 'dart:io';

import 'package:file_uploader_app/camera_screen.dart';
import 'package:file_uploader_app/constants/colors.dart';
import 'package:file_uploader_app/models/uploaded_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  List<UploadedImage> _uploadedImages = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prescriptionIdController =
      TextEditingController();
  final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();

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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          height: 360,
          child: Form(
            key: _dialogFormKey,
            child: Column(
              children: [
                // 🔹 HEADER
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Enter Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // 🔹 CONTENT
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Name (Optional)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          hintText: "Enter name (optional)",
                          prefixIcon:
                              const Icon(Icons.person_outline, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Prescription ID (Mandatory)
                      TextFormField(
                        controller: _prescriptionIdController,
                        decoration: InputDecoration(
                          labelText: "Prescription ID *",
                          hintText: "Enter prescription ID",
                          prefixIcon: const Icon(
                              Icons.medical_information_outlined,
                              size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Prescription ID is required'
                                : null,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 🔹 ACTION BUTTON
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_dialogFormKey.currentState!.validate()) {
                          Navigator.pop(context);
                          _openCamera(
                            _prescriptionIdController.text.trim(),
                          );

                          _nameController.clear();
                          _prescriptionIdController.clear();
                        }
                      },
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        "Open Camera",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
      _loadUploads();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: _uploadedImages.isEmpty
          ? const Center(child: Text("No uploads yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _uploadedImages.length,
              itemBuilder: (context, index) {
                final upload = _uploadedImages[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔄 SWIPEABLE IMAGES
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: upload.imagePaths.length == 1
                              ? Image.file(
                                  File(upload.imagePaths.first),
                                  fit: BoxFit.cover,
                                )
                              : Stack(
                                  children: [
                                    PageView.builder(
                                      itemCount: upload.imagePaths.length,
                                      itemBuilder: (_, imgIndex) {
                                        return Image.file(
                                          File(upload.imagePaths[imgIndex]),
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.photo_library,
                                                color: Colors.white, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${upload.imagePaths.length}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // 📝 Description
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          upload.description,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openDialog,
        shape: const CircleBorder(),
        elevation: 16,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
