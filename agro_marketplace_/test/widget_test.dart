import 'package:flutter_test/flutter_test.dart';

import 'package:agro_marketplace/core/result/result.dart';
import 'package:agro_marketplace/core/errors/app_exception.dart';
import 'package:agro_marketplace/core/validation/validators.dart';

void main() {
  group('Result', () {
    test('Success contains data', () {
      const result = Result<int>.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, equals(42));
    });

    test('Failure contains exception', () {
      const result = Result<int>.failure(
        NetworkException(),
      );
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.exceptionOrNull, isA<NetworkException>());
    });

    test('when() dispatches correctly', () {
      const success = Result<String>.success('hello');
      final message = success.when(
        success: (data) => 'Got: $data',
        failure: (e) => 'Error: ${e.message}',
      );
      expect(message, equals('Got: hello'));
    });

    test('map() transforms success data', () {
      const result = Result<int>.success(10);
      final mapped = result.map((data) => data * 2);
      expect(mapped.dataOrNull, equals(20));
    });
  });

  group('Validators', () {
    test('email validates correctly', () {
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('invalid'), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('phone validates Indian numbers', () {
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.phone('1234567890'), isNotNull); // Starts with 1
      expect(Validators.phone('98765'), isNotNull); // Too short
    });

    test('pincode validates 6-digit codes', () {
      expect(Validators.pincode('382001'), isNull);
      expect(Validators.pincode('12345'), isNotNull); // Too short
      expect(Validators.pincode('abcdef'), isNotNull);
    });

    test('password validates strength', () {
      expect(Validators.password('Abcd1234'), isNull);
      expect(Validators.password('weak'), isNotNull);
      expect(Validators.password('alllowercase1'), isNotNull); // No uppercase
    });

    test('required validates non-empty', () {
      expect(Validators.required('hello'), isNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required(null), isNotNull);
      expect(Validators.required('   '), isNotNull); // Only whitespace
    });
  });
}
