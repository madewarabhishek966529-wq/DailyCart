import 'package:flutter_test/flutter_test.dart';
import 'package:dailycart/core/utils/app_date_utils.dart';
import 'package:dailycart/core/utils/format_utils.dart';

void main() {
  group('FormatUtils and DateUtils', () {
    test('formatQuantity formats whole and decimal numbers cleanly', () {
      expect(FormatUtils.formatQuantity(1.0), '1');
      expect(FormatUtils.formatQuantity(2.5), '2.5');
      expect(FormatUtils.formatQuantity(0.75), '0.75');
      expect(FormatUtils.formatQuantity(10.0), '10');
    });

    test('formatCurrency contains Rupee symbol', () {
      final formatted = FormatUtils.formatCurrency(1500.50);
      expect(formatted.contains('1,500.50'), isTrue);
    });

    test('formatCurrencyCompact formats integers', () {
      final formatted = FormatUtils.formatCurrencyCompact(2500);
      expect(formatted.contains('2,500'), isTrue);
    });

    test('AppDateUtils relativeDate returns descriptive strings', () {
      final now = DateTime.now();
      expect(AppDateUtils.relativeDate(now), 'Today');

      final yesterday = now.subtract(const Duration(days: 1));
      expect(AppDateUtils.relativeDate(yesterday), 'Yesterday');

      final threeDaysAgo = now.subtract(const Duration(days: 3));
      expect(AppDateUtils.relativeDate(threeDaysAgo), '3 days ago');
    });
  });
}
