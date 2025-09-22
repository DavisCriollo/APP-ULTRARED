// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

class User {
  final String token;
  final int id;
  final String nombre;
  final String usuario;
  final String rucempresa;
  final String codigo;
  final String nomEmpresa;
  final String nomComercial;
  final String fechaCaducaFirma;
  final List<String> rol;
  final String empCategoria;
  final String logo;
  final int iva;
  final String foto;
  final String colorPrimario;
  final String colorSecundario;
  final List<String> empRoles;
  final dynamic permisosUsuario;

  User({
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
  });
}
