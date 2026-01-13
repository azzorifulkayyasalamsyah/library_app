import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/borrow_service.dart';
import '../screens/customer/pdf_reader_page.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final String userId;
  final VoidCallback? onBorrow;

  const BookCard({
    super.key,
    required this.book,
    required this.userId,
    this.onBorrow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon PDF
            const Center(
              child: Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
            ),

            const SizedBox(height: 8),

            // Judul
            Text(
              book.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            // Penulis
            Text(book.author, style: const TextStyle(fontSize: 13)),

            const SizedBox(height: 6),

            // Stok
            Text(
              'Stok tersedia: ${book.stock}',
              style: TextStyle(
                color: book.stock > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            // Tombol aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // PINJAM
                ElevatedButton(
                  onPressed: book.stock == 0
                      ? null
                      : () async {
                          final success = await BorrowService.borrowBook(
                            bookId: book.id,
                            userId: userId,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Buku berhasil dipinjam'
                                    : 'Stok habis',
                              ),
                            ),
                          );

                          if (success && onBorrow != null) onBorrow!();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text('Pinjam'),
                ),

                // BACA PDF
                OutlinedButton(
                  onPressed: () async {
                    final allowed = await BorrowService.canRead(
                      bookId: book.id,
                      userId: userId,
                    );

                    if (!allowed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Anda belum meminjam buku ini'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfReaderPage(book: book),
                      ),
                    );
                  },
                  child: const Text('Baca'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
