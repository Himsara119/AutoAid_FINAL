import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream current auth state (null when signed out)
  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update profile
      await cred.user?.updateDisplayName('$firstName $lastName');
      // Send verification link
      await cred.user?.sendEmailVerification();
      // Force clean state so the user must log in AFTER verifying
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Login and enforce email verification.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool resendIfUnverified = true,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        await _auth.signOut();
        throw AuthFailure(code: 'no-user', message: 'No user session established.');
      }

      // Always refresh before checking
      await user.reload();
      if (!(user.emailVerified)) {
        if (resendIfUnverified) {
          await user.sendEmailVerification();
        }
        await _auth.signOut();
        throw AuthFailure(
          code: 'email-not-verified',
          message: 'Email not verified. We sent a new verification email.',
        );
      }

      // Verified allow entry
      return;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    }
  }

  /// Try reloading and return the latest emailVerified state.
  Future<bool> refreshAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return user.emailVerified;
  }

  /// Resend verification email to the current user.
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthFailure(code: 'not-signed-in', message: 'No signed-in user to verify.');
    }
    await user.sendEmailVerification();
  }

  Future<void> signOut() => _auth.signOut();

  // ------------ Error mapping ------------

  AuthFailure _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthFailure(code: e.code, message: 'The email address is invalid.');
      case 'user-disabled':
        return AuthFailure(code: e.code, message: 'This account has been disabled.');
      case 'user-not-found':
        return AuthFailure(code: e.code, message: 'No account found for this email.');
      case 'wrong-password':
        return AuthFailure(code: e.code, message: 'Incorrect password.');
      case 'email-already-in-use':
        return AuthFailure(code: e.code, message: 'An account already exists for this email.');
      case 'weak-password':
        return AuthFailure(code: e.code, message: 'Password is too weak.');
      case 'too-many-requests':
        return AuthFailure(code: e.code, message: 'Too many attempts. Try again later.');
      default:
        return AuthFailure(
          code: e.code.isEmpty ? 'auth-error' : e.code,
          message: e.message ?? 'Authentication failed.',
        );
    }
  }
}

class AuthFailure implements Exception {
  final String code;
  final String message;
  AuthFailure({required this.code, required this.message});

  @override
  String toString() => '$code: $message';
}
