import 'dart:io';

class ProfileRequest {
  final String username;
  final String bio;
  final File? photo;

  const ProfileRequest({required this.username, required this.bio, this.photo});
}
