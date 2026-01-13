class Borrow {
  final String id;
  final String bookId;
  final String userId;
  final DateTime borrowDate;
  final DateTime dueDate;
  String status; // dipinjam / dikembalikan

  Borrow({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.borrowDate,
    required this.dueDate,
    this.status = 'dipinjam',
  });

  /// Konversi ke JSON (SharedPreferences)
  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'userId': userId,
        'borrowDate': borrowDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'status': status,
      };

  /// Ambil dari JSON
  factory Borrow.fromJson(Map<String, dynamic> json) => Borrow(
        id: json['id'],
        bookId: json['bookId'],
        userId: json['userId'],
        borrowDate: DateTime.parse(json['borrowDate']),
        dueDate: DateTime.parse(json['dueDate']),
        status: json['status'] ?? 'dipinjam',
      );
}
