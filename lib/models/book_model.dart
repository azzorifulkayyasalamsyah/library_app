class Book {
  final String id;
  String title;
  String author;
  String pdfPath;
  int stock; // mutable karena berubah saat pinjam / return

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.pdfPath,
    this.stock = 3,
  });

  /// Konversi ke JSON (untuk SharedPreferences)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'pdfPath': pdfPath,
        'stock': stock,
      };

  /// Ambil dari JSON (aman untuk data lama)
  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'],
        title: json['title'],
        author: json['author'],
        pdfPath: json['pdfPath'],
        stock: json['stock'] ?? 3,
      );
}
