class Imagen {
  String nombre;
  String url;

  Imagen({
    required this.nombre,
    required this.url,
  });

  factory Imagen.fromJson(Map<String, dynamic> json) => Imagen(
        nombre: json["nombre"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "url": url,
      };
}
