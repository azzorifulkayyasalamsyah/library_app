import 'dart:convert';
import 'package:crypto/crypto.dart';

class SimpleCrypto {
  /// Hash string menggunakan SHA-256
  /// Digunakan untuk password
  static String hash(String value) {
    final bytes = utf8.encode(value);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifikasi password (opsional, tapi rapi)
  static bool verify({
    required String plainText,
    required String hashedValue,
  }) {
    return hash(plainText) == hashedValue;
  }
}
