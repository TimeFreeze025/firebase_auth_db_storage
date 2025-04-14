import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get Current User
  User? get currentUser => _auth.currentUser;

  // Stream Auth State Changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email Verification Status
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Check if user needs email verification
  bool needsEmailVerification() {
    final user = _auth.currentUser;
    return user != null &&
        !user.emailVerified &&
        user.providerData.any((userInfo) => userInfo.providerId == 'password');
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign in aborted by user');
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await _auth.signInWithCredential(credential);
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
