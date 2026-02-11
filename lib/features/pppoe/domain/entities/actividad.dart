import 'dart:convert';

class ValidacionConexion {
  String? actaCiudad;
  bool isValid;

  ValidacionConexion({
    this.actaCiudad,
    this.isValid = true,
  });

  ValidacionConexion copyWith({
    String? actaCiudad,
    bool? isValid,
  }) {
    return ValidacionConexion(
      actaCiudad: actaCiudad ?? this.actaCiudad,
      isValid: isValid ?? this.isValid,
    );
  }

  ValidacionConexion validar(Conexion conexion) {
    // actaCiudad = Validacion.campoRequerido(conexion.actaCiudad);

    isValid = ![
      actaCiudad,
    ].any((error) => error != null);

    return copyWith();
  }
}

// To parse this JSON data, do
//
//     final conexion = conexionFromJson(jsonString);

class Conexion {
  final String? id;
  final String name;
  final String service;
  final String callerId;
  final String comment;
  final String profile;
  final String lastLoggedOut;
  final String disabled;
  final String address;
  final String startedAtIso;
  final String uptimeDhms;
  final String localAdress;
  static Conexion defaultConexion() {
    return Conexion(
      name: "",
      service: "",
      callerId: "",
      comment: "",
      profile: "",
      lastLoggedOut: "",
      disabled: "",
      address: "",
      startedAtIso: "",
      uptimeDhms: "",
      localAdress: "",
    );
  }

  Conexion({
    this.id = '',
    required this.name,
    required this.service,
    required this.callerId,
    required this.comment,
    required this.profile,
    required this.lastLoggedOut,
    required this.disabled,
    required this.address,
    required this.startedAtIso,
    required this.uptimeDhms,
    required this.localAdress,
  });

  Conexion copyWith({
    String? id,
    String? name,
    String? service,
    String? callerId,
    String? comment,
    String? profile,
    String? lastLoggedOut,
    String? disabled,
    String? address,
    String? startedAtIso,
    String? uptimeDhms,
    String? localAdress,
  }) =>
      Conexion(
        id: id ?? this.id,
        name: name ?? this.name,
        service: service ?? this.service,
        callerId: callerId ?? this.callerId,
        comment: comment ?? this.comment,
        profile: profile ?? this.profile,
        lastLoggedOut: lastLoggedOut ?? this.lastLoggedOut,
        disabled: disabled ?? this.disabled,
        address: address ?? this.address,
        startedAtIso: startedAtIso ?? this.startedAtIso,
        uptimeDhms: uptimeDhms ?? this.uptimeDhms,
        localAdress: localAdress ?? this.localAdress,
      );

  factory Conexion.fromJson(Map<String, dynamic> json) => Conexion(
        id: json[".id"],
        name: json["name"],
        service: json["service"],
        callerId: json["caller-id"],
        comment: json["comment"] ?? '',
        profile: json["profile"] ?? '',
        lastLoggedOut: json["last-logged-out"] ?? '',
        disabled: json["disabled"] ?? "",
        address: json["address"] ?? "",
        startedAtIso: json["started_at_iso"] ?? '',
        uptimeDhms: json["uptime_dhms"] ?? '',
        localAdress: json["local-address"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        ".id": id,
        "name": name,
        "service": service,
        "caller-id": callerId,
        "comment": comment,
        "profile": profile,
        "last-logged-out": lastLoggedOut,
        "disabled": disabled,
        "address": address,
        "started_at_iso": startedAtIso,
        "uptime_dhms": uptimeDhms,
        "local-address": localAdress,
      };
}

class BusquedaConexiones {
  final String actaDocCliente;
  const BusquedaConexiones({
    this.actaDocCliente = '',
  });

  factory BusquedaConexiones.fromJson(Map<String, dynamic> json) =>
      BusquedaConexiones(
        actaDocCliente: json["actaDocCliente"],
      );

  Map<String, dynamic> toJson() => {
        "actaDocCliente": actaDocCliente,
      };

  BusquedaConexiones copyWith({
    String? actaDocCliente,
    String? ccProcedencia,
    String? ccEstado,
  }) {
    return BusquedaConexiones(
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
