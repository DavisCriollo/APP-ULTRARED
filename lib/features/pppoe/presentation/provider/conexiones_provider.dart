import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/pppoe/domain/entities/actividad.dart';
import 'package:ultrared/features/pppoe/domain/repositores/conexiones_repository.dart';
import 'package:ultrared/features/pppoe/presentation/provider/conexiones_repository_provider.dart';
import 'package:ultrared/features/shared/domain/repositores/shared_responses_class.dart';
import 'package:ultrared/features/shared/provider/shared_data_provider.dart';

void printLargeMap(Map<String, dynamic> map, {int chunkSize = 10}) {
  final entries = map.entries.toList();
  final totalChunks = (entries.length / chunkSize).ceil();

  for (int i = 0; i < totalChunks; i++) {
    final start = i * chunkSize;
    final end = start + chunkSize;
    final chunk =
        entries.sublist(start, end > entries.length ? entries.length : end);

    final chunkMap = Map.fromEntries(chunk);
    // Convertir el fragmento en un mapa
    print('Parte ${i + 1} de $totalChunks: ${jsonEncode(chunkMap)}');
  }
}

enum ConexionEstado {
  activos("ACTIVOS"),
  secret("SECRET");
  // notaConexiones("NOTA VENTAS"),
  // proformas("PROFORMAS"),
  // notaCreditos("NOTA CREDITOS");

  final String value;
  const ConexionEstado(this.value);
}

class GetConexionResponse {
  final Conexion? conexion;
  final String error;

  GetConexionResponse({required this.conexion, required this.error});
}

final conexionesProvider =
    StateNotifierProvider.autoDispose<ConexionesNotifier, ConexionesState>(
  (ref) {
    final authState = ref.watch(authProvider);
    // final getUsuarioNombre = ref.watch(authProvider.notifier).getUsuarioNombre;
    final conexionesRepository = ref.watch(conexionesRepositoryProvider);
    final loadCiudades = ref.read(sharedDataProvider.notifier).loadCiudades;
    final responseGetCiudades =
        ref.read(sharedDataProvider).responseGetCiudades;
    // final socket = ref.watch(socketProvider);
    final usuario = authState.user;
    return ConexionesNotifier(
      // socket: socket,
      conexionesRepository: conexionesRepository,
      user: authState.user!,
      isAdmin: authState.isAdmin,
      usuario: usuario!,
      loadCiudades: loadCiudades,
      responseGetCiudades: responseGetCiudades,
    );
  },
);

class ConexionesNotifier extends StateNotifier<ConexionesState> {
  final ConexionesRepository conexionesRepository;
  // final io.Socket socket;
  final User user;
  final bool isAdmin;
  final User usuario;
  final Future<ResponseGetCiudades> Function() loadCiudades;
  final ResponseGetCiudades responseGetCiudades;
  ConexionesNotifier({
    required this.conexionesRepository,
    // required this.socket,
    required this.user,
    required this.isAdmin,
    required this.usuario,
    required this.loadCiudades,
    required this.responseGetCiudades,
  }) : super(ConexionesState()) {
    print('INIT VENTAS PROVIDER');
  }

  Future<List<Conexion>> searchConexionesByQueryWhileWasLoading() async {
    state = state.copyWith(isLoading: true);
    final conexiones = filterConexionesBySearch(null, state.search);
    // ref.read(searchQueryProvider.notifier).update((state) => search);

    state = state.copyWith(
        searchedConexiones: conexiones,
        totalSearched: conexiones.length,
        total: conexiones.length,
        conexiones: conexiones,
        isLoading: false,
        isSearching:
            state.search.isNotEmpty || state.busquedaConexion.isSearching());
    return conexiones;
  }

  Future<List<Conexion>> searchConexionesByQuery({String search = ''}) async {
    final conexiones = filterConexionesBySearch(null, search);

    // ref.read(searchQueryProvider.notifier).update((state) => search);

    state = state.copyWith(
        search: search,
        searchedConexiones: conexiones,
        totalSearched: conexiones.length,
        isSearching: search.isNotEmpty || state.busquedaConexion.isSearching());
    return conexiones;
  }

  void setSearch(String search) {
    state = state.copyWith(search: search);
  }

  /// Filtra las conexiones según el estado (ACTIVOS o INACTIVOS) y un término de búsqueda
  List<Conexion> filterConexionesBySearch(
      List<Conexion>? conexiones, String search) {
    if (search.trim().isEmpty) {
      return conexiones ?? state.conexiones;
    }
    final searchLower = search.toLowerCase();

    return (conexiones ?? state.conexiones).where((conexion) {
      if (state.estado == ConexionEstado.activos) {
        return conexion.name.toLowerCase().contains(searchLower) ||
            conexion.service.toLowerCase().contains(searchLower) ||
            conexion.address.toLowerCase().contains(searchLower) ||
            (conexion.id?.toLowerCase().contains(searchLower) ?? false);
      } else {
        return conexion.name.toLowerCase().contains(searchLower) ||
            conexion.service.toLowerCase().contains(searchLower) ||
            conexion.profile.toLowerCase().contains(searchLower) ||
            (conexion.id?.toLowerCase().contains(searchLower) ?? false);
      }
    }).toList();
  }

  // Future<GetConexionResponse> getConexionById(int actaId) async {
  //   try {
  //     final exist = [...state.conexiones, ...state.searchedConexiones]
  //         .any((e) => e.actaId == actaId);
  //     if (!exist) {
  //       return GetConexionResponse(
  //           conexion: null, error: 'No se encontró el conexion');
  //     }
  //     return GetConexionResponse(
  //         conexion:
  //             [...state.conexiones, ...state.searchedConexiones].firstWhere(
  //           (conexion) => conexion.actaId == actaId,
  //         ),
  //         error: '');
  //   } catch (e) {
  //     return GetConexionResponse(
  //         conexion: null, error: 'Hubo un error al consultar la conexion');
  //   }
  // }

  Future<bool> changeEstado(String name, String id, bool newStatus) async {
    final response = await conexionesRepository.changeStatusConexion(
      ciudad: state.ciudad,
      name: name,
      action: newStatus,
    );
    if (!mounted) return false;
    if (!response.status) {
      state = state.copyWith(error: response.error);
      return false;
    }
    state = state.copyWith(
        conexiones: state.conexiones.map((conexion) {
      if (conexion.id == id) {
        return conexion.copyWith(disabled: newStatus ? 'false' : 'true');
      }
      return conexion;
    }).toList());
    return true;
  }

  Future<void> resetQuery({
    String? search,
    ConexionEstado? estado,
    String? ciudad,
    String? input,
    bool? orden,
    BusquedaConexiones? busquedaConexion,
  }) async {
    if (state.isLoading) {
      return;
    }
    search ??= state.search;
    estado ??= state.estado;
    ciudad ??= state.ciudad;
    input ??= state.input;
    orden ??= state.orden;
    busquedaConexion ??= state.busquedaConexion;
    state = state.copyWith(isLoading: true);

    String primeraCiudad = '';
    if (responseGetCiudades.resultado.isEmpty) {
      final response = await loadCiudades();
      if (!mounted) return;
      if (response.error.isNotEmpty) {
        state = state.copyWith(isLoading: false, error: response.error);
        return;
      }
      primeraCiudad = response.resultado.first.ciuNombre;
      if (ciudad.isNotEmpty) {
        if (!response.resultado.any((c) => c.ciuNombre == ciudad)) {
          state =
              state.copyWith(isLoading: false, error: 'La ciudad no existe');
          return;
        } else {
          primeraCiudad = ciudad;
        }
      }

      if (state.ciudad.isEmpty) {
        state = state.copyWith(ciudad: primeraCiudad);
      }
    }

    final conexionesRes = await conexionesRepository.getConexionesByPage(
      // search: search ?? state.search,
      estado: estado.value,
      ciudad: primeraCiudad,
      // input: input ?? state.input,
      // orden: orden ?? state.orden,
      busquedaConexiones: busquedaConexion,
    );
    if (!mounted) return;
    if (conexionesRes.error.isNotEmpty) {
      state = state.copyWith(isLoading: false, error: conexionesRes.error);
      return;
    }
    final conexiones =
        filterConexionesBySearch(conexionesRes.resultado, search);

    state = state.copyWith(
      isLoading: false,
      total: conexiones.length,
      conexiones: conexiones,
      search: search,
      estado: estado,
      ciudad: primeraCiudad,
      input: input,
      orden: orden,
      busquedaConexion: busquedaConexion,
      isSearching:
          (search).trim().isNotEmpty || (busquedaConexion).isSearching(),
    );
  }

  void handleSearch() async {
    if (state.search.isEmpty) {
      return;
    }
    state = state.copyWith(
        total: state.totalSearched,
        conexiones: state.searchedConexiones,
        searchedConexiones: [],
        totalSearched: 0);
  }

  void resetError() {
    state = state.copyWith(error: '');
  }

  Future<void> createUpdateConexion(
      Map<String, dynamic> conexionMap, bool editando) async {
    if (editando) {
      // socket.emit('client:actualizarData', conexionMap);
    } else {
      // socket.emit("client:guardarData", conexionMap);
    }
  }

  // void _initializeSocketListeners() {
  //   socket.on('connect', _onConnect);
  //   socket.on('disconnect', _onDisconnect);
  //   socket.on("server:actualizadoExitoso", _onActualizadoExitoso);
  //   socket.on("server:guardadoExitoso", _onGuardadoExitoso);
  //   socket.on("server:error", _onError);
  // }

  // void _onConnect(dynamic data) {}

  // void _onDisconnect(dynamic data) {}

  // void _onActualizadoExitoso(dynamic data) {
  //   try {
  //     if (mounted) {
  //       if (data['tabla'] == 'acta_entrega_recepcion' &&
  //           data['rucempresa'] == user.rucempresa) {
  //         // Edita de la lista de conexiones
  //         final updatedConexion = Conexion.fromJson(data);
  //         final updatedConexionesList = state.conexiones.map((conexion) {
  //           return conexion.id == updatedConexion.id
  //               ? updatedConexion
  //               : conexion;
  //         }).toList();
  //         state = state.copyWith(conexiones: updatedConexionesList);
  //       }
  //     }
  //   } catch (e) {}
  // }

  // void _onGuardadoExitoso(dynamic data) async {
  //   try {
  //     if (mounted) {
  //       if (data['tabla'] == 'acta_entrega_recepcion' &&
  //           data['rucempresa'] == user.rucempresa) {
  //         // Agrega a la lista de conexiones
  //         final newConexion = Conexion.fromJson(data);
  //         // if (isAdmin || newConexion.ccUser == user.usuario) {
  //         state = state.copyWith(conexiones: [
  //           newConexion,
  //           ...state.conexiones,
  //         ]);
  //         // }
  //       }
  //     }
  //   } catch (e) {}
  // }

  // void _onError(dynamic data) {
  //   try {
  //     if (mounted) {
  //       state = state.copyWith(
  //           error: data['msg'] ?? "Hubo un error ${data['tabla']}");
  //     }
  //   } catch (e) {}
  // }

  // @override
  // void dispose() {
  //   // Limpia los listeners del socket
  //   socket.off('connect', _onConnect);
  //   socket.off('disconnect', _onDisconnect);
  //   socket.off("server:actualizadoExitoso", _onActualizadoExitoso);
  //   socket.off("server:guardadoExitoso", _onGuardadoExitoso);
  //   socket.off("server:error", _onError);

  //   print('Dispose VENTAS PROVIDER');
  //   super.dispose();
  // }
}

class ConexionesState {
  final bool isLoading;
  final List<Conexion> conexiones;
  final int total;
  final String search;
  final ConexionEstado estado;
  final String ciudad;
  final String input;
  final bool orden;
  final List<Conexion> searchedConexiones;
  final int totalSearched;
  final BusquedaConexiones busquedaConexion;
  final bool isSearching;
  final String error;

  ConexionesState({
    this.isLoading = false,
    this.conexiones = const [],
    this.error = '',
    this.total = 0,
    this.search = '',
    this.estado = ConexionEstado.activos,
    this.ciudad = '',
    this.input = 'actaId',
    this.orden = false,
    this.searchedConexiones = const [],
    this.totalSearched = 0,
    this.busquedaConexion = const BusquedaConexiones(),
    this.isSearching = false,
  });

  ConexionesState copyWith({
    bool? isLoading,
    List<Conexion>? conexiones,
    String? error,
    int? total,
    String? search,
    ConexionEstado? estado,
    String? ciudad,
    String? input,
    bool? orden,
    List<Conexion>? searchedConexiones,
    int? totalSearched,
    BusquedaConexiones? busquedaConexion,
    bool? isSearching,
  }) {
    return ConexionesState(
      isLoading: isLoading ?? this.isLoading,
      conexiones: conexiones ?? this.conexiones,
      error: error ?? this.error,
      total: total ?? this.total,
      search: search ?? this.search,
      estado: estado ?? this.estado,
      ciudad: ciudad ?? this.ciudad,
      input: input ?? this.input,
      orden: orden ?? this.orden,
      searchedConexiones: searchedConexiones ?? this.searchedConexiones,
      totalSearched: totalSearched ?? this.totalSearched,
      busquedaConexion: busquedaConexion ?? this.busquedaConexion,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
