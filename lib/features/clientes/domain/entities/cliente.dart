import 'package:ultrared/features/shared/helpers/parse.dart';

class Persona {
  final String perNombreComercial;
  final List<String> perEmpresa;
  final String perPais;
  final String perProvincia;
  final String perCanton;
  final String perTipoProveedor;
  final String perTiempoCredito;
  final String perDocTipo;
  final String perDocNumero;
  final List<String> perPerfil;
  final String perNombre;
  final String perDireccion;
  final String perObligado;
  final String perCredito;
  final String perTelefono;
  final List<String> perCelular;
  final String perEstado;
  final String perObsevacion;
  final List<String> perEmail;
  final List<String> perOtros;
  final String? perNickname;
  final String perUser;
  final String? perFoto;
  final PerUbicacion? perUbicacion;
  final String perDocumento;
  final String? perGenero;
  final String? perRecomendacion;
  final String perFecNacimiento;
  final String? perEspecialidad;
  final String perTitulo;
  final String perSenescyt;
  final String perPersonal;
  final int perId;
  final String perCodigo;
  final String perUsuario;
  final int? perOnline;
  final int? perSaldo;
  final String perFecReg;
  final String perFecUpd;
  final PerPermisos? perPermisos;  
  final String perCompra;
  final String ciudad;
  final String sector;
  Persona({
    required this.perNombreComercial,
    required this.perEmpresa,
    required this.perPais,
    required this.perProvincia,
    required this.perCanton,
    required this.perTipoProveedor,
    required this.perTiempoCredito,
    required this.perDocTipo,
    required this.perDocNumero,
    required this.perPerfil,
    required this.perNombre,
    required this.perDireccion,
    required this.perObligado,
    required this.perCredito,
    required this.perTelefono,
    required this.perCelular,
    required this.perEstado,
    required this.perObsevacion,
    required this.perEmail,
    required this.perOtros,
    required this.perNickname,
    required this.perUser,
    required this.perFoto,
      this.perUbicacion,
    required this.perDocumento,
    required this.perGenero,
    required this.perRecomendacion,
    required this.perFecNacimiento,
    required this.perEspecialidad,
    required this.perTitulo,
    required this.perSenescyt,
    required this.perPersonal,
    required this.perId,
    required this.perCodigo,
    required this.perUsuario,
    required this.perOnline,
    required this.perSaldo,
    required this.perFecReg,
    required this.ciudad,
    required this.sector,

    required this.perFecUpd, 
    required this.perCompra,
    this.perPermisos,
     
  });

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        perNombreComercial: json["perNombreComercial"] ?? '',
        perEmpresa: List<String>.from(
            Parse.parseDynamicToListString(json["perEmpresa"]).map((x) => x)),
        perPais: json["perPais"],
        perProvincia: json["perProvincia"],
        perCanton: json["perCanton"],
        perTipoProveedor: json["perTipoProveedor"],
        perTiempoCredito: Parse.parseDynamicToString(json["perTiempoCredito"]),
        perDocTipo: json["perDocTipo"],
        perDocNumero: json["perDocNumero"],
        perPerfil: List<String>.from(json["perPerfil"].map((x) => x)),
        perNombre: json["perNombre"],
        perDireccion: json["perDireccion"],
        perObligado: json["perObligado"],
        perCredito: json["perCredito"],
        perTelefono: json["perTelefono"],
        perCelular: List<String>.from(json["perCelular"].map((x) => x)),
        perEstado: json["perEstado"],
        perObsevacion: json["perObsevacion"],
        perEmail: List<String>.from(json["perEmail"].map((x) => x)),
        perOtros: List<String>.from(json["perOtros"].map((x) => x)),
        perNickname: json["perNickname"],
        perUser: json["perUser"],
        perFoto: json["perFoto"],
        perUbicacion: PerUbicacion.fromJson(json["perUbicacion"]),
        perDocumento: json["perDocumento"],
        perGenero: json["perGenero"],
        perRecomendacion: json["perRecomendacion"],
        perFecNacimiento: json["perFecNacimiento"] ?? '',
        perEspecialidad: json["perEspecialidad"],
        perTitulo: json["perTitulo"],
        perSenescyt: json["perSenescyt"],
        perPersonal: json["perPersonal"],
        perId: json["perId"] == "" ? 0 : json["perId"],
        perCodigo: json["perCodigo"] ?? '',
        perUsuario: json["perUsuario"] ?? '',
        perOnline: json["perOnline"],
        perSaldo: Parse.parseDynamicToInt(json["perSaldo"]),
        perFecReg: json["perFecReg"] ?? '',
        ciudad: json["ciudad"] ?? '',
        sector: json["sector"] ?? '',
        perFecUpd: json["perFecUpd"] ?? '',  
        perCompra: Parse.parseDynamicToString(json["perCompra"]),
        perPermisos: PerPermisos.fromJson(json["perPermisos"]), 
      );

  Map<String, dynamic> toJson() => {
        "perNombreComercial": perNombreComercial,
        "perEmpresa": List<dynamic>.from(perEmpresa.map((x) => x)),
        "perPais": perPais,
        "perProvincia": perProvincia,
        "perCanton": perCanton,
        "perTipoProveedor": perTipoProveedor,
        "perTiempoCredito": perTiempoCredito,
        "perDocTipo": perDocTipo,
        "perDocNumero": perDocNumero,
        "perPerfil": List<dynamic>.from(perPerfil.map((x) => x)),
        "perNombre": perNombre,
        "perDireccion": perDireccion,
        "perObligado": perObligado,
        "perCredito": perCredito,
        "perTelefono": perTelefono,
        "perCelular": List<dynamic>.from(perCelular.map((x) => x)),
        "perEstado": perEstado,
        "perObsevacion": perObsevacion,
        "perEmail": List<dynamic>.from(perEmail.map((x) => x)),
        "perOtros": List<dynamic>.from(perOtros.map((x) => x)),
        "perNickname": perNickname,
        "perUser": perUser,
        "perFoto": perFoto,
        "perUbicacion": perUbicacion?.toJson(),
        "perDocumento": perDocumento,
        "perGenero": perGenero,
        "perRecomendacion": perRecomendacion,
        "perFecNacimiento": perFecNacimiento,
        "perEspecialidad": perEspecialidad,
        "perTitulo": perTitulo,
        "perSenescyt": perSenescyt,
        "perPersonal": perPersonal,
        "perId": perId,
        "perCodigo": perCodigo,
        "perUsuario": perUsuario,
        "perOnline": perOnline,
        "perSaldo": perSaldo,
        "perFecReg": perFecReg,
        "ciudad": ciudad,
        "sector": sector,
        "perFecUpd": perFecUpd, 
        "perCompra": perCompra,
        "perPermisos": perPermisos?.toJson(), 
      };
}

class PerPermisos {
  PerPermisos();

  factory PerPermisos.fromJson(Map<String, dynamic>? json) => PerPermisos();

  Map<String, dynamic> toJson() => {};
}

class PerUbicacion {
  final dynamic longitud;
  final dynamic latitud;

  const PerUbicacion({
    required this.longitud,
    required this.latitud,
  });

  const PerUbicacion.defaultValues()
      : longitud = 0,
        latitud = 0;

  factory PerUbicacion.fromJson(Map<String, dynamic>? json) => PerUbicacion(
        longitud: json?["longitud"] ?? '',
        latitud: json?["latitud"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "longitud": longitud,
        "latitud": latitud,
      };
}
