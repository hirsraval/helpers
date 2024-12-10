import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

import 'permission_helper_base.dart';
import 'permission_result.dart';

class PermissionHelperImpl implements PermissionHelper {
  @override
  final Permission permission;

  const PermissionHelperImpl(this.permission);

  PermissionResult _getPermissionResult(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.denied => PermissionResult.denied,
      PermissionStatus.granted || PermissionStatus.provisional => PermissionResult.granted,
      PermissionStatus.limited => Platform.isIOS ? PermissionResult.granted : PermissionResult.denied,
      PermissionStatus.restricted || PermissionStatus.permanentlyDenied => PermissionResult.permanentlyDenied,
    };
  }

  ServiceResult _getServiceResult(ServiceStatus status) {
    return switch (status) {
      ServiceStatus.disabled => ServiceResult.disabled,
      ServiceStatus.enabled => ServiceResult.enabled,
      ServiceStatus.notApplicable => ServiceResult.notApplicable,
    };
  }

  @override
  Future<PermissionResult> requestPermission() async {
    final status = await permission.request();
    return _getPermissionResult(status);
  }

  @override
  Future<PermissionResult> checkPermission() async {
    final status = await permission.status;
    return _getPermissionResult(status);
  }

  @override
  Future<ServiceResult> checkService() async {
    if (permission is PermissionWithService) {
      final status = await (permission as PermissionWithService).serviceStatus;
      return _getServiceResult(status);
    }
    return ServiceResult.notApplicable;
  }

  @override
  Future<bool> openAppSettings() => permission_handler.openAppSettings();
}
