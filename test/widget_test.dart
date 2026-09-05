import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/core/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme loads lightTheme successfully', (tester) async {
    final theme = AppTheme.lightTheme;
    expect(theme.useMaterial3, isTrue);
  });
}
