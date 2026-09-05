import 'package:flutter_test/flutter_test.dart';
import 'package:psa_academy/core/state/view_state.dart';

void main() {
  group('ViewState', () {
    test('initial state has correct flags', () {
      const state = ViewState<String>.initial();
      expect(state.isInitial, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.isSuccess, isFalse);
      expect(state.data, isNull);
    });

    test('loading state has correct flags', () {
      const state = ViewState<String>.loading();
      expect(state.isLoading, isTrue);
      expect(state.isSuccess, isFalse);
    });

    test('success state contains data', () {
      const state = ViewState<String>.success('Hello PSA');
      expect(state.isSuccess, isTrue);
      expect(state.data, equals('Hello PSA'));
    });

    test('failure state contains error message', () {
      const state = ViewState<String>.failure('Network timeout');
      expect(state.isFailure, isTrue);
      expect(state.errorMessage, equals('Network timeout'));
    });
  });
}
