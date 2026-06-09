import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/models/app_user.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<AppUser?> loadCurrentUser() async {
    return _run(() => _authRepository.currentUserProfile());
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
    required String birthday,
  }) {
    return _run(
      () => _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        gender: gender,
        birthday: birthday,
      ),
    );
  }

  Future<AppUser?> login({required String email, required String password}) {
    return _run(() => _authRepository.login(email: email, password: password));
  }

  Future<AppUser?> updateProfile(AppUser user) {
    return _run(() => _authRepository.updateProfile(user));
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _currentUser = null;
      _errorMessage = null;
    } on AppException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudo cerrar la sesion.';
    } finally {
      _setLoading(false);
    }
  }

  Future<AppUser?> _run(Future<AppUser?> Function() action) async {
    _setLoading(true);
    try {
      final user = await action();
      _currentUser = user;
      _errorMessage = null;
      return user;
    } on AppException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Ocurrio un error inesperado.';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
