// To parse this JSON data
// do
//
//     final userMapper = userMapperFromJson(jsonString);

import 'package:ultrared/features/auth/domain/domain.dart';

class UserMapper {
  final String token;
  final int id;
  final String nombre;
  final String usuario;
  final String rucempresa;
  final String codigo;
  final String nomEmpresa;
  final String nomComercial;
  final String fechaCaducaFirma;
  final List rol;
  final String empCategoria;
  final String logo;
  final int iva;
  final String foto;
  final String colorPrimario;
  final String colorSecundario;
  final List empRoles;
  final dynamic permisosUsuario;
  final String sector;
  final String ciudad;
  UserMapper({
    required this.token,
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.rucempresa,
    required this.codigo,
    required this.nomEmpresa,
    required this.nomComercial,
    required this.fechaCaducaFirma,
    required this.rol,
    required this.empCategoria,
    required this.logo,
    required this.iva,
    required this.foto,
    required this.colorPrimario,
    required this.colorSecundario,
    required this.empRoles,
    required this.permisosUsuario,
    required this.sector,
    required this.ciudad,
  });

  static User userJsonToEntity(Map<String, dynamic> json) => User(
        token: json["token"],
        id: json["id"],
        nombre: json["nombre"],
        usuario: json["usuario"],
        rucempresa: json["rucempresa"],
        codigo: json["codigo"],
        nomEmpresa: json["nomEmpresa"],
        nomComercial: json["nomComercial"],
        fechaCaducaFirma: json["fechaCaducaFirma"],
        rol: List<String>.from(json["rol"].map((x) => x)),
        empCategoria: json["empCategoria"],
        logo: json["logo"],
        iva: json["iva"],
        foto: json["foto"],
        colorPrimario: json["colorPrimario"],
        colorSecundario: json["colorSecundario"],
        empRoles: List<String>.from(json["empRoles"].map((x) => x)),
        permisosUsuario: json["permisosUsuario"],
        sector: json["sector"] ?? '',
        ciudad: json["ciudad"] ?? '',
      );
}
