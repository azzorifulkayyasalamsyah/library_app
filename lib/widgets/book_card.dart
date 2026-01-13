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
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Cover image (try asset image, fallback to icon)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 96,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/${book.id}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Judul (uppercase untuk tampilan seperti mockup)
            Text(
              book.title.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            // Penulis
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const Spacer(),

            // Stok
            Text(
              'Stok: ${book.stock}',
              style: TextStyle(
                color: book.stock > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Tombol aksi (rapi, ukuran seragam)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
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
                      backgroundColor: const Color(0xFF6A2CBC),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Pinjam'),
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  width: 44,
                  height: 44,
                  child: OutlinedButton(
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
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.menu_book_outlined),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
