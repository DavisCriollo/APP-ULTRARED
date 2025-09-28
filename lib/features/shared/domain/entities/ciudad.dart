class Ciudad {
  String ciuNombre;
  String ciuUser;
  String ciuEmpresa;
  int ciuId;
  String ciuMikrotik;
  String ciuPuerto;
  String ciuFecReg;
  List<CiuSector> ciuSectores;

  Ciudad({
    required this.ciuNombre,
    required this.ciuUser,
    required this.ciuEmpresa,
    required this.ciuId,
    required this.ciuMikrotik,
    required this.ciuPuerto,
    required this.ciuFecReg,
    required this.ciuSectores,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json) => Ciudad(
        ciuNombre: json["ciuNombre"],
        ciuUser: json["ciuUser"],
        ciuEmpresa: json["ciuEmpresa"],
        ciuId: json["ciuId"],
        ciuMikrotik: json["ciuMikrotik"],
        ciuPuerto: json["ciuPuerto"],
        ciuFecReg: json["ciuFecReg"],
        ciuSectores: List<CiuSector>.from(
            json["ciuSectores"].map((x) => CiuSector.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ciuNombre": ciuNombre,
        "ciuUser": ciuUser,
        "ciuEmpresa": ciuEmpresa,
        "ciuId": ciuId,
        "ciuMikrotik": ciuMikrotik,
        "ciuPuerto": ciuPuerto,
        "ciuFecReg": ciuFecReg,
        "ciuSectores": List<dynamic>.from(ciuSectores.map((x) => x.toJson())),
      };
}

class CiuSector {
  String nombre;

  CiuSector({
    required this.nombre,
  });

  factory CiuSector.fromJson(Map<String, dynamic> json) => CiuSector(
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
      };
}
