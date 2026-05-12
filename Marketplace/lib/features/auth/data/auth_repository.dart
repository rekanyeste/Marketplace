import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../domain/app_user.dart';

/// Repository wrapping Firebase Authentication.
class AuthRepository {
  final fb.FirebaseAuth _auth;

  AuthRepository({fb.FirebaseAuth? auth})
      : _auth = auth ?? fb.FirebaseAuth.instance;

  /// Stream of auth state changes.
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      return user != null ? AppUser.fromFirebaseUser(user) : null;
    });
  }

  /// Current user (synchronous).
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user != null ? AppUser.fromFirebaseUser(user) : null;
  }

  /// Sign up with email and password.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return AppUser.fromFirebaseUser(credential.user!);
  }

  /// Sign in with email and password.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return AppUser.fromFirebaseUser(credential.user!);
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Send email verification to the current user.
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Reload the current user to refresh emailVerified status.
  Future<AppUser?> reloadUser() async {
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;
    return user != null ? AppUser.fromFirebaseUser(user) : null;
  }
}
