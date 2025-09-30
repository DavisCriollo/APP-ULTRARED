import 'package:dio/dio.dart';
import 'package:ultrared/features/clientes/domain/entities/cliente.dart';
import 'package:ultrared/features/shared/domain/entities/ciudad.dart';
import 'package:ultrared/features/shared/domain/entities/plan.dart';
import 'package:ultrared/features/shared/domain/entities/servicio.dart';
import 'package:ultrared/features/shared/domain/repositores/shared_responses_class.dart';
import 'package:ultrared/features/shared/errors/error_api.dart';

class SharedRepository {
  final Dio dio;
  SharedRepository({
    required this.dio,
  });

  Future<ResponseGetCiudades> getCiudades() async {
    try {
      final response = await dio.get(
        '/ciudades/filtro/0',
      );
      final List<Ciudad> resCiudades =
          response.data['data'].map<Ciudad>((e) => Ciudad.fromJson(e)).toList();

      return ResponseGetCiudades(
        resultado: resCiudades,
        error: '',
      );
    } on DioException catch (e) {
      return ResponseGetCiudades(
          resultado: [], error: ErrorApi.getErrorMessage(e, 'getCiudades'));
    }
  }

  Future<ResponseGetVendedores> getVendedores() async {
    try {
      final response = await dio.get(
        '/proveedores/filtro/0?search&estado=VENDEDOR&tabla=personas&listadoporperfil=true',
      );
      final List<Persona> resPersonas = response.data['data']
          .map<Persona>((e) => Persona.fromJson(e))
          .toList();

      return ResponseGetVendedores(
        resultado: resPersonas,
        error: '',
      );
    } on DioException catch (e) {
      return ResponseGetVendedores(
          resultado: [], error: ErrorApi.getErrorMessage(e, 'getVendedores'));
    }
  }

  Future<ResponseGetPlanes> getPlanes({required String tipoPlan}) async {
    try {
      final response = await dio.get(
        '/planes/filtroIsEstadoActual/0?tipo=$tipoPlan',
      );
      final List<Plan> resPlanes =
          response.data['data'].map<Plan>((e) => Plan.fromJson(e)).toList();

      return ResponseGetPlanes(
        resultado: resPlanes,
        error: '',
      );
    } on DioException catch (e) {
      return ResponseGetPlanes(
          resultado: [], error: ErrorApi.getErrorMessage(e, 'getPlanes'));
    }
  }

  Future<ResponseGetServicios> getServicios() async {
    try {
      final response = await dio.get(
        '/servicios_visita/listar/todos',
      );
      final List<Servicio> resServicios =
          response.data.map<Servicio>((e) => Servicio.fromJson(e)).toList();

      return ResponseGetServicios(
        resultado: resServicios,
        error: '',
      );
    } on DioException catch (e) {
      return ResponseGetServicios(
          resultado: [], error: ErrorApi.getErrorMessage(e, 'getPlanes'));
    }
  }
}
