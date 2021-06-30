bool teksNyaKosong(str) =>
    (new RegExp("^\s+\$", multiLine: true, caseSensitive: false)).hasMatch(str);

String timeAgoSinceDate(DateTime date, {bool numericDates = true}) {
  final date2 = DateTime.now();
  final difference = date2.difference(date);

  if ((difference.inDays / 365).floor() >= 2) {
    return '${(difference.inDays / 365).floor()} tahun lalu';
  } else if ((difference.inDays / 365).floor() >= 1) {
    return (numericDates) ? '1 tahun lalu' : 'Akhir tahun';
  } else if ((difference.inDays / 30).floor() >= 2) {
    return '${(difference.inDays / 365).floor()} bulan lalu';
  } else if ((difference.inDays / 30).floor() >= 1) {
    return (numericDates) ? '1 bulan lalu' : 'Akhir bulan';
  } else if ((difference.inDays / 7).floor() >= 2) {
    return '${(difference.inDays / 7).floor()} minggu lalu';
  } else if ((difference.inDays / 7).floor() >= 1) {
    return (numericDates) ? '1 minggu lalu' : 'Akhir minggu';
  } else if (difference.inDays >= 2) {
    return '${difference.inDays} hari lalu';
  } else if (difference.inDays >= 1) {
    return (numericDates) ? '1 hari lalu' : 'Kemarin';
  } else if (difference.inHours >= 2) {
    return '${difference.inHours} jam lalu';
  } else if (difference.inHours >= 1) {
    return (numericDates) ? '1 jam lalu' : 'Sejam lalu';
  } else if (difference.inMinutes >= 2) {
    return '${difference.inMinutes} menit lalu';
  } else if (difference.inMinutes >= 1) {
    return (numericDates) ? '1 menit lalu' : 'A menit lalu';
  } else if (difference.inSeconds >= 3) {
    return '${difference.inSeconds} detik lalu';
  } else {
    return 'Baru saja';
  }
}
