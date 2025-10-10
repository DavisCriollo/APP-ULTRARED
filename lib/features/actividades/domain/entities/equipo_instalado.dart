import 'package:ultrared/features/shared/helpers/parse.dart';
import 'package:uuid/uuid.dart';

class ValidacionEquipoInstalado {
  String? material;
  String? cantidad;
  bool isValid;
  ValidacionEquipoInstalado({
    this.material,
    this.cantidad,
    this.isValid = true,
  });
  ValidacionEquipoInstalado copyWith({
    String? material,
    String? cantidad,
    bool? isValid,
  }) {
    return ValidacionEquipoInstalado(
      material: material ?? this.material,
      cantidad: cantidad ?? this.cantidad,
      isValid: isValid ?? this.isValid,
    );
  }

  bool validacionHijo(EquipoInstalado itemHijo) {
    final noEsValido = itemHijo.material.trim() == "" || itemHijo.cantidad <= 0;
    isValid = !noEsValido;
    material = itemHijo.material.trim() == "" ? 'Campo requerido' : null;
    cantidad = itemHijo.cantidad <= 0 ? 'Debe ser mayor a 0' : null;
    return noEsValido;
  }
}

class EquipoInstalado {
  String id;
  int cantidad;
  String material;
  String marca;
  String serie;
  String observaciones;

  EquipoInstalado({
    required this.id,
    required this.cantidad,
    required this.material,
    required this.marca,
    required this.serie,
    required this.observaciones,
  });
  static EquipoInstalado defaultEquipoInstalado() {
    return EquipoInstalado(
      id: const Uuid().v4(),
      cantidad: 0,
      marca: '',
      material: '',
      serie: '',
      observaciones: '',
    );
  }

  EquipoInstalado copyWith({
    String? id,
    int? cantidad,
    String? material,
    String? marca,
    String? serie,
    String? observaciones,
  }) =>
      EquipoInstalado(
        id: id ?? this.id,
        cantidad: cantidad ?? this.cantidad,
        material: material ?? this.material,
        marca: marca ?? this.marca,
        serie: serie ?? this.serie,
        observaciones: observaciones ?? this.observaciones,
      );
  factory EquipoInstalado.fromJson(Map<String, dynamic> json) =>
      EquipoInstalado(
        id: json["id"],
        cantidad: Parse.parseDynamicToInt(json["cantidad"]),
        material: json["material"],
        marca: json["marca"],
        serie: json["serie"],
        observaciones: json["observaciones"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "cantidad": cantidad,
        "material": material,
        "marca": marca,
        "serie": serie,
        "observaciones": observaciones,
      };
}
