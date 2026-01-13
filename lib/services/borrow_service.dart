import 'package:uuid/uuid.dart';
import '../core/storage/local_storage.dart';
import '../models/borrow_model.dart';
import '../services/book_service.dart';

class BorrowService {
  static const _key = 'borrows';

  /// Ambil semua data peminjaman
  static Future<List<Borrow>> getAll() async {
    final data = await LocalStorage.read(_key);
    if (data == null) return [];
    return (data as List).map((e) => Borrow.fromJson(e)).toList();
  }

  /// Simpan
  static Future<void> _save(List<Borrow> borrows) async {
    await LocalStorage.save(_key, borrows.map((e) => e.toJson()).toList());
  }

  /// Pinjam buku
  static Future<bool> borrowBook({
    required String bookId,
    required String userId,
  }) async {
    final books = await BookService.getBooks();
    try {
      final book = books.firstWhere((b) => b.id == bookId);

      if (book.stock <= 0) return false;

      book.stock -= 1;
      await BookService.updateBook(book);

      final borrows = await getAll();
      borrows.add(
        Borrow(
          id: const Uuid().v4(),
          bookId: bookId,
          userId: userId,
          borrowDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      );

      await _save(borrows);
      return true;
    } catch (_) {
      // Book not found
      return false;
    }
  }

  /// Cek apakah user dapat membaca (sudah meminjam)
  static Future<bool> canRead({
    required String bookId,
    required String userId,
  }) async {
    final borrows = await getAll();
    try {
      borrows.firstWhere(
        (br) =>
            br.bookId == bookId &&
            br.userId == userId &&
            br.status == 'dipinjam',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Kembalikan buku manual
  static Future<void> returnBook(String borrowId) async {
    final borrows = await getAll();
    try {
      final borrow = borrows.firstWhere((b) => b.id == borrowId);

      if (borrow.status == 'dikembalikan') return;

      borrow.status = 'dikembalikan';

      final books = await BookService.getBooks();
      final book = books.firstWhere((b) => b.id == borrow.bookId);
      book.stock += 1;

      await BookService.updateBook(book);
      await _save(borrows);
    } catch (_) {
      // ignore if borrow/book not found
    }
  }

  /// AUTO RETURN
  static Future<void> autoReturn() async {
    final borrows = await getAll();
    bool updated = false;

    for (var borrow in borrows) {
      if (borrow.status == 'dipinjam' &&
          DateTime.now().isAfter(borrow.dueDate)) {
        borrow.status = 'dikembalikan';

        final books = await BookService.getBooks();
        try {
          final book = books.firstWhere((b) => b.id == borrow.bookId);
          book.stock += 1;
          await BookService.updateBook(book);
        } catch (_) {
          // ignore missing book
        }

        updated = true;
      }
    }

    if (updated) {
      await _save(borrows);
    }
  }

  /// History customer
  static Future<List<Borrow>> history(String userId) async {
    final borrows = await getAll();
    return borrows.where((b) => b.userId == userId).toList();
  }

  /// Backwards-compatible alias
  static Future<List<Borrow>> getAllBorrows() async => getAll();
}
