import 'package:flutter/material.dart';
import '../../services/borrow_service.dart';
import '../../models/borrow_model.dart';
import '../../services/auth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Borrow> history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.session();
    final id = user?.id ?? '';
    history = await BorrowService.history(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History Peminjaman')),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final h = history[index];
          return Card(
            child: ListTile(
              title: Text('ID Buku: ${h.bookId}'),
              subtitle: Text('Status: ${h.status}\nJatuh Tempo: ${h.dueDate}'),
              trailing: h.status == 'dipinjam'
                  ? ElevatedButton(
                      onPressed: () async {
                        await BorrowService.returnBook(h.id);
                        _load();
                      },
                      child: const Text('Kembalikan'),
                    )
                  : const Icon(Icons.check, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
