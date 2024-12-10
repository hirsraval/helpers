// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:permission_handler/permission_handler.dart';

import 'permission_helper_base.dart';
import 'permission_result.dart';

class PermissionHelperImpl implements PermissionHelper {
  @override
  final Permission permission;

  const PermissionHelperImpl(this.permission);

  PermissionResult _getPermissionResult(String status) {
    return switch (status) {
      "granted" => PermissionResult.granted,
      "prompt" => PermissionResult.denied,
      "denied" => PermissionResult.permanentlyDenied,
      _ => PermissionResult.denied,
    };
  }

  String _determinePermissionName() {
    return switch (permission) {
      Permission.camera => 'camera',
      Permission.notification => 'notifications',
      Permission.location || Permission.locationAlways || Permission.locationWhenInUse => 'geolocation',
      Permission.photos || Permission.storage => 'storage-access',
      _ => '',
    };
  }

  @override
  Future<PermissionResult> requestPermission() async {
    return checkPermission();
  }

  @override
  Future<PermissionResult> checkPermission() async {
    final status = await html.window.navigator.permissions?.query({'name': _determinePermissionName()});
    return _getPermissionResult(status?.state ?? "");
  }

  @override
  Future<ServiceResult> checkService() async {
    if (permission is PermissionWithService) {
      return ServiceResult.enabled;
    }
    return ServiceResult.notApplicable;
  }

  @override
  Future<bool> openAppSettings() {
    return Future.value(false);
  }
}
