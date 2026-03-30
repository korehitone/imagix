import 'dart:io';

class PostRequest {
  final String title;
  final String description;
  final File? imageFile;

  const PostRequest({
    required this.title,
    required this.description,
    this.imageFile,
  });
}
