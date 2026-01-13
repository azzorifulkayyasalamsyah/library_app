class DateHelper {
  /// Tanggal sekarang (tanpa jam, menit, detik)
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Hitung tanggal jatuh tempo (default 3 hari)
  static DateTime dueDate({int days = 3}) {
    return DateTime.now().add(Duration(days: days));
  }

  /// Cek apakah sudah lewat jatuh tempo
  static bool isExpired(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  /// Hitung sisa hari peminjaman
  static int remainingDays(DateTime dueDate) {
    final diff = dueDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Format tanggal untuk UI (dd/MM/yyyy)
  static String format(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  /// Status peminjaman berbasis waktu
  static String borrowStatus(DateTime dueDate, String status) {
    if (status == 'dikembalikan') {
      return 'Dikembalikan';
    }

    if (isExpired(dueDate)) {
      return 'Kadaluarsa';
    }

    return 'Dipinjam';
  }
}
