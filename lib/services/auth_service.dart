import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles Firebase authentication flows for the Pro Dalal app.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Returns the currently signed-in Firebase user, or null.
  static User? get currentUser => _auth.currentUser;

  /// Signs in with Google. Returns the [UserCredential] on success,
  /// or null if the user cancelled the flow.
  ///
  /// Throws a [FirebaseAuthException] on authentication errors.
  static Future<UserCredential?> signInWithGoogle() async {
    // Trigger the Google sign-in flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // User cancelled the picker
    if (googleUser == null) return null;

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential for Firebase
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await _auth.signInWithCredential(credential);
  }

  /// Signs out from Firebase and disconnects the Google account.
  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
