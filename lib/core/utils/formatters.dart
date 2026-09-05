import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'EGP ',
    decimalDigits: 2,
  );

  static final NumberFormat _currencyFormatWhole = NumberFormat.currency(
    symbol: 'EGP ',
    decimalDigits: 0,
  );

  static String formatCurrency(num amount, {bool showDecimals = false}) {
    if (showDecimals) {
      return _currencyFormat.format(amount);
    }
    return _currencyFormatWhole.format(amount);
  }

  static String formatCompactCurrency(num amount) {
    if (amount >= 1000) {
      final k = amount / 1000;
      final kStr = k % 1 == 0 ? k.toInt().toString() : k.toStringAsFixed(1);
      return 'EGP ${kStr}K';
    }
    return 'EGP ${amount.toInt()}';
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  static String formatDateShort(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('0')) {
      return '+20 ${cleaned.substring(1)}';
    }
    return cleaned;
  }
}
