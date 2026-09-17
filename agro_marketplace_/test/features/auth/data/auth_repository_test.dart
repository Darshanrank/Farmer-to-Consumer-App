import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:agro_marketplace/features/auth/data/auth_repository.dart';
import 'package:agro_marketplace/core/logging/app_logger.dart';
import 'package:agro_marketplace/app/config/environment.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  setUpAll(() {
    AppLogger.initialize(EnvironmentConfig.development);
  });

  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late AuthRepository authRepository;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    authRepository = AuthRepository(mockAuth);
  });

  group('AuthRepository', () {
    test('signInWithEmailAndPassword returns success on valid credentials', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      
      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await authRepository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, equals(mockUser));
    });

    test('signInWithEmailAndPassword returns failure on FirebaseAuthException', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrong_password',
      )).thenThrow(FirebaseAuthException(code: 'wrong_password'));

      final result = await authRepository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrong_password',
      );

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull?.code, equals('wrong_password'));
    });

    test('signOut calls FirebaseAuth.signOut', () async {
      when(mockAuth.signOut()).thenAnswer((_) async {});

      final result = await authRepository.signOut();

      expect(result.isSuccess, isTrue);
      verify(mockAuth.signOut()).called(1);
    });
  });
}
