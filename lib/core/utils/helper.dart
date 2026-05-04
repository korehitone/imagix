import 'package:flutter/material.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

extension NameValidator on String {
  bool isValidUsername() {
    return RegExp(r'^[A-Za-z0-9._]+$').hasMatch(this);
  }
}

extension BuildContextX on BuildContext {
  void showMsg(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
