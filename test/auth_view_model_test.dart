import 'package:flutter_test/flutter_test.dart';
import 'package:proyec/core/errors/app_exception.dart';
import 'package:proyec/ui/features/auth/view_models/auth_view_model.dart';

import 'fakes/fake_auth_repository.dart';

void main() {
  test('register creates an authenticated user profile', () async {
    final repository = FakeAuthRepository();
    final viewModel = AuthViewModel(authRepository: repository);

    final user = await viewModel.register(
      name: 'Usuario Invalido',
      email: 'usuarioinvalido@correo.unimet.edu.ve',
      password: 'password123',
      phone: '+58 412 1234567',
      gender: 'Masculino',
      birthday: '01/01/1995',
    );

    expect(user, isNotNull);
    expect(viewModel.isAuthenticated, isTrue);
    expect(viewModel.currentUser?.firstName, 'Usuario Invalido');
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.isLoading, isFalse);
  });

  test(
    'login stores the repository error and keeps user unauthenticated',
    () async {
      final repository = FakeAuthRepository()
        ..nextError = const AppException('Correo o contrasena incorrectos.');
      final viewModel = AuthViewModel(authRepository: repository);

      final user = await viewModel.login(
        email: 'usuarioinvalido@correo.unimet.edu.ve',
        password: 'bad-password',
      );

      expect(user, isNull);
      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.errorMessage, 'Correo o contrasena incorrectos.');
      expect(viewModel.isLoading, isFalse);
    },
  );

  test('logout clears the current user', () async {
    final repository = FakeAuthRepository();
    final viewModel = AuthViewModel(authRepository: repository);

    await viewModel.login(
      email: 'usuarioinvalido@correo.unimet.edu.ve',
      password: 'password123',
    );
    await viewModel.logout();

    expect(repository.logoutCalled, isTrue);
    expect(viewModel.currentUser, isNull);
    expect(viewModel.isAuthenticated, isFalse);
  });
}
