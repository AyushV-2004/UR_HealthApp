import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// =======================
  /// LOGIN (EMAIL)
  /// =======================
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// =======================
  /// REGISTER (EMAIL AUTH ONLY)
  /// =======================
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// =======================
  /// GOOGLE SIGN-IN
  /// =======================
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final userCredential =
    await _auth.signInWithCredential(credential);

    final user = userCredential.user;

    if (user != null &&
        userCredential.additionalUserInfo!.isNewUser) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? 'User',
        'email': user.email,
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  /// =======================
  /// FORGOT PASSWORD
  /// =======================
  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// =======================
  /// LOGOUT (IMPORTANT)
  /// =======================
  Future<void> logout() async {
    await _googleSignIn.signOut(); // prevents auto-login
    await _auth.signOut();
  }

  /// =======================
  /// AUTH STATE STREAM
  /// =======================
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
