import 'dart:async';

import 'package:helpers/helpers.dart';

class BusEventData<T extends Object> {
  const BusEventData({required this.tag, this.data});

  final String tag;
  final T? data;
}

class EventBus {
  EventBus() : _controller = StreamController<BusEventData>.broadcast();

  final StreamController<BusEventData> _controller;

  StreamSubscription<BusEventData> listen(
    Function(BusEventData event) onEvent,
    bool? cancelOnError,
  ) {
    return _controller.stream.listen(onEvent, cancelOnError: cancelOnError);
  }

  void fire<T extends Object>(String tag, {T? data}) {
    Log.debug("BusEvent Fired - $tag -> $data");
    _controller.add(BusEventData<T>(tag: tag, data: data));
  }

  void dispose() {
    _controller.close();
  }
}
