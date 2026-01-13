import 'package:flutter/material.dart';

import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../core/constants/app_colors.dart';
import 'book_form_page.dart';

class ManageBookPage extends StatefulWidget {
  const ManageBookPage({super.key});

  @override
  State<ManageBookPage> createState() => _ManageBookPageState();
}

class _ManageBookPageState extends State<ManageBookPage> {
  List<Book> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await BookService.getBooks();
    setState(() {
      _books = books;
      _loading = false;
    });
  }

  Future<void> _deleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Buku'),
        content: Text('Yakin hapus "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await BookService.deleteBook(book.id);
    await _loadBooks();
  }

  Future<void> _openForm({Book? book}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookFormPage(book: book),
      ),
    );

    if (result == true) {
      await _loadBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Buku'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),

      // ➕ BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? const Center(child: Text('Belum ada buku'))
              : RefreshIndicator(
                  onRefresh: _loadBooks,
                  child: ListView.builder(
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.pdfIcon,
                          ),
                          title: Text(book.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Penulis: ${book.author}'),
                              Text('Stok: ${book.stock}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ✏️ EDIT
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppColors.warning,
                                ),
                                onPressed: () => _openForm(book: book),
                              ),

                              // 🗑️ DELETE
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                ),
                                onPressed: () => _deleteBook(book),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
