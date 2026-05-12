import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Lightweight domain model wrapping Firebase User.
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isEmailVerified = false,
  });

  factory AppUser.fromFirebaseUser(fb.User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }
}
