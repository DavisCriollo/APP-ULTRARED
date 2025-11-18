import 'package:ultrared/features/shared/helpers/get_date.dart';
import 'package:ultrared/features/shared/helpers/parse.dart';
import 'package:ultrared/features/shared/infrastructure/inputs/generic_required_input.dart';
import 'package:ultrared/features/shared/infrastructure/inputs/generic_required_input_number.dart';
import 'package:uuid/uuid.dart';

class CcPago {
  final String ccComprobante;
  final String ccTipo;
  final String ccBanco;
  final String ccNumero;
  final String ccDeposito;
  final double ccValor;
  final String ccFechaAbono;
  final String ccDetalle;
  final String ccProcedencia;
  final String ccEstado;
  final String estado;
  final bool imprimir;
  final String ccUsuario;
  final String uuid;
  CcPago copyWith({
    String? ccComprobante,
    String? ccTipo,
    String? ccBanco,
    String? ccNumero,
    String? ccDeposito,
    double? ccValor,
    String? ccFechaAbono,
    String? ccDetalle,
    String? ccProcedencia,
    String? ccEstado,
    String? estado,
    bool? imprimir,
    String? ccUsuario,
    String? uuid,
  }) {
    return CcPago(
      ccComprobante: ccComprobante ?? this.ccComprobante,
      ccTipo: ccTipo ?? this.ccTipo,
      ccBanco: ccBanco ?? this.ccBanco,
      ccNumero: ccNumero ?? this.ccNumero,
      ccDeposito: ccDeposito ?? this.ccDeposito,
      ccValor: ccValor ?? this.ccValor,
      ccFechaAbono: ccFechaAbono ?? this.ccFechaAbono,
      ccDetalle: ccDetalle ?? this.ccDetalle,
      ccProcedencia: ccProcedencia ?? this.ccProcedencia,
      ccEstado: ccEstado ?? this.ccEstado,
      estado: estado ?? this.estado,
      imprimir: imprimir ?? this.imprimir,
      ccUsuario: ccUsuario ?? this.ccUsuario,
      uuid: uuid ?? this.uuid,
    );
  }

  CcPago({
    required this.ccComprobante,
    required this.ccTipo,
    required this.ccBanco,
    required this.ccNumero,
    required this.ccDeposito,
    required this.ccValor,
    required this.ccFechaAbono,
    required this.ccDetalle,
    required this.ccProcedencia,
    required this.ccEstado,
    required this.estado,
    required this.imprimir,
    required this.ccUsuario,
    required this.uuid,
  });

  static CcPago defaultCcPago() {
    return CcPago(
      ccComprobante: "",
      ccTipo: "EFECTIVO",
      ccBanco: "",
      ccNumero: "0",
      ccDeposito: "NO",
      ccValor: 0,
      ccFechaAbono: GetDate.today,
      ccDetalle: "",
      ccProcedencia: "",
      ccEstado: "ACTIVO",
      estado: "ACTIVO",
      imprimir: false,
      ccUsuario: "",
      uuid: '',
    );
  }

  factory CcPago.fromJson(Map<String, dynamic> json) => CcPago(
        ccComprobante: json["ccComprobante"],
        ccTipo: json["ccTipo"],
        ccBanco: json["ccBanco"],
        ccNumero: json["ccNumero"],
        ccDeposito: json["ccDeposito"],
        ccValor: Parse.parseDynamicToDouble(json["ccValor"]),
        ccFechaAbono: json["ccFechaAbono"],
        ccDetalle: json["ccDetalle"],
        ccProcedencia: json["ccProcedencia"],
        ccEstado: json["ccEstado"],
        estado: json["estado"],
        imprimir: json["imprimir"],
        ccUsuario: json["ccUsuario"] ?? "",
        uuid: json["uuid"] ?? const Uuid().v4(),
      );

  Map<String, dynamic> toJson() => {
        "ccComprobante": ccComprobante,
        "ccTipo": ccTipo,
        "ccBanco": ccBanco,
        "ccNumero": ccNumero,
        "ccDeposito": ccDeposito,
        "ccValor": ccValor,
        "ccFechaAbono": ccFechaAbono,
        "ccDetalle": ccDetalle,
        "ccProcedencia": ccProcedencia,
        "ccEstado": ccEstado,
        "estado": estado,
        "imprimir": imprimir,
        "ccUsuario": ccUsuario,
        "uuid": uuid,
      };
}

//* ES LA CUENTA POR COBRAR PERO CON VALIDACIONES PARA EL FORMULARIO
class CcPagoForm extends CcPago {
  // final GenericRequiredInput venRucClienteInput;
  // final Productos venProductosInput;
  // final MinValueCliente venTotalInput;

  final GenericRequiredInput ccTipoInput;
  final GenericRequiredInput ccDepositoInput;
  final GenericRequiredInputNumber ccValorInput;
  final GenericRequiredInputNumber ccNumeroInput;
  final GenericRequiredInput ccFechaAbonoInput;
  CcPagoForm({
    //*VALIDACIONES
    // required this.venRucClienteInput,
    required this.ccTipoInput,
    required this.ccDepositoInput,
    required this.ccValorInput,
    required this.ccNumeroInput,
    required this.ccFechaAbonoInput,
    //*CAMPOS NORMALES
    required super.ccComprobante,
    required super.ccTipo,
    required super.ccBanco,
    required super.ccNumero,
    required super.ccDeposito,
    required super.ccValor,
    required super.ccFechaAbono,
    required super.ccDetalle,
    required super.ccProcedencia,
    required super.ccEstado,
    required super.estado,
    required super.imprimir,
    required super.ccUsuario,
    required super.uuid,
  });

  CcPagoForm copyWith({
    //* REQUERIDOS
    // String? venRucCliente,

    //* CUENTA POR COBRAR
    String? ccComprobante,
    String? ccTipo,
    String? ccBanco,
    String? ccNumero,
    String? ccDeposito,
    double? ccValor,
    String? ccFechaAbono,
    String? ccDetalle,
    String? ccProcedencia,
    String? ccEstado,
    String? estado,
    bool? imprimir,
    String? ccUsuario,
    String? uuid,
  }) {
    final ccTipoInput =
        ccTipo != null ? GenericRequiredInput.dirty(ccTipo) : this.ccTipoInput;

    final ccDepositoInput = ccDeposito != null
        ? GenericRequiredInput.dirty(ccDeposito)
        : this.ccDepositoInput;

    final ccValorInput = ccValor != null
        ? GenericRequiredInputNumber.dirty(Parse.parseDynamicToDouble(ccValor),
            condition: true)
        : this.ccValorInput;

    final ccFechaAbonoInput = ccFechaAbono != null
        ? GenericRequiredInput.dirty(ccFechaAbono)
        : this.ccFechaAbonoInput;

    final ccNumeroInput = ccNumero != null
        ? GenericRequiredInputNumber.dirty(Parse.parseDynamicToDouble(ccNumero),
            condition: ccTipo == 'EFECTIVO')
        : this.ccNumeroInput;

    return CcPagoForm(
      // //*REQUERIDOS
      ccTipoInput: ccTipoInput,
      ccDepositoInput: ccDepositoInput,
      ccValorInput: ccValorInput,
      ccFechaAbonoInput: ccFechaAbonoInput,
      ccNumeroInput: ccNumeroInput,
      //*SUS EQUIVALENTES
      // venRucCliente: venRucCliente ?? this.venRucCliente,

      //* LO DEMAS
      ccComprobante: ccComprobante ?? this.ccComprobante,
      ccTipo: ccTipo ?? this.ccTipo,
      ccBanco: ccBanco ?? this.ccBanco,
      ccNumero: ccNumero ?? this.ccNumero,
      ccDeposito: ccDeposito ?? this.ccDeposito,
      ccValor: ccValor ?? this.ccValor,
      ccFechaAbono: ccFechaAbono ?? this.ccFechaAbono,
      ccDetalle: ccDetalle ?? this.ccDetalle,
      ccProcedencia: ccProcedencia ?? this.ccProcedencia,
      ccEstado: ccEstado ?? this.ccEstado,
      estado: estado ?? this.estado,
      imprimir: imprimir ?? this.imprimir,
      ccUsuario: ccUsuario ?? this.ccUsuario,
      uuid: uuid ?? this.uuid,
    );
  }

  //CONVIERTE A CUENTA POR COBRAR
  CcPago toCcPago() => CcPago(
        ccComprobante: ccComprobante,
        ccTipo: ccTipo,
        ccBanco: ccBanco,
        ccNumero: ccNumero,
        ccDeposito: ccDeposito,
        ccValor: ccValor,
        ccFechaAbono: ccFechaAbono,
        ccDetalle: ccDetalle,
        ccProcedencia: ccProcedencia,
        ccEstado: ccEstado,
        estado: estado,
        imprimir: imprimir,
        ccUsuario: ccUsuario,
        uuid: uuid,
      );

  factory CcPagoForm.fromCcPago(CcPago venta) {
    return CcPagoForm(
      ccTipoInput: GenericRequiredInput.dirty(venta.ccTipo),
      ccDepositoInput: GenericRequiredInput.dirty(venta.ccDeposito),
      ccValorInput: GenericRequiredInputNumber.dirty(
          Parse.parseDynamicToDouble(
            venta.ccValor,
          ),
          condition: true),
      ccNumeroInput: GenericRequiredInputNumber.dirty(
          Parse.parseDynamicToDouble(venta.ccNumero),
          condition: venta.ccTipo == 'EFECTIVO'),
      ccFechaAbonoInput: GenericRequiredInput.dirty(venta.ccFechaAbono),
      ccComprobante: venta.ccComprobante,
      ccTipo: venta.ccTipo,
      ccBanco: venta.ccBanco,
      ccNumero: venta.ccNumero,
      ccDeposito: venta.ccDeposito,
      ccValor: venta.ccValor,
      ccFechaAbono: venta.ccFechaAbono,
      ccDetalle: venta.ccDetalle,
      ccProcedencia: venta.ccProcedencia,
      ccEstado: venta.ccEstado,
      estado: venta.estado,
      imprimir: venta.imprimir,
      ccUsuario: venta.ccUsuario,
      uuid: venta.uuid,
    );
  }
}
