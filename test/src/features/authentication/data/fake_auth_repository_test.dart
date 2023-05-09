@Timeout(Duration(milliseconds: 500))

import 'package:ecommerce_app/src/features/authentication/data/fake_auth_repository.dart';
import 'package:ecommerce_app/src/features/authentication/domain/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testEmail = 'carlos@hotmail.com';
  const testPassword = "123456";
  final testUser =
      AppUser(email: testEmail, uid: testEmail.split('').reversed.join());

  FakeAuthRepository makeAuthRepository() => FakeAuthRepository(
        addDelay: false,
      );

  group('FakeAuthRepository', () {
    test("currenctUser is null", () {
      final authRepository = makeAuthRepository();
      addTearDown(authRepository.dispose);
      expect(authRepository.currentUser, null);
      expect(authRepository.authStateChanges(), emits(null));
    });

    test('currentUser is not null after sign in', () async {
      final authRepository = makeAuthRepository();
      addTearDown(authRepository.dispose);

      await authRepository.signinwithEmailAndPassord(testEmail, testPassword);
      expect(authRepository.currentUser, testUser);
      expect(authRepository.authStateChanges(), emits(testUser));
    });

    test('currentUser is not null after registration', () async {
      final authRepository = makeAuthRepository();
      addTearDown(authRepository.dispose);

      await authRepository.createuserWithEmailAndPassword(
          testEmail, testPassword);
      expect(authRepository.currentUser, testUser);
      expect(authRepository.authStateChanges(), emits(testUser));
    });

    test('currentUser is null after sign out', () async {
      final authRepository = makeAuthRepository();
      addTearDown(authRepository.dispose);

      await authRepository.signinwithEmailAndPassord(testEmail, testPassword);
      expect(
        authRepository.authStateChanges(),
        emitsInOrder([
          testUser,
          null,
        ]),
      );
      expect(authRepository.currentUser, testUser);
      expect(authRepository.authStateChanges(), emits(testUser));

      await authRepository.signOut();
      expect(authRepository.currentUser, null);
      expect(authRepository.authStateChanges(), emits(null));
    });

    test("sign in after dispose throws expecption", () {
      final authRepository = makeAuthRepository();
      addTearDown(authRepository.dispose);

      authRepository.dispose();

      expect(
        () => authRepository.signinwithEmailAndPassord(testEmail, testPassword),
        throwsStateError,
      );
    });
  });
}
