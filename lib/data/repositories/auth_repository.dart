// lib/data/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';

abstract class AuthRepository {
  Stream<String?> authStateChanges();
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
    required String birthday,
    required UserRole role,  // ← NUEVO
  });
  Future<AppUser> login({required String email, required String password});
  Future<AppUser?> currentUserProfile();
  Future<AppUser> updateProfile(AppUser user);
  Future<void> logout();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    AuthService? authService,
    UserProfileService? userProfileService,
  }) : _authService = authService ?? FirebaseAuthService(),
       _userProfileService =
           userProfileService ?? FirestoreUserProfileService();

  final AuthService _authService;
  final UserProfileService _userProfileService;

  @override
  Stream<String?> authStateChanges() => _authService.authStateChanges();

  @override
  Future<AppUser?> currentUserProfile() async {
    final uid = _authService.currentUserId;
    if (uid == null) return null;
    return _userProfileService.getUser(uid);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
    required String birthday,
    required UserRole role,
  }) async {
    try {
      final credentials = await _authService.createUser(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = AppUser(
        id: credentials.uid,
        name: name.trim(),
        email: credentials.email,
        phone: phone.trim(),
        gender: gender,
        birthday: birthday,
        role: role,
      );
      await _userProfileService.createUser(user);
      return user;
    } on FirebaseAuthException catch (error) {
      throw AppException(_authMessage(error));
    } catch (_) {
      throw const AppException('No se pudo crear la cuenta.');
    }
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final credentials = await _authService.signIn(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final profile = await _userProfileService.getUser(credentials.uid);
      return profile ??
          AppUser(
            id: credentials.uid,
            name: credentials.email.split('@').first,
            email: credentials.email,
          );
    } on FirebaseAuthException catch (error) {
      throw AppException(_authMessage(error));
    } catch (_) {
      throw const AppException('No se pudo iniciar sesion.');
    }
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    try {
      await _userProfileService.updateUser(user);
      return user;
    } catch (_) {
      throw const AppException('No se pudieron guardar los cambios.');
    }
  }

  @override
  Future<void> logout() => _authService.signOut();

  String _authMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'El correo ya esta registrado.';
      case 'invalid-email':
        return 'El correo no es valido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contrasena incorrectos.';
      case 'weak-password':
        return 'La contrasena debe ser mas segura.';
      default:
        return error.message ?? 'Error de autenticacion.';
    }
  }
}
