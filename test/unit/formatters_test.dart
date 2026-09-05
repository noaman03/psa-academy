import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/core/utils/formatters.dart';

void main() {
  group('AppFormatters', () {
    test('formats standard currency correctly', () {
      expect(AppFormatters.formatCurrency(1500), contains('1,500'));
      expect(AppFormatters.formatCurrency(0), contains('0'));
    });

    test('formats compact currency for thousands', () {
      expect(AppFormatters.formatCompactCurrency(1500), contains('1.5K'));
      expect(AppFormatters.formatCompactCurrency(500), contains('500'));
    });

    test('formats dates correctly', () {
      final date = DateTime(2026, 9, 5);
      expect(AppFormatters.formatDate(date), equals('05 Sep 2026'));
      expect(AppFormatters.formatDateShort(date), equals('05/09/2026'));
    });

    test('formats phone numbers cleanly', () {
      expect(AppFormatters.formatPhone('01012345678'), equals('+20 1012345678'));
      expect(AppFormatters.formatPhone('+201012345678'), equals('+201012345678'));
    });
  });
}
