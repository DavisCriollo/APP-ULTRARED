import 'package:dio/dio.dart'; 
import 'package:ultrared/features/clientes/domain/entities/cliente.dart';
import 'package:ultrared/features/shared/errors/error_api.dart';

// class ResponseSearchClientes {
//   final List<Cliente> resultado;
//   final int total;
//   final String error;

//   ResponseClientes(
//       {required this.resultado, required this.error, this.total = 0});
// }
class ResponseSearchClientes {
  final List<Cliente> resultado;
  final String error;

  ResponseSearchClientes({
    required this.resultado,
    required this.error,
  });
}

class ClientesRepository {
  final Dio dio;
  ClientesRepository({
    required this.dio,
  });

  Future<ResponseSearchClientes> searchClientesForeign({
    required String search,
  }) async {
    try {
      final queryParameters = {
        'search': search,
      };
      //       `/acta_entrega_recepcion/?cantidad=${cantidad}&page=${page}&search=${
      //   search ? search : ""
      // }&input=${input ? input : ""}&orden=${orden ? orden : ""}&rucempresa=${
      //   rucempresa ? rucempresa : ""
      // }&sector=${usuario.sector}&ciudad=${usuario.ciudad}&estado=${estado}${
      //   idPer_frompersonas ? `&idPer_frompersonas=${idPer_frompersonas}` : ""
      // }&datos=${datos}`
      final response = await dio.get('/proveedores/agregarperfil/0',
          queryParameters: queryParameters);
      final List<Cliente> newClientes = response.data['data']
          .map<Cliente>((e) => Cliente.fromJson(e))
          .toList();

      return ResponseSearchClientes(
        resultado: newClientes,
        error: '',
      );
    } on DioException catch (e) {
      return ResponseSearchClientes(
          resultado: [],
          error: ErrorApi.getErrorMessage(e, 'searchClientesForeign'));
    }
  }
}
