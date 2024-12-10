import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'log.dart';

mixin StorageHelper {
  Future<File?> downloadFile(String url, String fileName) async {
    HttpClient httpClient = HttpClient();
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      final dir = await getTemporaryDirectory();
      File file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      Log.success("File Stored Successfully -> ${file.path}");
      return file;
    } catch (e) {
      Log.error("StorageHelper.downloadFile -> $e");
      return null;
    }
  }

  Future<bool> checkFileExist(String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      File file = File('${dir.path}/$fileName');
      return file.exists();
    } catch (e) {
      Log.error("StorageHelper.checkFileExist -> $e");
      return false;
    }
  }
}
