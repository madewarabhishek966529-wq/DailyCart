// DailyCart - String Extensions
extension StringExtensions on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool containsIgnoreCase(String query) =>
      toLowerCase().contains(query.toLowerCase());

  String? get trimmedOrNull {
    final t = trim();
    return t.isEmpty ? null : t;
  }
}
