import 'package:uuid/uuid.dart';
import '../core/crypto/simple_crypto.dart';
import '../core/storage/local_storage.dart';
import '../models/user_model.dart';

class AuthService {
  static const _userKey = 'users';
  static const _sessionKey = 'session';

  /// Inisialisasi user default (sekali saja)
  static Future<void> initUsers() async {
    final data = await LocalStorage.read(_userKey);
    if (data != null) return;

    final users = [
      User(
        id: const Uuid().v4(),
        username: 'admin',
        password: SimpleCrypto.hash('admin123'),
        role: 'admin',
      ),
      User(
        id: const Uuid().v4(),
        username: 'customer',
        password: SimpleCrypto.hash('customer123'),
        role: 'customer',
      ),
    ];

    await LocalStorage.save(_userKey, users.map((u) => u.toJson()).toList());
  }

  /// Login
  static Future<User?> login(String username, String password) async {
    final data = await LocalStorage.read(_userKey);
    if (data == null) return null;

    final users = (data as List).map((e) => User.fromJson(e)).toList();
    final hash = SimpleCrypto.hash(password);

    try {
      final user = users.firstWhere(
        (u) => u.username == username && u.password == hash,
      );

      await LocalStorage.save(_sessionKey, user.toJson());
      return user;
    } catch (_) {
      return null;
    }
  }

  /// Ambil session
  static Future<User?> session() async {
    final data = await LocalStorage.read(_sessionKey);
    return data == null ? null : User.fromJson(data);
  }

  /// Logout
  static Future<void> logout() async {
    await LocalStorage.remove(_sessionKey);
  }

  /// Register customer
  static Future<User?> register(String username, String password) async {
    final data = await LocalStorage.read(_userKey);
    final users = data == null
        ? <User>[]
        : (data as List).map((e) => User.fromJson(e)).toList();

    // Cek apakah username sudah ada
    final exists = users.any((u) => u.username == username);
    if (exists) return null;

    final newUser = User(
      id: const Uuid().v4(),
      username: username,
      password: SimpleCrypto.hash(password),
      role: 'customer',
    );

    users.add(newUser);
    await LocalStorage.save(_userKey, users.map((u) => u.toJson()).toList());

    // Set session
    await LocalStorage.save(_sessionKey, newUser.toJson());
    return newUser;
  }
}
