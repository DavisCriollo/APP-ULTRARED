import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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

  bool get tieneCoordenadas => latitud != 0 || longitud != 0;

  /// Última ubicación que el teléfono ya tenía. Responde al instante.
  static Future<Ubicacion?> obtenerUltimaConocida() async {
    try {
      final posicion = await Geolocator.getLastKnownPosition();
      if (posicion == null) return null;
      return Ubicacion(
        longitud: posicion.longitude,
        latitud: posicion.latitude,
      );
    } catch (_) {
      return null;
    }
  }

  /// 📍 Obtiene la ubicación actual del dispositivo
  static Future<Ubicacion> obtenerActual() async {
    try {
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) {
        return Ubicacion(longitud: 0, latitud: 0);
      }

      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) {
          return Ubicacion(longitud: 0, latitud: 0);
        }
      }

      if (permiso == LocationPermission.deniedForever) {
        return Ubicacion(longitud: 0, latitud: 0);
      }

      // final settings = LocationSettings(
      //   accuracy: LocationAccuracy.high,
      //   distanceFilter: 10,
      // );

      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      return Ubicacion(
        longitud: posicion.longitude,
        latitud: posicion.latitude,
      );
    } catch (e) {
      return Ubicacion(longitud: 0, latitud: 0);
    }
  }
}
