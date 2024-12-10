import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpers/log.dart';
import 'package:helpers/permission/permission.dart';

enum DistanceType {
  kilometers,
  meters,
}

mixin LocationHelper {
  Future<Position?> getCurrentLocation() async {
    try {
      final permission = await PermissionHelper.location.requestPermission();
      if (permission != PermissionResult.granted) return null;
      const settings = LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(minutes: 1));
      final position = await Geolocator.getCurrentPosition(locationSettings: settings);
      return position;
    } catch (e) {
      Log.error("LocationHelper.getCurrentLocation -> $e");
      return null;
    }
  }

  Future<double> getDistanceBetweenCoordinates(
    LatLng from,
    LatLng to, {
    DistanceType type = DistanceType.kilometers,
  }) async {
    try {
      double result = Geolocator.distanceBetween(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );
      return switch (type) {
        DistanceType.kilometers => result / 1000,
        DistanceType.meters => result,
      };
    } catch (e) {
      Log.error("LocationHelper.getDistanceBetweenCoordinates -> $e");
      return 0.0;
    }
  }

  Future<Placemark> getAddress(Position position) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    return placeMarks.first;
  }
}
