// DailyCart - Format Utilities
import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  static final _currencyFmt = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20b9',
    decimalDigits: 2,
  );
  static final _currencyCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20b9',
    decimalDigits: 0,
  );
  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _dateTimeFmt = DateFormat('dd MMM yyyy, hh:mm a');
  static final _monthYearFmt = DateFormat('MMMM yyyy');

  static String formatCurrency(double amount) => _currencyFmt.format(amount);
  static String formatCurrencyCompact(double amount) =>
      _currencyCompact.format(amount);
  static String formatDate(DateTime date) => _dateFmt.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFmt.format(date);
  static String formatMonthYear(DateTime date) => _monthYearFmt.format(date);

  static String formatQuantity(double qty) {
    if (qty == qty.truncateToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
  }
}
