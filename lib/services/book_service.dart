import 'package:uuid/uuid.dart';
import '../core/storage/local_storage.dart';
import '../models/book_model.dart';

class BookService {
  static const _key = 'books';

  static Future<List<Book>> getBooks() async {
    final data = await LocalStorage.read(_key);
    if (data == null) return [];
    return (data as List).map((e) => Book.fromJson(e)).toList();
  }

  static Future<void> addBook(Book book) async {
    final books = await getBooks();
    books.add(book);
    await _save(books);
  }

  static Future<void> updateBook(Book book) async {
    final books = await getBooks();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      books[index] = book;
      await _save(books);
    }
  }

  static Future<void> deleteBook(String id) async {
    final books = await getBooks();
    books.removeWhere((b) => b.id == id);
    await _save(books);
  }

  static Future<void> _save(List<Book> books) async {
    await LocalStorage.save(_key, books.map((b) => b.toJson()).toList());
  }

  static Book create({
    required String title,
    required String author,
    required String pdfPath,
  }) {
    return Book(
      id: const Uuid().v4(),
      title: title,
      author: author,
      pdfPath: pdfPath,
      stock: 3,
    );
  }
}
