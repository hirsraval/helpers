import 'package:flutter/cupertino.dart';

mixin PageStorageHelper<T extends StatefulWidget> on State<T> {
  late final PageStorageBucket _bucket = PageStorage.of(context);

  void write(String key, Object? data) async {
    _bucket.writeState(context, data, identifier: ValueKey(key));
  }

  S? read<S>(String key, {S Function(dynamic data)? parser}) {
    final data = _bucket.readState(context, identifier: key) as Object?;
    if (data != null) {
      return parser?.call(data) ?? (data as S?);
    }
    return null;
  }
}
