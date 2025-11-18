import 'dart:convert';

import 'package:ultrared/features/cuentas_por_cobrar/domain/entities/cc_pago.dart';
import 'package:ultrared/features/shared/helpers/parse.dart';

class CuentaPorCobrar {
  final int ccId;
  final int ventaId;
  final String ccRucCliente;
  final String ccNomCliente;
  final String ccFactura;
  final String ccFechaFactura;
  final String ccValorFactura;
  final String ccValorRetencion;
  final String ccValorAPagar;
  final String ccFechaAbono;
  final String ccEstado;
  final String ccProcedencia;
  final String ccAbono;
  final String ccSaldo;
  final String ccEmpresa;
  final String ccUser;
  final List<CcPago> ccPagos;
  final String ccFecReg;
  final String ccFecUpd;
  final String ccOtrosDetalles;
  final String ccConductor;
  final String ccObservacion;
  final String? ciudad;
  final String? sector;
  final double? totalSaldoPendienteDelTurno;
// "TotalSaldoPendienteDelTurno" -> "9.75"

  CuentaPorCobrar({
    required this.ccId,
    required this.ventaId,
    required this.ccRucCliente,
    required this.ccNomCliente,
    required this.ccFactura,
    required this.ccFechaFactura,
    required this.ccValorFactura,
    required this.ccValorRetencion,
    required this.ccValorAPagar,
    required this.ccFechaAbono,
    required this.ccEstado,
    required this.ccProcedencia,
    required this.ccAbono,
    required this.ccSaldo,
    required this.ccEmpresa,
    required this.ccUser,
    required this.ccPagos,
    required this.ccFecReg,
    required this.ccFecUpd,
    required this.ciudad,
    required this.sector,
    required this.ccOtrosDetalles,
    required this.ccConductor,
    required this.ccObservacion,
    required this.totalSaldoPendienteDelTurno,
  });

  static CuentaPorCobrar defaultCuentaPorCobrar() {
    return CuentaPorCobrar(
      ccId: 0,
      ventaId: 0,
      ccRucCliente: '',
      ccNomCliente: '',
      ccFactura: '',
      ccFechaFactura: '',
      ccValorFactura: '0',
      ccValorRetencion: '0',
      ccValorAPagar: '0',
      ccFechaAbono: '',
      ccEstado: '',
      ccProcedencia: '',
      ccAbono: '0',
      ccSaldo: '0',
      ccEmpresa: '',
      ccUser: '',
      ccPagos: [],
      ccFecReg: '',
      ccFecUpd: '',
      ccOtrosDetalles: '',
      ccConductor: '',
      ccObservacion: '',
      ciudad: null,
      sector: null,
      totalSaldoPendienteDelTurno: 0,
    );
  }

  factory CuentaPorCobrar.fromJson(Map<String, dynamic> json) =>
      CuentaPorCobrar(
        ccId: json["ccId"],
        ventaId: json["ventaId"],
        ccRucCliente: json["ccRucCliente"],
        ccNomCliente: json["ccNomCliente"],
        ccFactura: json["ccFactura"],
        ccFechaFactura: json["ccFechaFactura"],
        ccValorFactura: json["ccValorFactura"],
        ccValorRetencion: Parse.parseDynamicToString(json["ccValorRetencion"]),
        ccValorAPagar: json["ccValorAPagar"],
        ccFechaAbono: json["ccFechaAbono"],
        ccEstado: json["ccEstado"],
        ccProcedencia: json["ccProcedencia"],
        ccAbono: Parse.parseDynamicToString(json["ccAbono"]),
        ccSaldo: json["ccSaldo"],
        ccEmpresa: json["ccEmpresa"],
        ccUser: json["ccUser"],
        ccPagos:
            List<CcPago>.from(json["ccPagos"].map((x) => CcPago.fromJson(x))),
        ccFecReg: json["ccFecReg"],
        ccFecUpd: json["ccFecUpd"],
        ccOtrosDetalles: json["ccOtrosDetalles"] ?? "",
        ccConductor: json["ccConductor"] ?? "",
        ccObservacion: json["ccObservacion"] ?? "",
        ciudad: json["ciudad"],
        sector: json["sector"],
        totalSaldoPendienteDelTurno:Parse.parseDynamicToDouble( json["TotalSaldoPendienteDelTurno"]),
      );

  Map<String, dynamic> toJson() => {
        "ccId": ccId,
        "ventaId": ventaId,
        "ccRucCliente": ccRucCliente,
        "ccNomCliente": ccNomCliente,
        "ccFactura": ccFactura,
        "ccFechaFactura": ccFechaFactura,
        "ccValorFactura": ccValorFactura,
        "ccValorRetencion": ccValorRetencion,
        "ccValorAPagar": ccValorAPagar,
        "ccFechaAbono": ccFechaAbono,
        "ccEstado": ccEstado,
        "ccProcedencia": ccProcedencia,
        "ccAbono": ccAbono,
        "ccSaldo": ccSaldo,
        "ccEmpresa": ccEmpresa,
        "ccUser": ccUser,
        "ccPagos": List<dynamic>.from(ccPagos.map((x) => x.toJson())),
        "ccFecReg": ccFecReg,
        "ccFecUpd": ccFecUpd,
        "ccOtrosDetalles": ccOtrosDetalles,
        "ccConductor": ccConductor,
        "ccObservacion": ccObservacion,
        "ciudad": ciudad,
        "sector": sector,
        "TotalSaldoPendienteDelTurno": totalSaldoPendienteDelTurno,
      };
}

class BusquedaCuentasPorCobrar {
  final String ccFactura;
  final String ccProcedencia;
  final String ccEstado;
  final String ccFechaFactura1;
  final String ccFechaFactura2;
  final String ccFecReg1;
  final String ccFecReg2;

  const BusquedaCuentasPorCobrar({
    this.ccFactura = '',
    this.ccProcedencia = '',
    this.ccEstado = '',
    this.ccFechaFactura1 = '',
    this.ccFechaFactura2 = '',
    this.ccFecReg1 = '',
    this.ccFecReg2 = '',
  });

  factory BusquedaCuentasPorCobrar.fromJson(Map<String, dynamic> json) =>
      BusquedaCuentasPorCobrar(
        ccFactura: json["ccFactura"],
        ccProcedencia: json["ccProcedencia"],
        ccEstado: json["ccEstado"],
        ccFechaFactura1: json["ccFechaFactura1"],
        ccFechaFactura2: json["ccFechaFactura2"],
        ccFecReg1: json["ccFecReg1"],
        ccFecReg2: json["ccFecReg2"],
      );

  Map<String, dynamic> toJson() => {
        "ccFactura": ccFactura,
        "ccProcedencia": ccProcedencia,
        "ccEstado": ccEstado,
        "ccFechaFactura1": ccFechaFactura1,
        "ccFechaFactura2": ccFechaFactura2,
        "ccFecReg1": ccFecReg1,
        "ccFecReg2": ccFecReg2,
      };

  BusquedaCuentasPorCobrar copyWith({
    String? ccFactura,
    String? ccProcedencia,
    String? ccEstado,
  }) {
    return BusquedaCuentasPorCobrar(
      ccFactura: ccFactura ?? this.ccFactura,
      ccProcedencia: ccProcedencia ?? this.ccProcedencia,
      ccEstado: ccEstado ?? this.ccEstado,
      ccFechaFactura1: ccFechaFactura1,
      ccFechaFactura2: ccFechaFactura2,
      ccFecReg1: ccFecReg1,
      ccFecReg2: ccFecReg2,
    );
  }

  bool isSearching() {
    return ccFactura.isNotEmpty ||
        ccProcedencia.isNotEmpty ||
        ccEstado.isNotEmpty ||
        ccFechaFactura1.isNotEmpty ||
        ccFechaFactura2.isNotEmpty ||
        ccFecReg1.isNotEmpty ||
        ccFecReg2.isNotEmpty;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

//* ES LA CUENTA POR COBRAR PERO CON VALIDACIONES PARA EL FORMULARIO
class CuentaPorCobrarForm extends CuentaPorCobrar {
  // final GenericRequiredInput venRucClienteInput;
  // final Productos venProductosInput;
  // final MinValueCliente venTotalInput;
  CuentaPorCobrarForm({
    //*VALIDACIONES
    // required this.venRucClienteInput,
    // required this.venProductosInput,
    // required this.venTotalInput,
    //*CAMPOS NORMALES
    required super.ccId,
    required super.ventaId,
    required super.ccRucCliente,
    required super.ccNomCliente,
    required super.ccFactura,
    required super.ccFechaFactura,
    required super.ccValorFactura,
    required super.ccValorRetencion,
    required super.ccValorAPagar,
    required super.ccFechaAbono,
    required super.ccEstado,
    required super.ccProcedencia,
    required super.ccAbono,
    required super.ccSaldo,
    required super.ccEmpresa,
    required super.ccUser,
    required super.ccPagos,
    required super.ccFecReg,
    required super.ccFecUpd,
    required super.ccOtrosDetalles,
    required super.ccConductor,
    required super.ccObservacion,
    super.ciudad,
    super.sector,
    super.totalSaldoPendienteDelTurno,
  });

  CuentaPorCobrarForm copyWith({
    //* REQUERIDOS
    // String? venRucCliente,

    //* CUENTA POR COBRAR
    int? ccId,
    int? ventaId,
    String? ccRucCliente,
    String? ccNomCliente,
    String? ccFactura,
    String? ccFechaFactura,
    String? ccValorFactura,
    String? ccValorRetencion,
    String? ccValorAPagar,
    String? ccFechaAbono,
    String? ccEstado,
    String? ccProcedencia,
    String? ccAbono,
    String? ccSaldo,
    String? ccEmpresa,
    String? ccUser,
    List<CcPago>? ccPagos,
    String? ccFecReg,
    String? ccFecUpd,
    String? ccOtrosDetalles,
    String? ccConductor,
    String? ccObservacion,
    String? ciudad,
    String? sector,
  }) {
    // final venRucClienteInput = venRucCliente != null
    //     ? GenericRequiredInput.dirty(venRucCliente)
    //     : this.venRucClienteInput;

    return CuentaPorCobrarForm(
      // //*REQUERIDOS
      // venRucClienteInput: venRucClienteInput,

      //*SUS EQUIVALENTES
      // venRucCliente: venRucCliente ?? this.venRucCliente,

      //* LO DEMAS
      ccId: ccId ?? this.ccId,
      ventaId: ventaId ?? this.ventaId,
      ccRucCliente: ccRucCliente ?? this.ccRucCliente,
      ccNomCliente: ccNomCliente ?? this.ccNomCliente,
      ccFactura: ccFactura ?? this.ccFactura,
      ccFechaFactura: ccFechaFactura ?? this.ccFechaFactura,
      ccValorFactura: ccValorFactura ?? this.ccValorFactura,
      ccValorRetencion: ccValorRetencion ?? this.ccValorRetencion,
      ccValorAPagar: ccValorAPagar ?? this.ccValorAPagar,
      ccFechaAbono: ccFechaAbono ?? this.ccFechaAbono,
      ccEstado: ccEstado ?? this.ccEstado,
      ccProcedencia: ccProcedencia ?? this.ccProcedencia,
      ccAbono: ccAbono ?? this.ccAbono,
      ccSaldo: ccSaldo ?? this.ccSaldo,
      ccEmpresa: ccEmpresa ?? this.ccEmpresa,
      ccUser: ccUser ?? this.ccUser,
      ccPagos: ccPagos ?? this.ccPagos,
      ccFecReg: ccFecReg ?? this.ccFecReg,
      ccFecUpd: ccFecUpd ?? this.ccFecUpd,
      ccOtrosDetalles: ccOtrosDetalles ?? this.ccOtrosDetalles,
      ccConductor: ccConductor ?? this.ccConductor,
      ccObservacion: ccObservacion ?? this.ccObservacion,

      //*POSIBLES NULOS
      // venOtros: venOtros ?? this.venOtros,
      ciudad: ciudad ?? this.ciudad,
      sector: sector ?? this.sector,
    );
  }

  //CONVIERTE A CUENTA POR COBRAR
  CuentaPorCobrar toCuentaPorCobrar() => CuentaPorCobrar(
        ccId: ccId,
        ventaId: ventaId,
        ccRucCliente: ccRucCliente,
        ccNomCliente: ccNomCliente,
        ccFactura: ccFactura,
        ccFechaFactura: ccFechaFactura,
        ccValorFactura: ccValorFactura,
        ccValorRetencion: ccValorRetencion,
        ccValorAPagar: ccValorAPagar,
        ccFechaAbono: ccFechaAbono,
        ccEstado: ccEstado,
        ccProcedencia: ccProcedencia,
        ccAbono: ccAbono,
        ccSaldo: ccSaldo,
        ccEmpresa: ccEmpresa,
        ccUser: ccUser,
        ccPagos: ccPagos,
        ccFecReg: ccFecReg,
        ccFecUpd: ccFecUpd,
        ccOtrosDetalles: ccOtrosDetalles,
        ccConductor: ccConductor,
        ccObservacion: ccObservacion,
        ciudad: ciudad,
        sector: sector,
        totalSaldoPendienteDelTurno: totalSaldoPendienteDelTurno,
      );

  factory CuentaPorCobrarForm.fromCuentaPorCobrar(CuentaPorCobrar venta) {
    return venta.ccId == 0
        ? CuentaPorCobrarForm(
            // venTotalInput: const MinValueCliente.pure(),

            ccId: venta.ccId,
            ventaId: venta.ventaId,
            ccRucCliente: venta.ccRucCliente,
            ccNomCliente: venta.ccNomCliente,
            ccFactura: venta.ccFactura,
            ccFechaFactura: venta.ccFechaFactura,
            ccValorFactura: venta.ccValorFactura,
            ccValorRetencion: venta.ccValorRetencion,
            ccValorAPagar: venta.ccValorAPagar,
            ccFechaAbono: venta.ccFechaAbono,
            ccEstado: venta.ccEstado,
            ccProcedencia: venta.ccProcedencia,
            ccAbono: venta.ccAbono,
            ccSaldo: venta.ccSaldo,
            ccEmpresa: venta.ccEmpresa,
            ccUser: venta.ccUser,
            ccPagos: venta.ccPagos,
            ccFecReg: venta.ccFecReg,
            ccFecUpd: venta.ccFecUpd,
            ccOtrosDetalles: venta.ccOtrosDetalles,
            ccConductor: venta.ccConductor,
            ccObservacion: venta.ccObservacion,
            ciudad: venta.ciudad,
            sector: venta.sector,
          )
        : CuentaPorCobrarForm(
            // venRucClienteInput: GenericRequiredInput.dirty(venta.venRucCliente),
            ccId: venta.ccId,
            ventaId: venta.ventaId,
            ccRucCliente: venta.ccRucCliente,
            ccNomCliente: venta.ccNomCliente,
            ccFactura: venta.ccFactura,
            ccFechaFactura: venta.ccFechaFactura,
            ccValorFactura: venta.ccValorFactura,
            ccValorRetencion: venta.ccValorRetencion,
            ccValorAPagar: venta.ccValorAPagar,
            ccFechaAbono: venta.ccFechaAbono,
            ccEstado: venta.ccEstado,
            ccProcedencia: venta.ccProcedencia,
            ccAbono: venta.ccAbono,
            ccSaldo: venta.ccSaldo,
            ccEmpresa: venta.ccEmpresa,
            ccUser: venta.ccUser,
            ccPagos: venta.ccPagos,
            ccFecReg: venta.ccFecReg,
            ccFecUpd: venta.ccFecUpd,
            ccOtrosDetalles: venta.ccOtrosDetalles,
            ccConductor: venta.ccConductor,
            ccObservacion: venta.ccObservacion,
            ciudad: venta.ciudad,
            sector: venta.sector,
          );
  }
}
