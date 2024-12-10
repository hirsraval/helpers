import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'social_login.dart';

final class FacebookLoginHelper extends SocialLoginHelper {
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  FacebookLoginHelper._internal();

  static FacebookLoginHelper? _instance;

  factory FacebookLoginHelper() => _instance ??= FacebookLoginHelper._internal();

  @override
  Future<FacebookLoginResult?> loginAnonymously() async {
    final result = await _facebookAuth.login();
    if (result.status == LoginStatus.success && result.accessToken != null) {
      return FacebookLoginResult(token: result.accessToken?.tokenString);
    }
    return null;
  }

  @override
  Future<UserCredential?> handleSignIn() async {
    final result = await loginAnonymously();
    if (result == null) return null;
    final OAuthCredential credential = FacebookAuthProvider.credential(result.token!);
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    signOut();
    return userCredential;
  }

  @override
  Future<void> signOut() async {
    await _facebookAuth.logOut();
    super.signOut();
  }

  @override
  Future<bool> get isSignedIn => _facebookAuth.accessToken.then((value) => value != null);
}
