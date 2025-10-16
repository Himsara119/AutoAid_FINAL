import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// Watch authentication state changes
  Stream<User?> authState() => _auth.authStateChanges();

  /// Sign in existing user
  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  /// Register new user and create Firestore document
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'user',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'display_name': displayName,
      'email': email,
      'role': role,
      'deleted': false,
      'settings': {'push_enabled': true, 'locale': 'en', 'theme': 'light'},
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    return cred;
  }

  /// Send a password reset email
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Sign out the user
  Future<void> signOut() => _auth.signOut();

  /// Fetch currently logged-in user's Firestore profile
  Future<DocumentSnapshot<Map<String, dynamic>>> getProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("No logged-in user");
    return _db.collection('users').doc(uid).get();
  }
}
