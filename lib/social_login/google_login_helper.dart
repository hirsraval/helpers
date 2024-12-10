import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helpers/helpers.dart';

final class GoogleLoginHelper extends SocialLoginHelper {
  GoogleLoginHelper._internal();

  static GoogleLoginHelper? _instance;

  factory GoogleLoginHelper() => _instance ??= GoogleLoginHelper._internal();

  late final GoogleSignIn _googleSignIn;

  @override
  Future<GoogleLoginResult?> loginAnonymously({String? clientId, String? serverClientId}) async {
    _googleSignIn = GoogleSignIn(clientId: clientId, serverClientId: serverClientId, scopes: ["email"]);
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    return GoogleLoginResult(
      token: googleAuth.accessToken,
      idToken: googleAuth.idToken,
      email: googleUser.email,
      name: googleUser.displayName,
    );
  }

  @override
  Future<UserCredential?> handleSignIn() async {
    final result = await loginAnonymously();
    if (result == null) return null;
    final credential = GoogleAuthProvider.credential(accessToken: result.token, idToken: result.idToken);
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    signOut();
    return userCredential;
  }

  @override
  Future<bool> get isSignedIn => _googleSignIn.isSignedIn();

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    super.signOut();
  }
}
