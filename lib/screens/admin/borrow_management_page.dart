import 'package:flutter/material.dart';

import '../../models/borrow_model.dart';
import '../../models/book_model.dart';
import '../../services/borrow_service.dart';
import '../../services/book_service.dart';
import '../../utils/date_helper.dart';
import '../../core/constants/app_colors.dart';

class BorrowManagementPage extends StatefulWidget {
  const BorrowManagementPage({super.key});

  @override
  State<BorrowManagementPage> createState() => _BorrowManagementPageState();
}

class _BorrowManagementPageState extends State<BorrowManagementPage> {
  List<Borrow> _borrows = [];
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await BorrowService.autoReturn();
    final borrows = await BorrowService.getAllBorrows();
    final books = await BookService.getBooks();

    setState(() {
      _borrows = borrows;
      _books = books;
    });
  }

  Book? _findBook(String bookId) {
    try {
      return _books.firstWhere((b) => b.id == bookId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Peminjaman'),
        centerTitle: true,
      ),
      body: _borrows.isEmpty
          ? const Center(child: Text('Belum ada peminjaman'))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                itemCount: _borrows.length,
                itemBuilder: (context, index) {
                  final borrow = _borrows[index];
                  final book = _findBook(borrow.bookId);

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(book?.title ?? 'Buku tidak ditemukan'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${borrow.userId}'),
                          Text(
                            'Pinjam: ${DateHelper.format(borrow.borrowDate)}',
                          ),
                          Text(
                            'Jatuh Tempo: ${DateHelper.format(borrow.dueDate)}',
                          ),
                          Text(
                            'Status: ${DateHelper.borrowStatus(
                              borrow.dueDate,
                              borrow.status,
                            )}',
                            style: TextStyle(
                              color: borrow.status == 'dikembalikan'
                                  ? AppColors.success
                                  : DateHelper.isExpired(borrow.dueDate)
                                      ? AppColors.error
                                      : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      trailing: borrow.status == 'dipinjam'
                          ? IconButton(
                              icon: const Icon(
                                Icons.assignment_return,
                                color: AppColors.primary,
                              ),
                              onPressed: () async {
                                await BorrowService.returnBook(borrow.id);
                                await _loadData();
                              },
                            )
                          : const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
