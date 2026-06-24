import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyec/core/errors/app_exception.dart';
import 'package:proyec/data/repositories/auth_repository.dart';
import 'package:proyec/data/services/auth_service.dart';
import 'package:proyec/data/services/user_profile_service.dart';
import 'package:proyec/domain/models/app_user.dart';

void main() {
  test(
    'register returns the Firebase user even when profile creation fails',
    () async {
      final authService = _FakeAuthService();
      final profileService = _FakeUserProfileService()..failCreate = true;
      final repository = FirebaseAuthRepository(
        authService: authService,
        userProfileService: profileService,
      );

      final user = await repository.register(
        name: 'Usuario Invalido',
        email: 'usuarioinvalido@correo.unimet.edu.ve',
        password: 'password123',
        phone: '+58 412 1234567',
        gender: 'Masculino',
        birthday: '01/01/1995',
      );

      expect(user.id, 'user-1');
      expect(user.email, 'usuarioinvalido@correo.unimet.edu.ve');
      expect(user.name, 'Usuario Invalido');
    },
  );

  test('login repairs a missing profile and returns a fallback user', () async {
    final authService = _FakeAuthService();
    final profileService = _FakeUserProfileService();
    final repository = FirebaseAuthRepository(
      authService: authService,
      userProfileService: profileService,
    );

    final user = await repository.login(
      email: 'usuarioinvalido@correo.unimet.edu.ve',
      password: 'password123',
    );

    expect(user.id, 'user-1');
    expect(user.name, 'usuarioinvalido');
    expect(profileService.savedUser?.id, 'user-1');
  });

  test('login returns a fallback user when profile lookup fails', () async {
    final authService = _FakeAuthService();
    final profileService = _FakeUserProfileService()..failGet = true;
    final repository = FirebaseAuthRepository(
      authService: authService,
      userProfileService: profileService,
    );

    final user = await repository.login(
      email: 'usuarioinvalido@correo.unimet.edu.ve',
      password: 'password123',
    );

    expect(user.id, 'user-1');
    expect(user.email, 'usuarioinvalido@correo.unimet.edu.ve');
  });

  test('login still reports invalid credentials from Firebase Auth', () async {
    final authService = _FakeAuthService()
      ..signInError = FirebaseAuthException(code: 'invalid-credential');
    final repository = FirebaseAuthRepository(
      authService: authService,
      userProfileService: _FakeUserProfileService(),
    );

    expect(
      () => repository.login(
        email: 'usuarioinvalido@correo.unimet.edu.ve',
        password: 'bad-password',
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.message,
          'message',
          'Correo o contrasena incorrectos.',
        ),
      ),
    );
  });
}

class _FakeAuthService implements AuthService {
  FirebaseAuthException? signInError;
  String? _currentUserId;

  @override
  Stream<String?> authStateChanges() => Stream.value(_currentUserId);

  @override
  Future<AuthCredentials> createUser({
    required String email,
    required String password,
  }) async {
    _currentUserId = 'user-1';
    return AuthCredentials(uid: _currentUserId!, email: email);
  }

  @override
  String? get currentUserId => _currentUserId;

  @override
  Future<AuthCredentials> signIn({
    required String email,
    required String password,
  }) async {
    final error = signInError;
    if (error != null) throw error;
    _currentUserId = 'user-1';
    return AuthCredentials(uid: _currentUserId!, email: email);
  }

  @override
  Future<void> signOut() async {
    _currentUserId = null;
  }
}

class _FakeUserProfileService implements UserProfileService {
  AppUser? savedUser;
  bool failCreate = false;
  bool failGet = false;

  @override
  Future<void> createUser(AppUser user) async {
    if (failCreate) throw Exception('profile create failed');
    savedUser = user;
  }

  @override
  Future<AppUser?> getUser(String id) async {
    if (failGet) throw Exception('profile get failed');
    return savedUser;
  }

  @override
  Stream<List<AppUser>> watchUsers() {
    return Stream.value([?savedUser]);
  }

  @override
  Future<void> updateUser(AppUser user) async {
    savedUser = user;
  }
}
