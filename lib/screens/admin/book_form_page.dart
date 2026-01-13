import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../core/constants/app_colors.dart';

class BookFormPage extends StatefulWidget {
  final Book? book; // null = tambah, ada = edit

  const BookFormPage({super.key, this.book});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _pdfPathController;

  @override
  void initState() {
    super.initState();

    _titleController =
        TextEditingController(text: widget.book?.title ?? '');
    _authorController =
        TextEditingController(text: widget.book?.author ?? '');
    _pdfPathController =
        TextEditingController(text: widget.book?.pdfPath ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pdfPathController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.book == null) {
      // TAMBAH BUKU
      final newBook = Book(
        id: const Uuid().v4(),
        title: _titleController.text,
        author: _authorController.text,
        pdfPath: _pdfPathController.text,
        stock: 3,
      );
      await BookService.addBook(newBook);
    } else {
      // EDIT BUKU
      widget.book!
        ..title = _titleController.text
        ..author = _authorController.text
        ..pdfPath = _pdfPathController.text;

      await BookService.updateBook(widget.book!);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.book != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Buku' : 'Tambah Buku'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // JUDUL
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Buku',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              // PENULIS
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Penulis',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              // PATH PDF
              TextFormField(
                controller: _pdfPathController,
                decoration: const InputDecoration(
                  labelText: 'Path PDF (assets/pdf/...)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 24),

              // BUTTON SIMPAN
              ElevatedButton(
                onPressed: _saveBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH BUKU',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
