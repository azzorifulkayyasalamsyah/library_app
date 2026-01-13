import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  /// Simpan data (Map / List) ke SharedPreferences
  static Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(value);
    await prefs.setString(key, jsonString);
  }

  /// Ambil data dari SharedPreferences
  static Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();

    // Read generically using `get`, which avoids casting issues when the stored
    // value is a List<String> (legacy) or a String.
    final raw = prefs.get(key);
    if (raw == null) return null;

    if (raw is String) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        return raw;
      }
    }

    if (raw is List<String>) {
      // Try to parse each element as JSON; otherwise return the string list.
      return raw.map((item) {
        try {
          return jsonDecode(item);
        } catch (_) {
          return item;
        }
      }).toList();
    }

    // Otherwise return as-is (number, bool, etc.)
    return raw;
  }

  /// Hapus data tertentu
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Hapus semua data (opsional, untuk debug)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
