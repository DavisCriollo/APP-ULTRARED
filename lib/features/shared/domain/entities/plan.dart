class Plan {
  String planTipo;
  String planNombre;
  String planValor;
  String planMegas;
  String planObservacion;
  String planEmpresa;
  String planUser;
  int planId;
  String planEstado;
  String planFecReg;

  Plan({
    required this.planTipo,
    required this.planNombre,
    required this.planValor,
    required this.planMegas,
    required this.planObservacion,
    required this.planEmpresa,
    required this.planUser,
    required this.planId,
    required this.planEstado,
    required this.planFecReg,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        planTipo: json["planTipo"],
        planNombre: json["planNombre"],
        planValor: json["planValor"],
        planMegas: json["planMegas"],
        planObservacion: json["planObservacion"],
        planEmpresa: json["planEmpresa"],
        planUser: json["planUser"],
        planId: json["planId"],
        planEstado: json["planEstado"],
        planFecReg: json["planFecReg"],
      );

  Map<String, dynamic> toJson() => {
        "planTipo": planTipo,
        "planNombre": planNombre,
        "planValor": planValor,
        "planMegas": planMegas,
        "planObservacion": planObservacion,
        "planEmpresa": planEmpresa,
        "planUser": planUser,
        "planId": planId,
        "planEstado": planEstado,
        "planFecReg": planFecReg,
      };
}
