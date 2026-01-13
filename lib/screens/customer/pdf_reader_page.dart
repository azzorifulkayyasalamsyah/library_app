import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../models/book_model.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class PdfReaderPage extends StatelessWidget {
  final Book book;

  const PdfReaderPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    // If path looks like an asset (assets/...)
    if (book.pdfPath.startsWith('assets/')) {
      return FutureBuilder<bool>(
        future: _assetExists(book.pdfPath),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasData && snap.data == true) {
            return SfPdfViewer.asset(book.pdfPath);
          }

          return Center(
            child: Text('Asset PDF tidak ditemukan: ${book.pdfPath}'),
          );
        },
      );
    }

    // Otherwise treat as file path
    return FutureBuilder<bool>(
      future: File(book.pdfPath).exists(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasData && snap.data == true) {
          return SfPdfViewer.file(File(book.pdfPath));
        }

        return Center(child: Text('File PDF tidak ditemukan: ${book.pdfPath}'));
      },
    );
  }

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
