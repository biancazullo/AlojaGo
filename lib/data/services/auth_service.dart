import 'package:firebase_auth/firebase_auth.dart';

class AuthCredentials {
  const AuthCredentials({required this.uid, required this.email});

  final String uid;
  final String email;
}

abstract class AuthService {
  Stream<String?> authStateChanges();
  Future<AuthCredentials> createUser({
    required String email,
    required String password,
  });
  Future<AuthCredentials> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  String? get currentUserId;
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<String?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<AuthCredentials> createUser({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'No se pudo crear el usuario.',
      );
    }
    return AuthCredentials(uid: user.uid, email: user.email ?? email);
  }

  @override
  Future<AuthCredentials> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'No se pudo iniciar sesion.',
      );
    }
    return AuthCredentials(uid: user.uid, email: user.email ?? email);
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();
}
