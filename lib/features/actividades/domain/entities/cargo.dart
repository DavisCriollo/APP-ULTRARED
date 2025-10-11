import 'package:ultrared/features/shared/errors/error_validacion.dart';
import 'package:ultrared/features/shared/helpers/parse.dart';
import 'package:uuid/uuid.dart';

class ValidacionCargo {
  String? item;
  String? costoUnitario;
  String? cantidad;
  String? valor;
  bool isValid;

  ValidacionCargo({
    this.item,
    this.costoUnitario,
    this.cantidad,
    this.valor,
    this.isValid = true,
  });

  ValidacionCargo copyWith({
    String? item,
    String? costoUnitario,
    String? cantidad,
    String? valor,
    bool? isValid,
  }) {
    return ValidacionCargo(
      item: item ?? this.item,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      cantidad: cantidad ?? this.cantidad,
      valor: valor ?? this.valor,
      isValid: isValid ?? this.isValid,
    );
  }

  bool validar(Cargo itemHijo) {
    item = Validacion.campoRequerido(itemHijo.item);
    costoUnitario =
        itemHijo.costoUnitario <= 0 ? Validacion.numMin(valor: 0) : null;
    cantidad = itemHijo.cantidad <= 0 ? Validacion.numMin(valor: 0) : null;
    valor = itemHijo.valor <= 0 ? Validacion.numMin(valor: 0) : null;

    isValid = [
      item,
      costoUnitario,
      cantidad,
      valor,
    ].every((error) => error == null);

    return !isValid;
  }
}

class Cargo {
  String id;
  String item;
  double costoUnitario;
  int cantidad;
  double valor;
  String descripcion;

  Cargo({
    required this.id,
    required this.item,
    required this.costoUnitario,
    required this.cantidad,
    required this.valor,
    required this.descripcion,
  });
  static Cargo defaultCargo() {
    return Cargo(
      id: const Uuid().v4(),
      item: '',
      cantidad: 0,
      costoUnitario: 0,
      valor: 0,
      descripcion: '',
    );
  }

  Cargo copyWith({
    String? id,
    String? item,
    double? costoUnitario,
    int? cantidad,
    double? valor,
    String? descripcion,
  }) =>
      Cargo(
        id: id ?? this.id,
        item: item ?? this.item,
        costoUnitario: costoUnitario ?? this.costoUnitario,
        cantidad: cantidad ?? this.cantidad,
        valor: valor ?? this.valor,
        descripcion: descripcion ?? this.descripcion,
      );
  factory Cargo.fromJson(Map<String, dynamic> json) => Cargo(
        id: json["id"],
        item: json["item"],
        costoUnitario: Parse.parseDynamicToDouble(json["costoUnitario"]),
        cantidad: Parse.parseDynamicToInt(json["cantidad"]),
        valor: Parse.parseDynamicToDouble(json["valor"]),
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "item": item,
        "costoUnitario": costoUnitario,
        "cantidad": cantidad,
        "valor": valor,
        "descripcion": descripcion,
      };
}
