import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ultrared/features/shared/helpers/parse.dart';

class Ubicacion {
  double longitud;
  double latitud;

  Ubicacion({
    required this.longitud,
    required this.latitud,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        longitud: Parse.parseDynamicToDouble(json["longitud"]),
        latitud: Parse.parseDynamicToDouble(json["latitud"]),
      );

  factory Ubicacion.fromLatLng(LatLng latLng) => Ubicacion(
        longitud: Parse.parseDynamicToDouble(latLng.longitude),
        latitud: Parse.parseDynamicToDouble(latLng.latitude),
      );

  Map<String, dynamic> toJson() => {
        "longitud": longitud,
        "latitud": latitud,
      };
}
