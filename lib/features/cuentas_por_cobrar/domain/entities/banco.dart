class Banco {
  final int banId;
  final String banNombre;
  final String banUser;
  final String banFecReg;

  Banco({
    required this.banId,
    required this.banNombre,
    required this.banUser,
    required this.banFecReg,
  });

  factory Banco.fromJson(Map<String, dynamic> json) => Banco(
        banId: json["banId"],
        banNombre: json["banNombre"],
        banUser: json["banUser"],
        banFecReg: json["banFecReg"],
      );

  Map<String, dynamic> toJson() => {
        "banId": banId,
        "banNombre": banNombre,
        "banUser": banUser,
        "banFecReg": banFecReg,
      };
}
