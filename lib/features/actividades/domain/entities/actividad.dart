import 'dart:convert';

import 'package:ultrared/features/actividades/domain/entities/cargo.dart';
import 'package:ultrared/features/actividades/domain/entities/equipo_instalado.dart';
import 'package:ultrared/features/actividades/domain/entities/ubicacion.dart';
import 'package:ultrared/features/shared/domain/entities/imagen.dart';
import 'package:ultrared/features/shared/helpers/get_date.dart';
import 'package:ultrared/features/shared/helpers/parse.dart';

class Actividad {
  int actaId;
  int actaIdCliente;
  int actaIdPersonaEntrega;
  int actaIdVendedor;
  String actaFecha;
  String actaFechaInstalacion;
  String actaOpcion;
  String actaEstado;
  String actaDetalleEstado;
  String actaTipo;
  String actaSeEncuentraCliente;
  String actaServiciosVisita;
  String actaRedWifi;
  String actaClave;
  String actaClienteRegulador;
  List<Imagen> actaFotos;
  Ubicacion actaUbicacion;
  List<EquipoInstalado> actaEquiposInstalados;
  List<Cargo> actaCargosAdicionales;
  String actaConfigRouter;
  String actaValorRouter;
  String actaCambioPatch;
  String actaValorPatch;
  String actaCalidadIns;
  String actaSolucionReq;
  String actaRecNombre;
  String actaRecFirma;
  String actaEntFirma;
  String actaUser;
  String actaEmpresa;
  int actaIdPlanInternet;
  String actaCiudad;
  List<String> actaSector;
  String actaFecReg;
  String actaFecUpd;
  String actaDocCliente;
  String actaNombreCliente;
  String actaDireccionCliente;
  List<String> actaTelCliente;
  List<String> actaEmailCliente;
  String actaEntDoc;
  String actaEntNombre;
  String actaDocVendedor;
  String actaNombreVendedor;
  String planNombreInternet;
  String planValorInternet;
  String planMegasInternet;
  String correoNuevoRegistro;

  Actividad({
    required this.actaId,
    required this.actaIdCliente,
    required this.actaIdPersonaEntrega,
    required this.actaIdVendedor,
    required this.actaFecha,
    required this.actaFechaInstalacion,
    required this.actaOpcion,
    required this.actaEstado,
    required this.actaDetalleEstado,
    required this.actaTipo,
    required this.actaSeEncuentraCliente,
    required this.actaServiciosVisita,
    required this.actaRedWifi,
    required this.actaClave,
    required this.actaClienteRegulador,
    required this.actaFotos,
    required this.actaUbicacion,
    required this.actaEquiposInstalados,
    required this.actaCargosAdicionales,
    required this.actaConfigRouter,
    required this.actaValorRouter,
    required this.actaCambioPatch,
    required this.actaValorPatch,
    required this.actaCalidadIns,
    required this.actaSolucionReq,
    required this.actaRecNombre,
    required this.actaRecFirma,
    required this.actaEntFirma,
    required this.actaUser,
    required this.actaEmpresa,
    required this.actaIdPlanInternet,
    required this.actaCiudad,
    required this.actaSector,
    required this.actaFecReg,
    required this.actaFecUpd,
    required this.actaDocCliente,
    required this.actaNombreCliente,
    required this.actaDireccionCliente,
    required this.actaTelCliente,
    required this.actaEmailCliente,
    required this.actaEntDoc,
    required this.actaEntNombre,
    required this.actaDocVendedor,
    required this.actaNombreVendedor,
    required this.planNombreInternet,
    required this.planValorInternet,
    required this.planMegasInternet,
    required this.correoNuevoRegistro,
  });
  static Actividad defaultActividad() {
    return Actividad(
      actaId: 0,
      actaIdCliente: 0,
      actaIdPersonaEntrega: 0,
      actaFecha: GetDate.today,
      // actaInstalacionFibra: "EMPRESARIAL",
      // actaVisitaTecnica: "EMPRESARIAL",
      actaServiciosVisita: "TRASLADOS",
      actaOpcion: "Nueva Instalación", // | Visita Técnica
      actaTipo: "HOME", //EMPRESARIAL "CORPORATIVO", "HOME"
      actaSeEncuentraCliente: "SI", // | NO
      actaCiudad: "",
      actaSector: [],
      actaFechaInstalacion: GetDate.today,
      actaRedWifi: "",
      actaClave: "",
      actaClienteRegulador: "NO",
      actaConfigRouter: "NO",
      actaCambioPatch: "NO",
      actaCalidadIns: "",
      actaSolucionReq: "MUY BUENO",
      actaRecNombre: "",
      actaRecFirma: "",
      actaEntFirma: "",
      actaUser: "",
      actaEmpresa: "",
      actaFecUpd: '',
      actaFecReg: "",
      actaDocCliente: "",
      actaNombreCliente: "",
      actaDireccionCliente: "",
      // actaRecDoc: "",
      actaEntNombre: "",
      actaEntDoc: "",
      actaFotos: [],
      actaEquiposInstalados: [],
      actaCargosAdicionales: [],
      actaTelCliente: [],
      actaEmailCliente: [],
      actaEstado: "PENDIENTE", // ANULADO 'PENDIENTE', 'PROCESADO' ,'EN PROCESO'
      actaValorRouter: "0",
      actaValorPatch: "0",
      actaDetalleEstado: "",
      actaIdVendedor: 0,
      actaDocVendedor: "",
      actaNombreVendedor: "",
      planNombreInternet: "",
      planValorInternet: "",
      planMegasInternet: "",
      correoNuevoRegistro: '',
      actaIdPlanInternet: 0,
      actaUbicacion: Ubicacion(longitud: 0, latitud: 0),
    );
  }

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      actaId: json["actaId"],
      actaIdCliente: json["actaIdCliente"],
      actaIdPersonaEntrega: json["actaIdPersonaEntrega"],
      actaIdVendedor: json["actaIdVendedor"],
      actaFecha: json["actaFecha"],
      actaFechaInstalacion: json["actaFechaInstalacion"],
      actaOpcion: json["actaOpcion"],
      actaEstado: json["actaEstado"],
      actaDetalleEstado: json["actaDetalleEstado"],
      actaTipo: json["actaTipo"],
      actaSeEncuentraCliente: json["actaSeEncuentraCliente"],
      actaServiciosVisita: json["actaServiciosVisita"],
      actaRedWifi: json["actaRedWifi"],
      actaClave: json["actaClave"],
      actaClienteRegulador: json["actaClienteRegulador"],
      actaFotos: List<Imagen>.from(json["actaFotos"].map((x) => x != null
              ? Imagen.fromJson(x)
              : Imagen(nombre: 'no-name', url: '')))
          .where((x) => x.url.isNotEmpty)
          .toList(),
      actaUbicacion: Ubicacion.fromJson(json["actaUbicacion"]),
      actaEquiposInstalados:
          List<EquipoInstalado>.from(json["actaEquiposInstalados"].map((x) => x)),
      actaCargosAdicionales:
          List<Cargo>.from(json["actaCargosAdicionales"].map((x) => x)),
      actaConfigRouter: json["actaConfigRouter"],
      actaValorRouter: json["actaValorRouter"],
      actaCambioPatch: json["actaCambioPatch"],
      actaValorPatch: json["actaValorPatch"],
      actaCalidadIns: json["actaCalidadIns"],
      actaSolucionReq: json["actaSolucionReq"],
      actaRecNombre: json["actaRecNombre"],
      actaRecFirma: json["actaRecFirma"],
      actaEntFirma: json["actaEntFirma"],
      actaUser: json["actaUser"],
      actaEmpresa: json["actaEmpresa"],
      actaIdPlanInternet: json["actaIdPlanInternet"],
      actaCiudad: json["actaCiudad"] ?? '',
      actaSector: Parse.parseDynamicToListString(json["actaSector"]),
      actaFecReg: json["actaFecReg"],
      actaFecUpd: json["actaFecUpd"],
      actaDocCliente: json["actaDocCliente"],
      actaNombreCliente: json["actaNombreCliente"],
      actaDireccionCliente: json["actaDireccionCliente"],
      actaTelCliente: List<String>.from(json["actaTelCliente"].map((x) => x)),
      actaEmailCliente:
          List<String>.from(json["actaEmailCliente"].map((x) => x)),
      actaEntDoc: json["actaEntDoc"],
      actaEntNombre: json["actaEntNombre"],
      actaDocVendedor: json["actaDocVendedor"] ?? '',
      actaNombreVendedor: json["actaNombreVendedor"] ?? '',
      planNombreInternet:
          Parse.parseDynamicToString(json["planNombreInternet"]),
      planValorInternet: Parse.parseDynamicToString(json["planValorInternet"]),
      planMegasInternet: Parse.parseDynamicToString(json["planMegasInternet"]),
      correoNuevoRegistro: json["correo_nuevo_registro"] ?? '',
    );
  }

  // Nuevo método copyWith
  Actividad copyWith({
    int? actaId,
    int? actaIdCliente,
    int? actaIdPersonaEntrega,
    int? actaIdVendedor,
    String? actaFecha,
    String? actaFechaInstalacion,
    String? actaOpcion,
    String? actaEstado,
    String? actaDetalleEstado,
    String? actaTipo,
    String? actaSeEncuentraCliente,
    String? actaServiciosVisita,
    String? actaRedWifi,
    String? actaClave,
    String? actaClienteRegulador,
    List<Imagen>? actaFotos,
    Ubicacion? actaUbicacion,
    List<EquipoInstalado>? actaEquiposInstalados,
    List<Cargo>? actaCargosAdicionales,
    String? actaConfigRouter,
    String? actaValorRouter,
    String? actaCambioPatch,
    String? actaValorPatch,
    String? actaCalidadIns,
    String? actaSolucionReq,
    String? actaRecNombre,
    String? actaRecFirma,
    String? actaEntFirma,
    String? actaUser,
    String? actaEmpresa,
    int? actaIdPlanInternet,
    String? actaCiudad,
    List<String>? actaSector,
    String? actaFecReg,
    String? actaFecUpd,
    String? actaDocCliente,
    String? actaNombreCliente,
    String? actaDireccionCliente,
    List<String>? actaTelCliente,
    List<String>? actaEmailCliente,
    String? actaEntDoc,
    String? actaEntNombre,
    String? actaDocVendedor,
    String? actaNombreVendedor,
    String? planNombreInternet,
    String? planValorInternet,
    String? planMegasInternet,
    String? correoNuevoRegistro,
  }) {
    return Actividad(
      actaId: actaId ?? this.actaId,
      actaIdCliente: actaIdCliente ?? this.actaIdCliente,
      actaIdPersonaEntrega: actaIdPersonaEntrega ?? this.actaIdPersonaEntrega,
      actaIdVendedor: actaIdVendedor ?? this.actaIdVendedor,
      actaFecha: actaFecha ?? this.actaFecha,
      actaFechaInstalacion: actaFechaInstalacion ?? this.actaFechaInstalacion,
      actaOpcion: actaOpcion ?? this.actaOpcion,
      actaEstado: actaEstado ?? this.actaEstado,
      actaDetalleEstado: actaDetalleEstado ?? this.actaDetalleEstado,
      actaTipo: actaTipo ?? this.actaTipo,
      actaSeEncuentraCliente:
          actaSeEncuentraCliente ?? this.actaSeEncuentraCliente,
      actaServiciosVisita: actaServiciosVisita ?? this.actaServiciosVisita,
      actaRedWifi: actaRedWifi ?? this.actaRedWifi,
      actaClave: actaClave ?? this.actaClave,
      actaClienteRegulador: actaClienteRegulador ?? this.actaClienteRegulador,
      actaFotos: actaFotos ?? this.actaFotos,
      actaUbicacion: actaUbicacion ?? this.actaUbicacion,
      actaEquiposInstalados:
          actaEquiposInstalados ?? this.actaEquiposInstalados,
      actaCargosAdicionales:
          actaCargosAdicionales ?? this.actaCargosAdicionales,
      actaConfigRouter: actaConfigRouter ?? this.actaConfigRouter,
      actaValorRouter: actaValorRouter ?? this.actaValorRouter,
      actaCambioPatch: actaCambioPatch ?? this.actaCambioPatch,
      actaValorPatch: actaValorPatch ?? this.actaValorPatch,
      actaCalidadIns: actaCalidadIns ?? this.actaCalidadIns,
      actaSolucionReq: actaSolucionReq ?? this.actaSolucionReq,
      actaRecNombre: actaRecNombre ?? this.actaRecNombre,
      actaRecFirma: actaRecFirma ?? this.actaRecFirma,
      actaEntFirma: actaEntFirma ?? this.actaEntFirma,
      actaUser: actaUser ?? this.actaUser,
      actaEmpresa: actaEmpresa ?? this.actaEmpresa,
      actaIdPlanInternet: actaIdPlanInternet ?? this.actaIdPlanInternet,
      actaCiudad: actaCiudad ?? this.actaCiudad,
      actaSector: actaSector ?? this.actaSector,
      actaFecReg: actaFecReg ?? this.actaFecReg,
      actaFecUpd: actaFecUpd ?? this.actaFecUpd,
      actaDocCliente: actaDocCliente ?? this.actaDocCliente,
      actaNombreCliente: actaNombreCliente ?? this.actaNombreCliente,
      actaDireccionCliente: actaDireccionCliente ?? this.actaDireccionCliente,
      actaTelCliente: actaTelCliente ?? this.actaTelCliente,
      actaEmailCliente: actaEmailCliente ?? this.actaEmailCliente,
      actaEntDoc: actaEntDoc ?? this.actaEntDoc,
      actaEntNombre: actaEntNombre ?? this.actaEntNombre,
      actaDocVendedor: actaDocVendedor ?? this.actaDocVendedor,
      actaNombreVendedor: actaNombreVendedor ?? this.actaNombreVendedor,
      planNombreInternet: planNombreInternet ?? this.planNombreInternet,
      planValorInternet: planValorInternet ?? this.planValorInternet,
      planMegasInternet: planMegasInternet ?? this.planMegasInternet,
      correoNuevoRegistro: correoNuevoRegistro ?? this.correoNuevoRegistro,
    );
  }

  Map<String, dynamic> toJson() => {
        "actaId": actaId,
        "actaIdCliente": actaIdCliente,
        "actaIdPersonaEntrega": actaIdPersonaEntrega,
        "actaIdVendedor": actaIdVendedor,
        "actaFecha": actaFecha,
        "actaFechaInstalacion": actaFechaInstalacion,
        "actaOpcion": actaOpcion,
        "actaEstado": actaEstado,
        "actaDetalleEstado": actaDetalleEstado,
        "actaTipo": actaTipo,
        "actaSeEncuentraCliente": actaSeEncuentraCliente,
        "actaServiciosVisita": actaServiciosVisita,
        "actaRedWifi": actaRedWifi,
        "actaClave": actaClave,
        "actaClienteRegulador": actaClienteRegulador,
        "actaFotos": List<dynamic>.from(actaFotos.map((x) => x.toJson())),
        "actaUbicacion": actaUbicacion.toJson(),
        "actaEquiposInstalados":
            List<dynamic>.from(actaEquiposInstalados.map((x) => x)),
        "actaCargosAdicionales":
            List<Cargo>.from(actaCargosAdicionales.map((x) => x)),
        "actaConfigRouter": actaConfigRouter,
        "actaValorRouter": actaValorRouter,
        "actaCambioPatch": actaCambioPatch,
        "actaValorPatch": actaValorPatch,
        "actaCalidadIns": actaCalidadIns,
        "actaSolucionReq": actaSolucionReq,
        "actaRecNombre": actaRecNombre,
        "actaRecFirma": actaRecFirma,
        "actaEntFirma": actaEntFirma,
        "actaUser": actaUser,
        "actaEmpresa": actaEmpresa,
        "actaIdPlanInternet": actaIdPlanInternet,
        "actaCiudad": actaCiudad,
        "actaSector": List<dynamic>.from(actaSector.map((x) => x)),
        "actaFecReg": actaFecReg,
        "actaFecUpd": actaFecUpd,
        "actaDocCliente": actaDocCliente,
        "actaNombreCliente": actaNombreCliente,
        "actaDireccionCliente": actaDireccionCliente,
        "actaTelCliente": List<dynamic>.from(actaTelCliente.map((x) => x)),
        "actaEmailCliente": List<dynamic>.from(actaEmailCliente.map((x) => x)),
        "actaEntDoc": actaEntDoc,
        "actaEntNombre": actaEntNombre,
        "actaDocVendedor": actaDocVendedor,
        "actaNombreVendedor": actaNombreVendedor,
        "planNombreInternet": planNombreInternet,
        "planValorInternet": planValorInternet,
        "planMegasInternet": planMegasInternet,
        "correo_nuevo_registro": planMegasInternet,
      };
}

class BusquedaActividades {
  final String actaDocCliente;
  const BusquedaActividades({
    this.actaDocCliente = '',
  });

  factory BusquedaActividades.fromJson(Map<String, dynamic> json) =>
      BusquedaActividades(
        actaDocCliente: json["actaDocCliente"],
      );

  Map<String, dynamic> toJson() => {
        "actaDocCliente": actaDocCliente,
      };

  BusquedaActividades copyWith({
    String? actaDocCliente,
    String? ccProcedencia,
    String? ccEstado,
  }) {
    return BusquedaActividades(
      actaDocCliente: actaDocCliente ?? this.actaDocCliente,
    );
  }

  bool isSearching() {
    return actaDocCliente.isNotEmpty;
    // ccProcedencia.isNotEmpty ||
    // ccEstado.isNotEmpty ||
    // ccFechaFactura1.isNotEmpty ||
    // ccFechaFactura2.isNotEmpty ||
    // ccFecReg1.isNotEmpty ||
    // ccFecReg2.isNotEmpty;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
