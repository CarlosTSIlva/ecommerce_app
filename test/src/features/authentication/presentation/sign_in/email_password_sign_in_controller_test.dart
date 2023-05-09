@Timeout(Duration(milliseconds: 500))

import 'package:ecommerce_app/src/features/authentication/presentation/sign_in/email_password_sign_in_controller.dart';
import 'package:ecommerce_app/src/features/authentication/presentation/sign_in/email_password_sign_in_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  const testEmail = 'carlos@hotmail.com';
  const testPassword = "123456";

  group('submit', () {
    test(
      '''
    Given formType in signIn
    When sigInWithEmailAndPassword succeeds
    Then return true
    And state  is AsyncData
    ''',
      () async {
        final authRepository = MockAuthRepository();
        when(() => authRepository.signinwithEmailAndPassord(
              testEmail,
              testPassword,
            )).thenAnswer((_) => Future.value());

        final controller = EmailPasswordSignInController(
          formType: EmailPasswordSignInFormType.signIn,
          authRepository: authRepository,
        );

        expectLater(
            controller.stream,
            emitsInOrder([
              EmailPasswordSignInState(
                formType: EmailPasswordSignInFormType.signIn,
                value: const AsyncLoading<void>(),
              ),
              EmailPasswordSignInState(
                formType: EmailPasswordSignInFormType.signIn,
                value: const AsyncData<void>(null),
              ),
            ]));

        final result = await controller.submit(
          testEmail,
          testPassword,
        );

        expect(result, true);
      },
    );

    test(
      '''
    Given formType in signIn
    When sigInWithEmailAndPassword fails
    Then return false
    And state  is AsyncError
    ''',
      () async {
        final authRepository = MockAuthRepository();
        final exception = Exception('Connection failed');

        when(() => authRepository.signinwithEmailAndPassord(
              testEmail,
              testPassword,
            )).thenThrow(exception);

        final controller = EmailPasswordSignInController(
          formType: EmailPasswordSignInFormType.signIn,
          authRepository: authRepository,
        );

        expectLater(
            controller.stream,
            emitsInOrder([
              EmailPasswordSignInState(
                formType: EmailPasswordSignInFormType.signIn,
                value: const AsyncLoading<void>(),
              ),
              predicate<EmailPasswordSignInState>((state) {
                expect(state.formType, EmailPasswordSignInFormType.signIn);
                expect(state.value.hasError, true);
                return true;
              }),
            ]));

        final result = await controller.submit(
          testEmail,
          testPassword,
        );

        expect(result, false);
      },
    );

    test(
      '''
    Given formType in register
    When createuserWithEmailAndPassword succeeds
    Then return true
    And state  is AsyncData
    ''',
      () async {
        final authRepository = MockAuthRepository();
        when(() => authRepository.createuserWithEmailAndPassword(
              testEmail,
              testPassword,
            )).thenAnswer((_) => Future.value());

        final controller = EmailPasswordSignInController(
          formType: EmailPasswordSignInFormType.register,
          authRepository: authRepository,
        );

        expectLater(
            controller.stream,
            emitsInOrder([
              EmailPasswordSignInState(
                formType: EmailPasswordSignInFormType.register,
                value: const AsyncLoading<void>(),
              ),
              EmailPasswordSignInState(
                formType: EmailPasswordSignInFormType.register,
                value: const AsyncData<void>(null),
              ),
            ]));

        final result = await controller.submit(
          testEmail,
          testPassword,
        );

        expect(result, true);
      },
    );

    test(
      '''
    Given formType in register
    When createuserWithEmailAndPassword fails
    Then return false
    And state  is AsyncError
    ''',
      () async {
        final authRepository = MockAuthRepository();
        final exception = Exception('Connection failed');

        when(() => authRepository.createuserWithEmailAndPassword(
              testEmail,
              testPassword,
            )).thenThrow(exception);

        final controller = EmailPasswordSignInController(
          formType: EmailPasswordSignInFormType.register,
          authRepository: authRepository,
        );

        expectLater(
            controller.stream,
            emitsInOrder([
              EmailPasswordSignInState(
                formType: EmailPasswordSignInFormType.register,
                value: const AsyncLoading<void>(),
              ),
              predicate<EmailPasswordSignInState>((state) {
                expect(state.formType, EmailPasswordSignInFormType.register);
                expect(state.value.hasError, true);
                return true;
              }),
            ]));

        final result = await controller.submit(
          testEmail,
          testPassword,
        );

        expect(result, false);
      },
    );
  });

  group('updateFormType', () {
    test('''
    Given formType is signIn
    When called with register
    Then state.formTytpe is register
    ''', () {
      final authRepository = MockAuthRepository();
      final controller = EmailPasswordSignInController(
        formType: EmailPasswordSignInFormType.signIn,
        authRepository: authRepository,
      );

      controller.updateTypeForm(EmailPasswordSignInFormType.register);

      expect(
        controller.debugState,
        EmailPasswordSignInState(
          formType: EmailPasswordSignInFormType.register,
          value: const AsyncData<void>(null),
        ),
      );
    });

    test('''
    Given formType is register
    When called with signIn
    Then state.formTytpe is signIn
    ''', () {
      final authRepository = MockAuthRepository();
      final controller = EmailPasswordSignInController(
        formType: EmailPasswordSignInFormType.register,
        authRepository: authRepository,
      );

      controller.updateTypeForm(EmailPasswordSignInFormType.signIn);

      expect(
        controller.debugState,
        EmailPasswordSignInState(
          formType: EmailPasswordSignInFormType.signIn,
          value: const AsyncData<void>(null),
        ),
      );
    });
  });
}
