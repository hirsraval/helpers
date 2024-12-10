import 'dart:async';

import 'package:flutter/material.dart';

mixin AfterLayoutMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await afterFirstLayout();
    });
  }

  @mustCallSuper
  FutureOr<void> afterFirstLayout();
}
