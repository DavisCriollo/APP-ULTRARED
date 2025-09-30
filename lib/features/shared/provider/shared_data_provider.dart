import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/shared/domain/repositores/shared_repository.dart';
import 'package:ultrared/features/shared/domain/repositores/shared_responses_class.dart';
import 'package:ultrared/features/shared/provider/shared_repository_provider.dart';

enum ErrorSharedType { ciudades, vendedores, planes, servicios }

final sharedDataProvider =
    StateNotifierProvider.autoDispose<SharedDataNotifier, SharedDataState>(
  (ref) {
    // final getUsuarioNombre = ref.watch(authProvider.notifier).getUsuarioNombre;
    final sharedRepository = ref.watch(sharedRepositoryProvider);

    return SharedDataNotifier(sharedRepository: sharedRepository);
  },
);

class SharedDataNotifier extends StateNotifier<SharedDataState> {
  final SharedRepository sharedRepository;

  SharedDataNotifier({required this.sharedRepository})
      : super(
          SharedDataState(
            responseGetCiudades: ResponseGetCiudades(resultado: [], error: ''),
            responseGetVendedores:
                ResponseGetVendedores(resultado: [], error: ''),
            responseGetPlanes: ResponseGetPlanes(resultado: [], error: ''),
            responseGetServicios: ResponseGetServicios(resultado: [], error: ''),
          ),
        ) {
    // loadNextPage();
  }

  Future<void> loadCiudades() async {
    // if (!isAdmin && state.page == 1) {

    final ciudadesRes = await sharedRepository.getCiudades();

    if (ciudadesRes.error.isNotEmpty) {
      state = state.copyWith(
          responseGetCiudades:
              ResponseGetCiudades(resultado: [], error: ciudadesRes.error));
      return;
    }

    state = state.copyWith(
        responseGetCiudades:
            ResponseGetCiudades(resultado: ciudadesRes.resultado, error: ''));
  }

  Future<void> loadVendedores() async {
    // if (!isAdmin && state.page == 1) {

    final vendedoresRes = await sharedRepository.getVendedores();

    if (vendedoresRes.error.isNotEmpty) {
      state = state.copyWith(
          responseGetVendedores:
              ResponseGetVendedores(resultado: [], error: vendedoresRes.error));
      return;
    }

    state = state.copyWith(
      responseGetVendedores:
          ResponseGetVendedores(resultado: vendedoresRes.resultado, error: ''),
    );
  }

  Future<void> loadPlanes({required String tipoPlan}) async {
    // if (!isAdmin && state.page == 1) {

    final vendedoresRes = await sharedRepository.getPlanes(tipoPlan: tipoPlan);

    if (vendedoresRes.error.isNotEmpty) {
      state = state.copyWith(
          responseGetPlanes:
              ResponseGetPlanes(resultado: [], error: vendedoresRes.error));
      return;
    }

    state = state.copyWith(
      responseGetPlanes:
          ResponseGetPlanes(resultado: vendedoresRes.resultado, error: ''),
    );
  }

  Future<void> loadServicios() async {
    // if (!isAdmin && state.page == 1) {

    final serviciosRes = await sharedRepository.getServicios();

    if (serviciosRes.error.isNotEmpty) {
      state = state.copyWith(
          responseGetServicios:
              ResponseGetServicios(resultado: [], error: serviciosRes.error));
      return;
    }

    state = state.copyWith(
      responseGetServicios:
          ResponseGetServicios(resultado: serviciosRes.resultado, error: ''),
    );
  }

  void clearError(ErrorSharedType type) async {
    if (type == ErrorSharedType.ciudades) {
      state = state.copyWith(
        responseGetCiudades: state.responseGetCiudades.clearError(),
      );
    }
    if (type == ErrorSharedType.vendedores) {
      state = state.copyWith(
        responseGetVendedores: state.responseGetVendedores.clearError(),
      );
    }
    if (type == ErrorSharedType.planes) {
      state = state.copyWith(
        responseGetPlanes: state.responseGetPlanes.clearError(),
      );
    }
    if (type == ErrorSharedType.servicios) {
      state = state.copyWith(
        responseGetPlanes: state.responseGetPlanes.clearError(),
      );
    }
  }

  @override
  void dispose() {
    print('Dispose SHARED');
    super.dispose();
  }
}

class SharedDataState {
  final ResponseGetCiudades responseGetCiudades;
  final ResponseGetVendedores responseGetVendedores;
  final ResponseGetPlanes responseGetPlanes;
  final ResponseGetServicios responseGetServicios;

  SharedDataState({
    required this.responseGetCiudades,
    required this.responseGetVendedores,
    required this.responseGetPlanes,
    required this.responseGetServicios,
  });

  SharedDataState copyWith({
    ResponseGetCiudades? responseGetCiudades,
    ResponseGetVendedores? responseGetVendedores,
    ResponseGetPlanes? responseGetPlanes,
    ResponseGetServicios? responseGetServicios,
  }) {
    return SharedDataState(
      responseGetCiudades: responseGetCiudades ?? this.responseGetCiudades,
      responseGetVendedores:
          responseGetVendedores ?? this.responseGetVendedores,
      responseGetPlanes: responseGetPlanes ?? this.responseGetPlanes,
      responseGetServicios: responseGetServicios ?? this.responseGetServicios,
    );
  }
}
