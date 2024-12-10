import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpers/helpers.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final class AppleLoginHelper extends SocialLoginHelper {
  AppleLoginHelper._internal();

  static AppleLoginHelper? _instance;

  factory AppleLoginHelper() => _instance ??= AppleLoginHelper._internal();

  @override
  Future<AppleLoginResult?> loginAnonymously() async {
    bool available = await SignInWithApple.isAvailable();
    if (!available) return null;
    final idCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );
    return AppleLoginResult(
      token: idCredential.identityToken,
      email: idCredential.email,
      name: idCredential.givenName,
    );
  }

  @override
  Future<UserCredential?> handleSignIn() async {
    final result = await loginAnonymously();
    if (result == null) return null;
    signOut();
    final credential = OAuthProvider("apple.com").credential(idToken: result.token);
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential;
  }
}
