import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpers/helpers.dart';

export 'apple_login_helper.dart';
export 'facebook_login_helper.dart';
export 'google_login_helper.dart';
export 'result.dart';

abstract base class SocialLoginHelper {
  Future<bool> get isSignedIn => Future.value(false);

  Future<SocialLoginResult?> loginAnonymously();

  Future<UserCredential?> signIn() async {
    try {
      final res = await handleSignIn();
      return res;
    } on FirebaseAuthException catch (e, st) {
      Log.error(e);
      Log.error(st);
    }
    return null;
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  Future<UserCredential?> handleSignIn();
}
