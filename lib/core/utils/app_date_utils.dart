// DailyCart - Date Utilities
class AppDateUtils {
  AppDateUtils._();

  static String nowIso() => DateTime.now().toIso8601String();
  static DateTime parseIso(String iso) => DateTime.parse(iso).toLocal();

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static DateTime startOfMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  static String relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${(diff.inDays / 30).floor()} months ago';
  }
}
