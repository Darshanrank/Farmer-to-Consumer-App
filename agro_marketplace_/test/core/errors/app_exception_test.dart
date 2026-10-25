import 'package:flutter_test/flutter_test.dart';

import 'package:agro_marketplace/core/errors/app_exception.dart';

void main() {
  group('AppException metadata', () {
    test('classifies network errors as retryable', () {
      const exception = NetworkException();

      expect(exception.category, ExceptionCategory.network);
      expect(exception.isRetryable, isTrue);
    });

    test('classifies validation errors as non-retryable', () {
      const exception = ValidationException(message: 'Invalid quantity.');

      expect(exception.category, ExceptionCategory.validation);
      expect(exception.isRetryable, isFalse);
    });

    test('classifies conflicts as retryable', () {
      const exception = ConflictException();

      expect(exception.category, ExceptionCategory.conflict);
      expect(exception.isRetryable, isTrue);
    });

    test('classifies unknown errors as non-retryable', () {
      const exception = UnknownException();

      expect(exception.category, ExceptionCategory.unknown);
      expect(exception.isRetryable, isFalse);
    });
  });
}
