import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_uploader_app/api/file_upload_api.dart';
import 'package:file_uploader_app/main.dart';
import 'package:file_uploader_app/models/uploaded_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CameraScreen extends StatefulWidget {
  final String description;

  const CameraScreen({super.key, required this.description});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeCameraFuture;

  final List<XFile> _images = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeCameraFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 📸 CAPTURE IMAGE
  Future<void> _captureImage() async {
    if (_isUploading) return;

    try {
      final image = await _controller.takePicture();
      setState(() => _images.add(image));
    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  // ❌ DELETE IMAGE
  void _deleteImage(int index) {
    if (_isUploading) return;

    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _mockUpload() async {
    if (_images.isEmpty || _isUploading) return;

    setState(() => _isUploading = true);

    try {
      // 🔹 1. Upload to server
      await uploadToServer();

      // 🔹 2. Save locally to Hive (unchanged)
      final box = Hive.box('uploads');

      final uploaded = UploadedImage(
        description: widget.description,
        imagePaths: _images.map((e) => e.path).toList(),
        uploadedAt: DateTime.now(),
      );

      box.add(uploaded.toMap());

      if (!mounted) return;

      _images.clear();
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> uploadToServer() async {
    final files = _images.map((e) => File(e.path)).toList();

    final docsList = files.map((file) {
      return {
        "file_name": file.uri.pathSegments.last,
        "file_size": file.lengthSync().toString(),
        "file_type": file.path.split('.').last,
      };
    }).toList();

    // 1️⃣ Get presigned URLs
    final response = await FileUploadApi.uploadDocuments(
      patientId: 'PATIENT_001',
      prescriptionId: widget.description,
      docsList: docsList,
    );

    final Map<String, String> presignedUrls =
        Map<String, String>.from(response['data']['doc_url']);

    // 2️⃣ Upload each file to S3
    for (final file in files) {
      final fileName = file.uri.pathSegments.last;
      final url = presignedUrls[fileName];

      if (url != null) {
        await S3Uploader.uploadFileToS3(
          presignedUrl: url,
          file: file,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeCameraFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              // 🔹 FULLSCREEN CAMERA
              Positioned.fill(
                child: CameraPreview(_controller),
              ),

              // 🔹 BACK BUTTON
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed:
                        _isUploading ? null : () => Navigator.pop(context),
                  ),
                ),
              ),

              // 🔹 IMAGE THUMBNAILS OVERLAY
              if (_images.isNotEmpty)
                Positioned(
                  bottom: 140,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_images[index].path),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isUploading
                                    ? null
                                    : () => _deleteImage(index),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

              // 🔹 CAPTURE BUTTON (DISABLED DURING UPLOAD)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _isUploading ? null : _captureImage,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isUploading ? Colors.grey : Colors.white,
                          width: 4,
                        ),
                        color:
                            _isUploading ? Colors.black54 : Colors.transparent,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: _isUploading ? Colors.grey : Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 🔹 BOTTOM UPLOAD BAR
              if (_images.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 📸 Image count
                        Text(
                          "${_images.length} image(s)",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),

                        const Spacer(),

                        // ⏳ Uploading loader
                        if (_isUploading)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),

                        const SizedBox(width: 12),

                        // 📤 Upload button
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : _mockUpload,
                          icon: const Icon(
                            Icons.cloud_upload,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Upload",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            disabledBackgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
