import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Identitas user tanpa login. Disimpan di SharedPreferences.
class Session {
  static String userId = '';
  static String userName = '';

  /// Id room yang sedang dibuka (null = sedang tidak di halaman chat).
  /// Dipakai popup pesan baru supaya tidak muncul untuk room yang sedang dibuka.
  static String? openRoomId;

  /// Baca nama & id tersimpan. Return nama (atau null kalau belum pernah isi).
  static Future<String?> loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    final name = prefs.getString('userName');
    if (name != null) userName = name;
    return name;
  }

  /// Simpan nama. userId dibuat sekali saja dan tidak berubah.
  static Future<void> save(String name) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId.isEmpty) {
      userId = '${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(9999)}';
    }
    userName = name;
    await prefs.setString('userId', userId);
    await prefs.setString('userName', userName);
  }
}
