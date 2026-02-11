import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/pppoe/domain/entities/actividad.dart';
import 'package:ultrared/features/pppoe/infrastructure/delegatesFunction/delegates.dart';
import 'package:ultrared/features/pppoe/presentation/provider/conexion_provider.dart';
import 'package:ultrared/features/pppoe/presentation/provider/conexiones_provider.dart';
import 'package:ultrared/features/pppoe/presentation/widgets/conexion_card.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/provider/shared_data_provider.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/buttons/custom_tab.dart';
import 'package:ultrared/main.dart';

class ConexionesScreen extends ConsumerStatefulWidget {
  final String search;
  final String ciudad;
  const ConexionesScreen({
    super.key,
    this.search = '',
    this.ciudad = '',
  });

  @override
  ConsumerState createState() => ConexionesViewState();
}

class ConexionesViewState extends ConsumerState<ConexionesScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(conexionesProvider.notifier)
          .resetQuery(search: widget.search, ciudad: widget.ciudad);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = Responsive.of(context);
    final conexionesState = ref.watch(conexionesProvider);
    final conexionesNotifi = ref.watch(conexionesProvider.notifier);
    final isLoadingConexion = ref.watch(conexionFormProvider).isLoading;
    final loadConexion = ref.watch(conexionFormProvider.notifier).loadConexion;
    // final deleteConexion =
    //     ref.watch(conexionesProvider.notifier).;
    // final isAdmin = ref.watch(authProvider).isAdmin;
    final sharedData = ref.watch(sharedDataProvider);
    ref.listen(
      conexionesProvider,
      (_, next) {
        if (next.error.isEmpty) return;
        NotificationsService.show(context, next.error, SnackbarCategory.error);
        ref.read(conexionesProvider.notifier).resetError();
      },
    );

    ref.listen(sharedDataProvider, (_, next) {
      if (next.responseGetCiudades.error.isNotEmpty) {
        NotificationsService.show(
            context, next.responseGetCiudades.error, SnackbarCategory.error);
        ref
            .read(sharedDataProvider.notifier)
            .clearError(ErrorSharedType.ciudades);
      }
    });
    return DefaultTabController(
      length: ConexionEstado.values.length,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (conexionesState.isSearching)
              IconButton(
                  onPressed: () {
                    ref.read(conexionesProvider.notifier).resetQuery(
                        busquedaConexion: const BusquedaConexiones(),
                        search: '');
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  )),
            IconButton(
                onPressed: () async {
                  final conexionesState = ref.read(conexionesProvider);
                  final searchConexionResult = await searchConexiones(
                    context: context,
                    ref: ref,
                    conexionesState: conexionesState,
                    size: size,
                    loadConexion: loadConexion,
                    activo: conexionesState.estado.value == 'ACTIVOS',
                    estado: conexionesState.estado,
                  );
                  if (searchConexionResult?.wasLoading == true) {
                    ref
                        .read(conexionesProvider.notifier)
                        .searchConexionesByQueryWhileWasLoading();
                  }
                  if (searchConexionResult?.setBusqueda == true) {
                    ref.read(conexionesProvider.notifier).handleSearch();
                  }
                  if (!context.mounted) return;
                },
                icon: const Icon(Icons.search)),
          ],
          title: Text('Conexiones ${conexionesState.total}'),
          // bottom: TabBar(
          //   isScrollable: true,
          //   tabs: ConexionEstado.values.map((estado) {
          //     final isSelected = conexionesState.estado == estado;
          //     return Tab(
          //       child: Text(
          //         estado.value,
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           color: isSelected
          //               ? colors.onSecondary
          //               : colors.onSecondary.withAlpha(150),
          //         ),
          //       ),
          //     );
          //   }).toList(),
          //   onTap: (index) {
          //     final estado = ConexionEstado.values[index];
          //     ref.read(conexionesProvider.notifier).resetQuery(estado: estado);
          //   },
          // ),
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                return ref.read(conexionesProvider.notifier).resetQuery();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [...ConexionEstado.values].map((estado) {
                        // children: [].map((estado) {
                        final isSelected = conexionesState.estado == estado;
                        return CustomTab(
                          isSelected: isSelected,
                          color: colors.secondary,
                          colorSelected: colors.secondary.lighten(.3),
                          texto: estado.value,
                          funcion: (param) {
                            ref
                                .read(conexionesProvider.notifier)
                                .resetQuery(estado: estado);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: sharedData.responseGetCiudades.resultado
                          .map((ciudad) {
                        // children: [].map((estado) {
                        final isSelected =
                            conexionesState.ciudad == ciudad.ciuNombre;
                        return CustomTab(
                          isSelected: isSelected,
                          color: colors.primary,
                          colorSelected: colors.primary.lighten(.1),
                          texto: ciudad.ciuNombre,
                          funcion: (param) {
                            ref
                                .read(conexionesProvider.notifier)
                                .resetQuery(ciudad: param);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  if (conexionesState.search.isNotEmpty)
                    Wrap(
                      children: [
                        Chip(
                          label:
                              Text('Buscando por: ${conexionesState.search}'),
                          deleteIcon: const Icon(Icons.clear),
                          onDeleted: () {
                            ref
                                .read(conexionesProvider.notifier)
                                .resetQuery(search: '');
                          },
                        ),
                      ],
                    ),
                  ExpansionTile(
                    dense: true,
                    title: const Text('Buscar - Ordenar'),
                    children: [
                      const Row(
                        verticalDirection: VerticalDirection.down,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Expanded(
                          //   child: CustomDatePickerButton(
                          //     label: 'Fecha inicio',
                          //     value: conexionesState
                          //         .busquedaConexion.cajaFecha1,
                          //     getDate: (String date) {
                          //       ref
                          //           .read(conexionesProvider.notifier)
                          //           .resetQuery(
                          //               busquedaConexion:
                          //                   conexionesState
                          //                       .busquedaConexion
                          //                       .copyWith(cajaFecha1: date));
                          //     },
                          //   ),
                          // ),
                          // Expanded(
                          //   child: CustomDatePickerButton(
                          //     label: 'Fecha Fin',
                          //     value: conexionesState
                          //         .busquedaConexion.cajaFecha2,
                          //     getDate: (String date) {
                          //       ref
                          //           .read(conexionesProvider.notifier)
                          //           .resetQuery(
                          //               busquedaConexion:
                          //                   conexionesState
                          //                       .busquedaConexion
                          //                       .copyWith(cajaFecha2: date));
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomSelectField(
                              size: size,
                              label: 'Ordenar Por',
                              value: conexionesState.input,
                              onChanged: (String? value) {
                                ref
                                    .read(conexionesProvider.notifier)
                                    .resetQuery(
                                      input: value,
                                    );
                              },
                              options: [
                                Option(label: "ID.", value: "actaId"),
                              ].toList(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              conexionesState.orden
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                            ),
                            onPressed: () {
                              ref.read(conexionesProvider.notifier).resetQuery(
                                    orden: !conexionesState.orden,
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: conexionesState.conexiones.length + 1,
                      itemBuilder: (context, index) {
                        if (index == conexionesState.conexiones.length) {
                          return SizedBox(height: 80); // Espacio dinámico
                        }

                        final conexion = conexionesState.conexiones[index];
                        return ConexionCard(
                          conexion: conexion,
                          size: size,
                          redirect: true,
                          loadConexion: loadConexion,
                          activo: conexionesState.estado.value == 'ACTIVOS',
                          changeEstado: conexionesNotifi.changeEstado,
                          estado: conexionesState.estado,
                          onDelete: () async {
                            // lógica de eliminación
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (conexionesState.isLoading)
              Positioned(
                bottom: 150,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: size.wScreen(100),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
        // bottomSheet: Container(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         children: [
        //           // ResumenButton(
        //           //   backgroundColor: Colors.green.shade100,
        //           //   textColor: Colors.green,
        //           //   label: 'Ingreso',
        //           //   value: '${cierreCajasState.sumaIEC.ingreso}',
        //           //   onPressed: () {},
        //           // ),
        //           // ResumenButton(
        //           //   backgroundColor: Colors.red.shade100,
        //           //   textColor: Colors.red,
        //           //   label: 'Saldo a Pagar',
        //           //   value: '${conexionesState.saldoAPagar}',
        //           //   onPressed: () {},
        //           // ),
        //           // ResumenButton(
        //           //   backgroundColor: Colors.green.shade100,
        //           //   textColor: Colors.green.shade700,
        //           //   label: 'Valor Total',
        //           //   value: '${conexionesState.valorTotalFacturas}',
        //           //   onPressed: () {},
        //           // ),
        //           // ResumenButton(
        //           //   backgroundColor: Colors.blue.shade100,
        //           //   textColor: Colors.blue,
        //           //   label: 'Total',
        //           //   value:
        //           //       '\$${Format.roundToTwoDecimals(cierreCajasState.sumaIEC.ingreso + cierreCajasState.sumaIEC.egreso)}',
        //           //   onPressed: () {},
        //           // ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        floatingActionButton: conexionesState.estado != ConexionEstado.secret
            ? null
            : FloatingActionButton(
                onPressed: isLoadingConexion
                    ? null
                    : () async {
                        loadConexion(Conexion.defaultConexion());
                        context.push('/conexion/0');
                      },
                child: isLoadingConexion
                    ? SpinPerfect(
                        duration: const Duration(seconds: 1),
                        spins: 10,
                        infinite: true,
                        child: const Icon(Icons.refresh),
                      )
                    : const Icon(Icons.add),
              ),
      ),
    );
  }
}
