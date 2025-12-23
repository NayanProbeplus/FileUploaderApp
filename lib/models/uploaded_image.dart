class UploadedImage {
  final String description;
  final List<String> imagePaths;
  final DateTime uploadedAt;

  UploadedImage({
    required this.description,
    required this.imagePaths,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() => {
        'description': description,
        'imagePaths': imagePaths,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  factory UploadedImage.fromMap(Map<String, dynamic> map) {
    return UploadedImage(
      description: map['description'],
      imagePaths: List<String>.from(map['imagePaths']),
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }
}
