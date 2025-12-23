class UploadedImage {
  final String path;
  final String description;
  final DateTime uploadedAt;

  UploadedImage({
    required this.path,
    required this.description,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() => {
        'path': path,
        'description': description,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  factory UploadedImage.fromMap(Map<String, dynamic> map) {
    return UploadedImage(
      path: map['path'],
      description: map['description'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
}
