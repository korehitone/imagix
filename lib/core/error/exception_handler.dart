import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExceptionHandler {
  static String handle(dynamic e) {
    if (kDebugMode) {
      print("DEBUG_LOG | Type: ${e.runtimeType} | Detail: $e");
    }

    // 1. PostgrestException (Database/SQL/RLS)
    if (e is PostgrestException) {
      switch (e.code) {
        case 'PGRST116':
          return "The requested information could not be found.";
        case '23505':
          return "This data already exists.";
        case 'PGRST301':
          return "Session expired, please sign in again.";
        default:
          return "Something went wrong. Try again later";
      }
    }

    // 2. AuthException (Login/Register/Session)
    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        return "invalid email or password.";
      }
      if (msg.contains('email not confirmed')) {
        return "Please verify your email.";
      }
      if (msg.contains('too many requests')) {
        return "Too many attempts. Please try again later";
      }
      if (msg.contains('user already registered')) {
        return "This email is already registered.";
      }
      return e.message;
    }

    // 3. SocketException (Internet)
    if (e is SocketException) {
      return "No internet connection. Please check your network.";
    }

    // 4. Default Error
    return "An unexpected error occurred. Please try again.";
  }
}
