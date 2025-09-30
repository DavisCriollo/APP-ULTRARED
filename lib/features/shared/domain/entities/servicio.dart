class Servicio {
  int id;
  String nombre;
  String usuario;
  String empresa;
  String fecReg;
  String fecUpd;

  Servicio({
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.empresa,
    required this.fecReg,
    required this.fecUpd,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) => Servicio(
        id: json["id"],
        nombre: json["nombre"],
        usuario: json["usuario"],
        empresa: json["empresa"],
        fecReg: json["fecReg"],
        fecUpd: json["fecUpd"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "usuario": usuario,
        "empresa": empresa,
        "fecReg": fecReg,
        "fecUpd": fecUpd,
      };
}
