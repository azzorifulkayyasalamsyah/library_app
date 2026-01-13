class User {
  final String id;
  final String username;
  final String password; // sudah di-hash (SHA-256)
  final String role; // admin / customer

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  /// Konversi ke JSON (SharedPreferences)
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'role': role,
      };

  /// Ambil dari JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        role: json['role'],
      );
}
