abstract class SocialLoginResult {
  String? get token;

  String? get email;

  String? get name;
}

base class GoogleLoginResult extends SocialLoginResult {
  GoogleLoginResult({this.token, this.email, this.name, this.idToken});

  final String? idToken;
  @override
  final String? token;
  @override
  final String? email;
  @override
  final String? name;
}

base class FacebookLoginResult extends SocialLoginResult {
  FacebookLoginResult({this.token});

  @override
  final String? token;

  @override
  String? get email => "";

  @override
  String? get name => "";
}

base class AppleLoginResult extends SocialLoginResult {
  AppleLoginResult({this.token, this.email, this.name});

  @override
  final String? token;
  @override
  final String? email;
  @override
  final String? name;
}
