import 'package:dio/dio.dart';
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/pppoe/domain/entities/actividad.dart';
import 'package:ultrared/features/shared/errors/error_api.dart';

class ResponseConexiones {
  final List<Conexion> resultado;
  final int total;
  final String error;

  ResponseConexiones(
      {required this.resultado, required this.error, this.total = 0});
}

class ResponseChangeStatusConexion {
  final bool status;
  final String error;

  ResponseChangeStatusConexion({required this.status, required this.error});
}

class ConexionesRepository {
  final Dio dio;
  final User usuario;
  ConexionesRepository({required this.dio, required this.usuario});

  Future<ResponseConexiones> getConexionesByPage(
      {required String ciudad,
      required String estado,
      required BusquedaConexiones busquedaConexiones}) async {
    try {
      final queryParameters = {
        'ciudad': ciudad,
        'tipo': estado,
        'datos': busquedaConexiones.toJsonString(),
      };
      //       `/acta_entrega_recepcion/?cantidad=${cantidad}&page=${page}&search=${
      //   search ? search : ""
      // }&input=${input ? input : ""}&orden=${orden ? orden : ""}&rucempresa=${
      //   rucempresa ? rucempresa : ""
      // }&sector=${usuario.sector}&ciudad=${usuario.ciudad}&estado=${estado}${
      //   idPer_frompersonas ? `&idPer_frompersonas=${idPer_frompersonas}` : ""
      // }&datos=${datos}`
      final response = await dio.get('/mikrotik/listar/active/and/secret',
          queryParameters: queryParameters);
      final List<Conexion> newConexiones =
          response.data.map<Conexion>((e) => Conexion.fromJson(e)).toList();

      return ResponseConexiones(
          resultado: newConexiones, error: '', total: newConexiones.length);
    } on DioException catch (e) {
      return ResponseConexiones(
          resultado: [],
          error: ErrorApi.getErrorMessage(e, 'getConexionesByPage'));
    }
  }

  Future<ResponseChangeStatusConexion> changeStatusConexion(
      {required String ciudad,
      required String name,
      required bool action}) async {
    try {
      final queryParameters = {
        'ciudad': ciudad,
        'name': name,
        'action': action ? 'activar' : 'desactivar',
      };
      //       `/acta_entrega_recepcion/?cantidad=${cantidad}&page=${page}&search=${
      //   search ? search : ""
      // }&input=${input ? input : ""}&orden=${orden ? orden : ""}&rucempresa=${
      //   rucempresa ? rucempresa : ""
      // }&sector=${usuario.sector}&ciudad=${usuario.ciudad}&estado=${estado}${
      //   idPer_frompersonas ? `&idPer_frompersonas=${idPer_frompersonas}` : ""
      // }&datos=${datos}`
      final response = await dio.put('/mikrotik/activar/desactivar/servicio',
          data: queryParameters);

      return ResponseChangeStatusConexion(
          error: '', status: response.data['status'] == "OK");
    } on DioException catch (e) {
      return ResponseChangeStatusConexion(
          status: false,
          error: ErrorApi.getErrorMessage(e, 'changeStatusConexion'));
    }
  }
}
