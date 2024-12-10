import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:helpers/permission/permission.dart';
import 'package:image_picker/image_picker.dart';

import 'log.dart';

mixin MediaPickerHelper<T extends StatefulWidget> on State<T> {
  late final _imagePicker = ImagePicker();
  late final _filePicker = FilePicker.platform;
  final _deviceInfo = Completer<BaseDeviceInfo>();

  @override
  void initState() {
    super.initState();
    final deviceInfo = DeviceInfoPlugin();
    _deviceInfo.complete(deviceInfo.deviceInfo);
  }

  Future<ImageSource?> _chooseImageSource() async {
    return SynchronousFuture(ImageSource.gallery);
  }

  Future<bool> _resolvePermissionForImage(BuildContext context, ImageSource source) async {
    PermissionHelper? permission;
    switch (source) {
      case ImageSource.camera:
        permission = PermissionHelper.camera;
        break;
      case ImageSource.gallery:
        if (Platform.isAndroid) {
          _deviceInfo.future.then(
            (deviceInfo) {
              final androidInfo = deviceInfo as AndroidDeviceInfo;
              if (androidInfo.version.sdkInt < 33) {
                permission = PermissionHelper.storage;
              }
            },
          );
        }
        permission ??= PermissionHelper.photos;
    }
    final result = await permission?.requestPermission();
    return result == PermissionResult.granted;
  }

  Future<bool> _resolvePermissionForVideo(BuildContext context, ImageSource source) async {
    PermissionHelper? permission;
    PermissionHelper? microphone;
    switch (source) {
      case ImageSource.camera:
        permission = PermissionHelper.camera;
        if (Platform.isIOS) {
          microphone = PermissionHelper.microphone;
        }
        break;
      case ImageSource.gallery:
        if (Platform.isAndroid) {
          _deviceInfo.future.then(
            (deviceInfo) {
              final androidInfo = deviceInfo as AndroidDeviceInfo;
              if (androidInfo.version.sdkInt < 33) {
                permission = PermissionHelper.storage;
              }
            },
          );
        }
        permission ??= PermissionHelper.videos;
    }
    final result = await permission?.requestPermission();
    if (Platform.isIOS && microphone != null) {
      final microphoneResult = await microphone.requestPermission();
      return result == PermissionResult.granted && microphoneResult == PermissionResult.granted;
    }
    return result == PermissionResult.granted;
  }

  Future<XFile?> pickVideo({ImageSource? source}) async {
    try {
      source ??= await _chooseImageSource();
      if (source == null) return null;
      final permissionResult = await _resolvePermissionForVideo(context, source);
      if (!permissionResult) return null;
      var pickedVideo = await _imagePicker.pickVideo(source: source);
      return pickedVideo;
    } on Exception catch (e) {
      Log.error("MediaPickerHelper.pickVideo -> $e");
      return null;
    }
  }

  Future<List<XFile>> pickMultipleVideos() async {
    try {
      final permissionResult = await _resolvePermissionForVideo(context, ImageSource.gallery);
      if (!permissionResult) return [];
      var pickedVideos = await _filePicker.pickFiles(type: FileType.video, allowMultiple: true);
      return pickedVideos?.xFiles ?? <XFile>[];
    } on Exception catch (e) {
      Log.error("MediaPickerHelper.pickMultipleVideos -> $e");
      return [];
    }
  }

  Future<XFile?> pickImage({ImageSource? source}) async {
    try {
      source ??= await _chooseImageSource();
      if (source == null) return null;
      final permissionResult = await _resolvePermissionForImage(context, source);
      if (!permissionResult) return null;
      var pickedImage = await _imagePicker.pickImage(source: source, imageQuality: 100);
      return pickedImage;
    } on Exception catch (e) {
      Log.error("MediaPickerHelper.pickImage -> $e");
      return null;
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    try {
      final permissionResult = await _resolvePermissionForImage(context, ImageSource.gallery);
      if (!permissionResult) return [];
      var pickedImages = await _imagePicker.pickMultiImage(imageQuality: 100);
      return pickedImages;
    } on Exception catch (e) {
      Log.error("MediaPickerHelper.pickMultipleImages -> $e");
      return [];
    }
  }
}
