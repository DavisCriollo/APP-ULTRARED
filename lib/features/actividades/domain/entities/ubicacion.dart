import 'package:ultrared/features/shared/helpers/parse.dart';

class Ubicacion {
  String longitud;
  String latitud;

  Ubicacion({
    required this.longitud,
    required this.latitud,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        longitud: Parse.parseDynamicToString(json["longitud"]),
        latitud: Parse.parseDynamicToString(json["latitud"]),
      );

  Map<String, dynamic> toJson() => {
        "longitud": longitud,
        "latitud": latitud,
      };
}
