import 'dart:async';

import 'package:proyec/core/errors/app_exception.dart';
import 'package:proyec/data/repositories/auth_repository.dart';
import 'package:proyec/domain/models/app_user.dart';

class FakeAuthRepository implements AuthRepository {
  AppUser? currentUser;
  AppException? nextError;
  bool logoutCalled = false;

  @override
  Stream<String?> authStateChanges() {
    return Stream.value(currentUser?.id);
  }

  @override
  Future<AppUser?> currentUserProfile() async => currentUser;

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    currentUser = AppUser(id: 'user-1', name: 'Usuario Invalido', email: email);
    return currentUser!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    currentUser = null;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
    required String birthday,
    UserRole role = UserRole.traveler,
  }) async {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    currentUser = AppUser(
      id: 'user-1',
      name: name,
      email: email,
      phone: phone,
      gender: gender,
      birthday: birthday,
    );
    return currentUser!;
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async {
    currentUser = user;
    return user;
  }
}
