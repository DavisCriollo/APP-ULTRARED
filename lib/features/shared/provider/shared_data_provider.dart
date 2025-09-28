import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/shared/domain/repositores/shared_repository.dart';
import 'package:ultrared/features/shared/provider/shared_repository_provider.dart';

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
      : super(SharedDataState(
            responseGetCiudades:
                ResponseGetCiudades(resultado: [], error: ''))) {
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

  void clearErrorCiudades() async {
    state = state.copyWith(
      responseGetCiudades: state.responseGetCiudades.clearError(),
    );
  }

  @override
  void dispose() {
    print('Dispose SHARED');
    super.dispose();
  }
}

class SharedDataState {
  final ResponseGetCiudades responseGetCiudades;

  SharedDataState({required this.responseGetCiudades});

  SharedDataState copyWith({ResponseGetCiudades? responseGetCiudades}) {
    return SharedDataState(
      responseGetCiudades: responseGetCiudades ?? this.responseGetCiudades,
    );
  }
}
