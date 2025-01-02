import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef PaginatedBuilder = void Function(BuildContext context);

class PaginationListener extends StatelessWidget {
  const PaginationListener({
    super.key,
    required this.onRefresh,
    required this.onScrollToEnd,
    required this.child,
  });

  final PaginatedBuilder onRefresh;
  final PaginatedBuilder onScrollToEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(context),
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent) {
            onScrollToEnd(context);
          }
          return false;
        },
        child: Scrollbar(child: child),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Widget>('child', child));
  }
}
