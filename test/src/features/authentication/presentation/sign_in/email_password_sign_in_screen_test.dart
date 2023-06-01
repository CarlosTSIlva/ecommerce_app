import 'package:ecommerce_app/src/features/authentication/presentation/sign_in/email_password_sign_in_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';
import '../../auth_robot.dart';

void main() {
  const testeEmail = "carlosteixeira.tc@hotmail.com";
  const testPassword = "1234";

  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
  });

  group("sign in", () {
    testWidgets('''
    Given formType is signIn
    When user taps on the sign-in in button
    Then signInWithEmailAndPassword is not called
    ''', (tester) async {
      final r = AuthRobot(tester);
      await r.pumpEmailPasswordSignInContents(
        authRepository: authRepository,
        formType: EmailPasswordSignInFormType.signIn,
      );
      await r.tapEmailAndPasswordSubmitButton();
      verifyNever(() => authRepository.signinwithEmailAndPassord(any(), any()));
    });

    testWidgets('''
    Given formType is signIn
    When enter valid email and password
    And tap on the sign-in button
    Then signInWithEmailAndPassword is called
    And onSignedIn callback is called
    And error alert is not shown
    ''', (tester) async {
      var didSignIn = false;
      final r = AuthRobot(tester);
      when(() => authRepository.signinwithEmailAndPassord(
          testeEmail, testPassword)).thenAnswer((_) => Future.value());
      await r.pumpEmailPasswordSignInContents(
        authRepository: authRepository,
        formType: EmailPasswordSignInFormType.signIn,
        onSignedIn: () => didSignIn = true,
      );

      await r.enterEmail(testeEmail);
      await r.enterPassword(testPassword);

      await r.tapEmailAndPasswordSubmitButton();
      verify(
        () =>
            authRepository.signinwithEmailAndPassord(testeEmail, testPassword),
      ).called(1);

      r.expectErrorAlertNotFound();
      expect(didSignIn, true);
    });
  });
}
