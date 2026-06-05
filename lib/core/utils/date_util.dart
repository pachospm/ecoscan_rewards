import 'package:intl/intl.dart';

class DateUtil {
  DateUtil._();

  // Formato largo de fecha "15 abr 2026"
  static String formatDate(DateTime date){
    return DateFormat('dd MM yyyy', 'es').format(date);
  }

  //Formato con hora: "15 abr 2026 * 18:30"
  static String formatDateTime(DateTime date){
    return DateFormat('dd MM yyyy HH:mm', 'es').format(date);
  }

  // Formato relativo: "hace 3 min" "hace 2 días"
  static String formatRelative(DateTime date){
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'hace un momento';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays <= 7) return 'hace ${diff.inDays} días';

    return formatDate(date);
  }

  static String toIso(DateTime date) => date.toIso8601String();
  static DateTime formIso(String iso) => DateTime.parse(iso);
}