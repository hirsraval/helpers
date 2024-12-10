import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'log.dart';

mixin BitmapDescriptorHelper {
  final Completer<BitmapDescriptor> _bitmapDescriptor = Completer();

  Future<BitmapDescriptor> get bitmapDescriptor => _bitmapDescriptor.future;

  Future<void> initDescriptor(BuildContext context, String icon) async {
    BitmapDescriptor? descriptor;
    try {
      ByteData data = await rootBundle.load(icon);
      final pictureInfo = await vg.loadPicture(SvgBytesLoader(data.buffer.asUint8List()), context);
      final ui.Image image = await pictureInfo.picture.toImage(60, 80);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        descriptor = BitmapDescriptor.fromBytes(
          byteData.buffer.asUint8List(),
          size: const Size(30, 40),
        );
      }
    } catch (error) {
      Log.error(error);
    } finally {
      _bitmapDescriptor.complete(descriptor ?? BitmapDescriptor.defaultMarker);
    }
  }
}

mixin MapControllerHelper {
  final Completer<bool> _googleMapController = Completer();
  late GoogleMapController _controller;

  Future<GoogleMapController> get googleMapController => _googleMapController.future.then((value) => _controller);

  @mustCallSuper
  void onGoogleMapCreated(GoogleMapController controller) {
    _controller = controller;
    if (!_googleMapController.isCompleted) _googleMapController.complete(true);
  }
}

mixin MapCirclesHelper {
  Circle createCircle({
    required BuildContext context,
    required CircleId circleId,
    required LatLng center,
    required double radius,
    required Color color,
  }) {
    return Circle(
      circleId: circleId,
      center: center,
      radius: radius * 1000,
      strokeWidth: 3,
      strokeColor: color,
      fillColor: color.withOpacity(0.25),
    );
  }

  Polygon createPolygon({
    required BuildContext context,
    required PolygonId polygonId,
    required List<LatLng> points,
    required Color color,
  }) {
    return Polygon(
      polygonId: polygonId,
      points: points,
      strokeWidth: 3,
      strokeColor: color,
      fillColor: color.withOpacity(0.25),
    );
  }

  Polygon addPolygonPoint({required Polygon polygon, required LatLng point}) {
    return polygon.copyWith(pointsParam: [...polygon.points, point]);
  }

  Polygon removePolygonPoint({required Polygon polygon, required LatLng point}) {
    return polygon.copyWith(pointsParam: [...polygon.points]..remove(point));
  }

  double getZoomLevelForRadius(double radius) {
    radius = radius * 1000;
    double zoomLevel = 10;
    double newRadius = radius + radius / 2;
    double scale = newRadius / 500;
    zoomLevel = (16 - math.log(scale) / math.log(2));
    return zoomLevel;
  }
}
