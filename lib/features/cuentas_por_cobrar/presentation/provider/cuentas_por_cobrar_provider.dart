import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/cuentas_por_cobrar/domain/entities/banco.dart';
import 'package:ultrared/features/cuentas_por_cobrar/domain/entities/cuenta_por_cobrar.dart';
import 'package:ultrared/features/cuentas_por_cobrar/domain/repositores/cuentas_por_cobrar_repository.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/provider/cuentas_por_cobrar_repository_provider.dart';
import 'package:ultrared/features/shared/provider/download_pdf.dart';
import 'package:ultrared/features/shared/provider/socket.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum CuentaPorCobrarEstado { 
  general("GENERAL");
  // notaCuentasPorCobrar("NOTA VENTAS"),
  // proformas("PROFORMAS"),
  // notaCreditos("NOTA CREDITOS");

  final String value;
  const CuentaPorCobrarEstado(this.value);
}

class GetCuentaPorCobrarResponse {
  final CuentaPorCobrar? cuentaPorCobrar;
  final String error;

  GetCuentaPorCobrarResponse(
      {required this.cuentaPorCobrar, required this.error});
}

final cuentasPorCobrarProvider = StateNotifierProvider.autoDispose<
    CuentasPorCobrarNotifier, CuentasPorCobrarState>(
  (ref) {
    final authState = ref.watch(authProvider);
    final getUsuarioNombre = ref.watch(authProvider.notifier).getUsuarioNombre;
    final cuentasPorCobrarRepository =
        ref.watch(cuentasPorCobrarRepositoryProvider);
    final socket = ref.watch(socketProvider);
    final downloadPDF = ref.watch(downloadPdfProvider.notifier).downloadPDF;
    return CuentasPorCobrarNotifier(
      socket: socket,
      cuentasPorCobrarRepository: cuentasPorCobrarRepository,
      downloadPDF: downloadPDF,
      user: authState.user!,
      isAdmin: authState.isAdmin,
      getUsuarioNombre: getUsuarioNombre,
    );
  },
);

class CuentasPorCobrarNotifier extends StateNotifier<CuentasPorCobrarState> {
  final CuentasPorCobrarRepository cuentasPorCobrarRepository;
  final io.Socket socket;
  final User user;
  final bool isAdmin;
  final Future<void> Function(BuildContext? context, String infoPdf)
      downloadPDF;
  final Future<UsuarioNombreResponse> Function(String) getUsuarioNombre;
  CuentasPorCobrarNotifier({
    required this.cuentasPorCobrarRepository,
    required this.socket,
    required this.user,
    required this.downloadPDF,
    required this.isAdmin,
    required this.getUsuarioNombre,
  }) : super(CuentasPorCobrarState()) {
    print('INIT VENTAS PROVIDER');
    _initializeSocketListeners();
    _setBancos();
    // setSaldoPendiente();
  }

  // void setSaldoPendiente() async {
  //   final res =
  //       await cuentasPorCobrarRepository.getCuentasPorCobrarPendientes();
  //   if (res.error.isNotEmpty) {
  //     state = state.copyWith(error: res.error);
  //     return;
  //   }
  //   state = state.copyWith(
  //       saldoAPagar: res.saldoAPagar,
  //       valorTotalFacturas: res.valorTotalFacturas);
  // }

  void _setBancos() async {
    final res = await cuentasPorCobrarRepository.getBancos();
    if (res.error.isNotEmpty) {
      state = state.copyWith(error: res.error);
      return;
    }
    state = state.copyWith(bancos: res.bancos);
  }

  Future loadNextPage() async {
    // if (!isAdmin && state.page == 1) {
    // if (state.page == 1 && state.estado == CuentaPorCobrarEstado.diaria) {
    //   return;
    // }
    if (state.isLastPage || state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true);

    final cuentasPorCobrar =
        await cuentasPorCobrarRepository.getCuentasPorCobrarByPage(
      cantidad: state.cantidad,
      page: state.page,
      search: state.search,
      estado: state.estado.value,
      input: state.input,
      orden: state.orden,
      busquedaCuentasPorCobrar: state.busquedaCuentaPorCobrar,
    );

    if (cuentasPorCobrar.error.isNotEmpty) {
      state = state.copyWith(isLoading: false, error: cuentasPorCobrar.error);
      return;
    }
    if (cuentasPorCobrar.resultado.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        error: '',
        isLoading: false,
        page: state.page + 1,
        total: cuentasPorCobrar.total,
        cuentasPorCobrar: [
          ...state.cuentasPorCobrar,
          ...cuentasPorCobrar.resultado
        ]);
  }

  Future<List<CuentaPorCobrar>>
      searchCuentasPorCobrarByQueryWhileWasLoading() async {
    state = state.copyWith(isLoading: true);
    final cuentasPorCobrar =
        await cuentasPorCobrarRepository.getCuentasPorCobrarByPage(
      search: state.search,
      cantidad: state.cantidad,
      input: state.input,
      orden: state.orden,
      page: 0,
      estado: state.estado.value,
      busquedaCuentasPorCobrar: state.busquedaCuentaPorCobrar,
    );
    // ref.read(searchQueryProvider.notifier).update((state) => search);
    if (cuentasPorCobrar.error.isNotEmpty) {
      state = state.copyWith(error: cuentasPorCobrar.error, isLoading: false);
      return [];
    }

    state = state.copyWith(
        searchedCuentasPorCobrar: cuentasPorCobrar.resultado,
        totalSearched: cuentasPorCobrar.total,
        total: cuentasPorCobrar.total,
        cuentasPorCobrar: cuentasPorCobrar.resultado,
        isLastPage: false,
        isLoading: false,
        isSearching: state.search.isNotEmpty ||
            state.busquedaCuentaPorCobrar.isSearching());
    return cuentasPorCobrar.resultado;
  }

  Future<List<CuentaPorCobrar>> searchCuentasPorCobrarByQuery(
      {String search = ''}) async {
    final cuentasPorCobrar =
        await cuentasPorCobrarRepository.getCuentasPorCobrarByPage(
      search: search,
      cantidad: state.cantidad,
      input: state.input,
      orden: state.orden,
      page: 0,
      estado: state.estado.value,
      busquedaCuentasPorCobrar: state.busquedaCuentaPorCobrar,
    );
    // ref.read(searchQueryProvider.notifier).update((state) => search);
    if (cuentasPorCobrar.error.isNotEmpty) {
      state = state.copyWith(error: cuentasPorCobrar.error, search: search);
      return [];
    }

    state = state.copyWith(
        search: search,
        searchedCuentasPorCobrar: cuentasPorCobrar.resultado,
        totalSearched: cuentasPorCobrar.total,
        isLastPage: false,
        isSearching:
            search.isNotEmpty || state.busquedaCuentaPorCobrar.isSearching());
    return cuentasPorCobrar.resultado;
  }

  void setSearch(String search) {
    state = state.copyWith(search: search);
  }

  Future<GetCuentaPorCobrarResponse> getCuentaPorCobrarById(int ccId) async {
    try {
      final exist = [
        ...state.cuentasPorCobrar,
        ...state.searchedCuentasPorCobrar
      ].any((e) => e.ccId == ccId);
      if (!exist) {
        return GetCuentaPorCobrarResponse(
            cuentaPorCobrar: null, error: 'No se encontró el cuentaPorCobrar');
      }
      return GetCuentaPorCobrarResponse(
          cuentaPorCobrar: [
            ...state.cuentasPorCobrar,
            ...state.searchedCuentasPorCobrar
          ].firstWhere(
            (cuentaPorCobrar) => cuentaPorCobrar.ccId == ccId,
          ),
          error: '');
    } catch (e) {
      return GetCuentaPorCobrarResponse(
          cuentaPorCobrar: null,
          error: 'Hubo un error al consultar la cuentaPorCobrar');
    }
  }

  Future<void> resetQuery({
    String? search,
    CuentaPorCobrarEstado? estado,
    String? input,
    bool? orden,
    BusquedaCuentasPorCobrar? busquedaCuentaPorCobrar,
  }) async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true);
    // setSaldoPendiente();

    final cuentasPorCobrar =
        await cuentasPorCobrarRepository.getCuentasPorCobrarByPage(
      cantidad: state.cantidad,
      page: 0,
      search: search ?? state.search,
      estado: estado?.value ?? state.estado.value,
      input: input ?? state.input,
      orden: orden ?? state.orden,
      busquedaCuentasPorCobrar:
          busquedaCuentaPorCobrar ?? state.busquedaCuentaPorCobrar,
    );

    if (cuentasPorCobrar.error.isNotEmpty) {
      state = state.copyWith(isLoading: false, error: cuentasPorCobrar.error);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      page: 1,
      total: cuentasPorCobrar.total,
      cuentasPorCobrar: cuentasPorCobrar.resultado,
      search: search,
      estado: estado,
      input: input,
      orden: orden,
      isLastPage: false,
      busquedaCuentaPorCobrar: busquedaCuentaPorCobrar,
      isSearching: (search ?? state.search).isNotEmpty ||
          (busquedaCuentaPorCobrar ?? state.busquedaCuentaPorCobrar)
              .isSearching(),
    );
  }

  void handleSearch() async {
    if (state.search.isEmpty) {
      return;
    }
    state = state.copyWith(
        total: state.totalSearched,
        cuentasPorCobrar: state.searchedCuentasPorCobrar,
        page: 1,
        searchedCuentasPorCobrar: [],
        totalSearched: 0);
  }

  void resetError() {
    state = state.copyWith(error: '');
  }

  Future<void> createUpdateCuentaPorCobrar(
      Map<String, dynamic> cuentaPorCobrarMap, bool editando) async {
    if (editando) {
      socket.emit('client:actualizarData', cuentaPorCobrarMap);
    } else {
      socket.emit("client:guardarData", cuentaPorCobrarMap);
    }
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
        if (data['tabla'] == 'cuentasporcobrar' &&
            data['rucempresa'] == user.rucempresa) {
          // Edita de la lista de cuentasPorCobrar
          final updatedCuentaPorCobrar = CuentaPorCobrar.fromJson(data);
          final updatedCuentasPorCobrarList =
              state.cuentasPorCobrar.map((cuentaPorCobrar) {
            return cuentaPorCobrar.ccId == updatedCuentaPorCobrar.ccId
                ? updatedCuentaPorCobrar
                : cuentaPorCobrar;
          }).toList();
          state = state.copyWith(cuentasPorCobrar: updatedCuentasPorCobrarList);
        }
      }
    } catch (e) {}
  }

  void _onGuardadoExitoso(dynamic data) async {
    try {
      if (mounted) {
        if (data['tabla'] == 'cuentasporcobrar' &&
            data['rucempresa'] == user.rucempresa) {
          // Agrega a la lista de cuentasPorCobrar
          final newCuentaPorCobrar = CuentaPorCobrar.fromJson(data);
          if (isAdmin || newCuentaPorCobrar.ccUser == user.usuario) {
            state = state.copyWith(cuentasPorCobrar: [
              newCuentaPorCobrar,
              ...state.cuentasPorCobrar,
            ]);
          }
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

class CuentasPorCobrarState {
  final bool isLastPage;
  final bool isLoading;
  final int cantidad;
  final int page;
  final List<CuentaPorCobrar> cuentasPorCobrar;
  final int total;
  final String search;
  final CuentaPorCobrarEstado estado;
  final String input;
  final bool orden;
  final List<CuentaPorCobrar> searchedCuentasPorCobrar;
  final int totalSearched;
  final BusquedaCuentasPorCobrar busquedaCuentaPorCobrar;
  final bool isSearching;
  final String error;
  //* PARAMS
  final List<Banco> bancos;
  final double saldoAPagar; // <-- Nueva propiedad
  final double valorTotalFacturas; // <-- Nueva propiedad

  CuentasPorCobrarState({
    this.isLastPage = false,
    this.isLoading = false,
    this.cantidad = 10,
    this.page = 0,
    this.cuentasPorCobrar = const [],
    this.error = '',
    this.total = 0,
    this.search = '',
    this.estado = CuentaPorCobrarEstado.general,
    this.input = 'ccId',
    this.orden = false,
    this.searchedCuentasPorCobrar = const [],
    this.totalSearched = 0,
    this.busquedaCuentaPorCobrar = const BusquedaCuentasPorCobrar(),
    this.isSearching = false,
    this.bancos = const [],
    this.saldoAPagar = 0.0, // <-- Valor por defecto
    this.valorTotalFacturas = 0.0, // <-- Valor por defecto
  });

  CuentasPorCobrarState copyWith(
      {bool? isLastPage,
      bool? isLoading,
      int? cantidad,
      int? page,
      List<CuentaPorCobrar>? cuentasPorCobrar,
      String? error,
      int? total,
      String? search,
      CuentaPorCobrarEstado? estado,
      String? input,
      bool? orden,
      List<CuentaPorCobrar>? searchedCuentasPorCobrar,
      int? totalSearched,
      BusquedaCuentasPorCobrar? busquedaCuentaPorCobrar,
      bool? isSearching,
      List<Banco>? bancos,
      double? saldoAPagar, // <-- Nuevo parámetro
      double? valorTotalFacturas // <-- Nuevo parámetro
      }) {
    return CuentasPorCobrarState(
      isLastPage: isLastPage ?? this.isLastPage,
      isLoading: isLoading ?? this.isLoading,
      cantidad: cantidad ?? this.cantidad,
      page: page ?? this.page,
      cuentasPorCobrar: cuentasPorCobrar ?? this.cuentasPorCobrar,
      error: error ?? this.error,
      total: total ?? this.total,
      search: search ?? this.search,
      estado: estado ?? this.estado,
      input: input ?? this.input,
      orden: orden ?? this.orden,
      searchedCuentasPorCobrar:
          searchedCuentasPorCobrar ?? this.searchedCuentasPorCobrar,
      totalSearched: totalSearched ?? this.totalSearched,
      busquedaCuentaPorCobrar:
          busquedaCuentaPorCobrar ?? this.busquedaCuentaPorCobrar,
      isSearching: isSearching ?? this.isSearching,
      bancos: bancos ?? this.bancos,
      saldoAPagar: saldoAPagar ?? this.saldoAPagar, // <-- Nuevo valor
      valorTotalFacturas:
          valorTotalFacturas ?? this.valorTotalFacturas, // <-- Nuevo valor
    );
  }
}
