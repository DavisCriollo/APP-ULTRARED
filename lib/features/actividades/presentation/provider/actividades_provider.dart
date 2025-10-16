import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/actividades/domain/repositores/cuentas_por_cobrar_repository.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividades_repository_provider.dart';
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/provider/socket.dart';

enum ActividadEstado {
  pendientes("PENDIENTES"),
  procesador("PROCESADOS"),
  retiroDeEquipos("RETIRO DE EQUIPOS");
  // notaActividades("NOTA VENTAS"),
  // proformas("PROFORMAS"),
  // notaCreditos("NOTA CREDITOS");

  final String value;
  const ActividadEstado(this.value);
}

class GetActividadResponse {
  final Actividad? actividad;
  final String error;

  GetActividadResponse({required this.actividad, required this.error});
}

final actividadesProvider =
    StateNotifierProvider.autoDispose<ActividadesNotifier, ActividadesState>(
  (ref) {
    final authState = ref.watch(authProvider);
    // final getUsuarioNombre = ref.watch(authProvider.notifier).getUsuarioNombre;
    final actividadesRepository = ref.watch(actividadesRepositoryProvider);
    final socket = ref.watch(socketProvider);
    final usuario = authState.user;
    return ActividadesNotifier(
        socket: socket,
        actividadesRepository: actividadesRepository,
        user: authState.user!,
        isAdmin: authState.isAdmin,
        usuario: usuario!);
  },
);

class ActividadesNotifier extends StateNotifier<ActividadesState> {
  final ActividadesRepository actividadesRepository;
  final io.Socket socket;
  final User user;
  final bool isAdmin;
  final User usuario;

  ActividadesNotifier({
    required this.actividadesRepository,
    required this.socket,
    required this.user,
    required this.isAdmin,
    required this.usuario,
  }) : super(ActividadesState()) {
    print('INIT VENTAS PROVIDER');
    _initializeSocketListeners();
  }

  Future loadNextPage() async {
    // if (!isAdmin && state.page == 1) {

    if (state.isLastPage || state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true);

    final actividades = await actividadesRepository.getActividadesByPage(
      cantidad: state.cantidad,
      page: state.page,
      search: state.search,
      estado: state.estado.value,
      input: state.input,
      orden: state.orden,
      busquedaActividades: state.busquedaActividad,
    );

    if (actividades.error.isNotEmpty) {
      state = state.copyWith(isLoading: false, error: actividades.error);
      return;
    }
    if (actividades.resultado.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        error: '',
        isLoading: false,
        page: state.page + 1,
        total: actividades.total,
        actividades: [...state.actividades, ...actividades.resultado]);
  }

  Future<List<Actividad>> searchActividadesByQueryWhileWasLoading() async {
    state = state.copyWith(isLoading: true);
    final actividades = await actividadesRepository.getActividadesByPage(
      search: state.search,
      cantidad: state.cantidad,
      input: state.input,
      orden: state.orden,
      page: 0,
      estado: state.estado.value,
      busquedaActividades: state.busquedaActividad,
    );
    // ref.read(searchQueryProvider.notifier).update((state) => search);
    if (actividades.error.isNotEmpty) {
      state = state.copyWith(error: actividades.error, isLoading: false);
      return [];
    }

    state = state.copyWith(
        searchedActividades: actividades.resultado,
        totalSearched: actividades.total,
        total: actividades.total,
        actividades: actividades.resultado,
        isLastPage: false,
        isLoading: false,
        isSearching:
            state.search.isNotEmpty || state.busquedaActividad.isSearching());
    return actividades.resultado;
  }

  Future<List<Actividad>> searchActividadesByQuery({String search = ''}) async {
    final actividades = await actividadesRepository.getActividadesByPage(
      search: search,
      cantidad: state.cantidad,
      input: state.input,
      orden: state.orden,
      page: 0,
      estado: state.estado.value,
      busquedaActividades: state.busquedaActividad,
    );
    // ref.read(searchQueryProvider.notifier).update((state) => search);
    if (actividades.error.isNotEmpty) {
      state = state.copyWith(error: actividades.error, search: search);
      return [];
    }

    state = state.copyWith(
        search: search,
        searchedActividades: actividades.resultado,
        totalSearched: actividades.total,
        isLastPage: false,
        isSearching:
            search.isNotEmpty || state.busquedaActividad.isSearching());
    return actividades.resultado;
  }

  void setSearch(String search) {
    state = state.copyWith(search: search);
  }

  Future<GetActividadResponse> getActividadById(int actaId) async {
    try {
      final exist = [...state.actividades, ...state.searchedActividades]
          .any((e) => e.actaId == actaId);
      if (!exist) {
        return GetActividadResponse(
            actividad: null, error: 'No se encontró el actividad');
      }
      return GetActividadResponse(
          actividad:
              [...state.actividades, ...state.searchedActividades].firstWhere(
            (actividad) => actividad.actaId == actaId,
          ),
          error: '');
    } catch (e) {
      return GetActividadResponse(
          actividad: null, error: 'Hubo un error al consultar la actividad');
    }
  }

  Future<void> resetQuery({
    String? search,
    ActividadEstado? estado,
    String? input,
    bool? orden,
    BusquedaActividades? busquedaActividad,
  }) async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true);
    final actividades = await actividadesRepository.getActividadesByPage(
      cantidad: state.cantidad,
      page: 0,
      search: search ?? state.search,
      estado: estado?.value ?? state.estado.value,
      input: input ?? state.input,
      orden: orden ?? state.orden,
      busquedaActividades: busquedaActividad ?? state.busquedaActividad,
    );

    if (actividades.error.isNotEmpty) {
      state = state.copyWith(isLoading: false, error: actividades.error);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      page: 1,
      total: actividades.total,
      actividades: actividades.resultado,
      search: search,
      estado: estado,
      input: input,
      orden: orden,
      isLastPage: false,
      busquedaActividad: busquedaActividad,
      isSearching: (search ?? state.search).isNotEmpty ||
          (busquedaActividad ?? state.busquedaActividad).isSearching(),
    );
  }

  void handleSearch() async {
    if (state.search.isEmpty) {
      return;
    }
    state = state.copyWith(
        total: state.totalSearched,
        actividades: state.searchedActividades,
        page: 1,
        searchedActividades: [],
        totalSearched: 0);
  }

  void resetError() {
    state = state.copyWith(error: '');
  }

  Future<void> createUpdateActividad(
      Map<String, dynamic> actividadMap, bool editando) async {
    if (editando) {
      socket.emit('client:actualizarData', actividadMap);
    } else {
      socket.emit("client:guardarData", actividadMap);
    }
  }

  Future<void> changeEstadoActividad(Actividad actividad) async {
    socket.emit('client:actualizarData', {
      ...actividad.toJson(),
      "rucempresa": usuario.rucempresa,
      "rol": usuario.rol,
      "actaUser": usuario.usuario,
      "actaEmpresa": usuario.rucempresa,
      "tabla": "acta_entrega_recepcion",

      // actaFotos: resDocumentos,
      // nombres_tecnicos: tecnicos.join(", "),
    });
  }

  void _initializeSocketListeners() {
    socket.on('connect', _onConnect);
    socket.on('disconnect', _onDisconnect);
    socket.on("server:actualizadoExitoso", _onActualizadoExitoso);
    socket.on("server:guardadoExitoso", _onGuardadoExitoso);
    socket.on("server:error", _onError);
  }

  void _onConnect(dynamic data) {}

  void _onDisconnect(dynamic data) {}

  void _onActualizadoExitoso(dynamic data) {
    try {
      if (mounted) {
        if (data['tabla'] == 'acta_entrega_recepcion' &&
            data['rucempresa'] == user.rucempresa) {
          // Edita de la lista de actividades
          final updatedActividad = Actividad.fromJson(data);
          final updatedActividadesList = state.actividades.map((actividad) {
            return actividad.actaId == updatedActividad.actaId
                ? updatedActividad
                : actividad;
          }).toList();
          state = state.copyWith(actividades: updatedActividadesList);
        }
      }
    } catch (e) {}
  }

  void _onGuardadoExitoso(dynamic data) async {
    try {
      if (mounted) {
        if (data['tabla'] == 'acta_entrega_recepcion' &&
            data['rucempresa'] == user.rucempresa) {
          // Agrega a la lista de actividades
          final newActividad = Actividad.fromJson(data);
          // if (isAdmin || newActividad.ccUser == user.usuario) {
          state = state.copyWith(actividades: [
            newActividad,
            ...state.actividades,
          ]);
          // }
        }
      }
    } catch (e) {}
  }

  void _onError(dynamic data) {
    try {
      if (mounted) {
        state = state.copyWith(
            error: data['msg'] ?? "Hubo un error ${data['tabla']}");
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    // Limpia los listeners del socket
    socket.off('connect', _onConnect);
    socket.off('disconnect', _onDisconnect);
    socket.off("server:actualizadoExitoso", _onActualizadoExitoso);
    socket.off("server:guardadoExitoso", _onGuardadoExitoso);
    socket.off("server:error", _onError);

    print('Dispose VENTAS PROVIDER');
    super.dispose();
  }
}

class ActividadesState {
  final bool isLastPage;
  final bool isLoading;
  final int cantidad;
  final int page;
  final List<Actividad> actividades;
  final int total;
  final String search;
  final ActividadEstado estado;
  final String input;
  final bool orden;
  final List<Actividad> searchedActividades;
  final int totalSearched;
  final BusquedaActividades busquedaActividad;
  final bool isSearching;
  final String error;

  ActividadesState({
    this.isLastPage = false,
    this.isLoading = false,
    this.cantidad = 10,
    this.page = 0,
    this.actividades = const [],
    this.error = '',
    this.total = 0,
    this.search = '',
    this.estado = ActividadEstado.pendientes,
    this.input = 'actaId',
    this.orden = false,
    this.searchedActividades = const [],
    this.totalSearched = 0,
    this.busquedaActividad = const BusquedaActividades(),
    this.isSearching = false,
  });

  ActividadesState copyWith({
    bool? isLastPage,
    bool? isLoading,
    int? cantidad,
    int? page,
    List<Actividad>? actividades,
    String? error,
    int? total,
    String? search,
    ActividadEstado? estado,
    String? input,
    bool? orden,
    List<Actividad>? searchedActividades,
    int? totalSearched,
    BusquedaActividades? busquedaActividad,
    bool? isSearching,
  }) {
    return ActividadesState(
      isLastPage: isLastPage ?? this.isLastPage,
      isLoading: isLoading ?? this.isLoading,
      cantidad: cantidad ?? this.cantidad,
      page: page ?? this.page,
      actividades: actividades ?? this.actividades,
      error: error ?? this.error,
      total: total ?? this.total,
      search: search ?? this.search,
      estado: estado ?? this.estado,
      input: input ?? this.input,
      orden: orden ?? this.orden,
      searchedActividades: searchedActividades ?? this.searchedActividades,
      totalSearched: totalSearched ?? this.totalSearched,
      busquedaActividad: busquedaActividad ?? this.busquedaActividad,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
