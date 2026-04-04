import 'package:family_health/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthDataSource {
  AuthDataSource() : _firebaseAuth = FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Future<UserEntity> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn.instance.authenticate();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    final User? user = userCredential.user;
    if (user == null) {
      throw Exception('Firebase authentication failed');
    }

    return _mapFirebaseUser(user);
  }

  Future<UserEntity> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    final UserCredential userCredential =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;
    if (user == null) {
      throw Exception('Firebase authentication failed');
    }

    return _mapFirebaseUser(user);
  }

  Future<UserEntity> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    final UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;
    if (user == null) {
      throw Exception('Firebase sign up failed');
    }

    return _mapFirebaseUser(user);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore UnimplementedError on platforms (like Windows) that don't support Google SignIn completely
    }
  }

  UserEntity? getCurrentUser() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }
}
