import 'package:url_launcher/url_launcher.dart';

mixin UrlLauncherHelper {
  Future<void> makePhoneCall({required String phoneNumber}) async {
    final Uri launchUri = Uri.parse("tel:$phoneNumber");
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }

  Future<void> openEmail({required String emailAddress}) async {
    final Uri launchUri = Uri.parse("mailto:$emailAddress");
    await launchUrl(launchUri, mode: LaunchMode.externalApplication);
  }
}