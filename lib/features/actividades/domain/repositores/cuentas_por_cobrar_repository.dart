import 'package:dio/dio.dart';
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/shared/errors/error_api.dart';

class ResponseActividades {
  final List<Actividad> resultado;
  final int total;
  final String error;

  ResponseActividades(
      {required this.resultado, required this.error, this.total = 0});
}

class ActividadesRepository {
  final Dio dio;
  final User usuario;
  ActividadesRepository({required this.dio, required this.usuario});

  Future<ResponseActividades> getActividadesByPage(
      {required int cantidad,
      required int page,
      required String estado,
      required String input,
      required bool orden,
      required String search,
      required BusquedaActividades busquedaActividades}) async {
    try {
      final queryParameters = {
        'search': search,
        'cantidad': cantidad,
        'page': page,
        'input': input,
        'orden': orden,
        'estado': estado,
        'datos': busquedaActividades.toJsonString(), // Con
        'sector': usuario.sector,
        'ciudad': usuario.ciudad,
        'idPer_frompersonas': null,
      };
      //       `/acta_entrega_recepcion/?cantidad=${cantidad}&page=${page}&search=${
      //   search ? search : ""
      // }&input=${input ? input : ""}&orden=${orden ? orden : ""}&rucempresa=${
      //   rucempresa ? rucempresa : ""
      // }&sector=${usuario.sector}&ciudad=${usuario.ciudad}&estado=${estado}${
      //   idPer_frompersonas ? `&idPer_frompersonas=${idPer_frompersonas}` : ""
      // }&datos=${datos}`
      final response = await dio.get('/acta_entrega_recepcion',
          queryParameters: queryParameters);
      final List<Actividad> newActividades = response.data['data']['results']
          .map<Actividad>((e) => Actividad.fromJson(e))
          .toList();

      return ResponseActividades(
          resultado: newActividades,
          error: '',
          total: response.data['data']['pagination']['numRows'] ?? 0);
    } on DioException catch (e) {
      return ResponseActividades(
          resultado: [],
          error: ErrorApi.getErrorMessage(e, 'getActividadesByPage'));
    }
  }
}
