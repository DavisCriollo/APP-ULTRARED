import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/actividades/infrastructure/delegatesFunction/delegates.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividad_provider.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividades_provider.dart';
import 'package:ultrared/features/actividades/presentation/widgets/actividad_card.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/main.dart';

class ActividadesScreen extends ConsumerStatefulWidget {
  final String search;
  const ActividadesScreen({
    super.key,
    this.search = '',
  });

  @override
  ConsumerState createState() => ActividadesViewState();
}

class ActividadesViewState extends ConsumerState<ActividadesScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.search.isNotEmpty) {
      Future.microtask(() {
        ref
            .read(actividadesProvider.notifier)
            .resetQuery(search: widget.search);
      });
    } else {
      Future.microtask(() {
        ref.read(actividadesProvider.notifier).loadNextPage();
      });
    }

    scrollController.addListener(
      () {
        if (scrollController.position.pixels + 400 >=
            scrollController.position.maxScrollExtent) {
          ref.read(actividadesProvider.notifier).loadNextPage();
        }
      },
    );
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
    final actividadesState = ref.watch(actividadesProvider);
    final loadActividad =
        ref.watch(actividadFormProvider.notifier).loadActividad;
    // final deleteActividad =
    //     ref.watch(actividadesProvider.notifier).;
    // final isAdmin = ref.watch(authProvider).isAdmin;
    ref.listen(
      actividadesProvider,
      (_, next) {
        if (next.error.isEmpty) return;
        NotificationsService.show(context, next.error, SnackbarCategory.error);
        ref.read(actividadesProvider.notifier).resetError();
      },
    );

    return DefaultTabController(
      length: ActividadEstado.values.length,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (actividadesState.isSearching)
              IconButton(
                  onPressed: () {
                    ref.read(actividadesProvider.notifier).resetQuery(
                        busquedaActividad: const BusquedaActividades(),
                        search: '');
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  )),
            IconButton(
                onPressed: () async {
                  final actividadesState = ref.read(actividadesProvider);
                  final searchActividadResult = await searchActividades(
                    context: context,
                    ref: ref,
                    actividadesState: actividadesState,
                    size: size,
                    loadActividad: loadActividad,
                  );
                  if (searchActividadResult?.wasLoading == true) {
                    ref
                        .read(actividadesProvider.notifier)
                        .searchActividadesByQueryWhileWasLoading();
                  }
                  if (searchActividadResult?.setBusqueda == true) {
                    ref.read(actividadesProvider.notifier).handleSearch();
                  }
                  if (!context.mounted) return;
                },
                icon: const Icon(Icons.search)),
          ],
          title: Text('Actividades ${actividadesState.total}'),
          // bottom: TabBar(
          //   isScrollable: true,
          //   tabs: ActividadEstado.values.map((estado) {
          //     final isSelected = actividadesState.estado == estado;
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
          //     final estado = ActividadEstado.values[index];
          //     ref.read(actividadesProvider.notifier).resetQuery(estado: estado);
          //   },
          // ),
        ),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                return ref.read(actividadesProvider.notifier).resetQuery();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [...ActividadEstado.values].map((estado) {
                        // children: [].map((estado) {
                        final isSelected = actividadesState.estado == estado;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, // Reducir el padding horizontal
                            ),
                            backgroundColor:
                                isSelected ? colors.primary : colors.secondary,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            ref
                                .read(actividadesProvider.notifier)
                                .resetQuery(estado: estado);
                          },
                          child: Text(
                            estado.value,
                            style: TextStyle(
                              color: isSelected
                                  ? colors.primary.contrastText
                                  : colors.secondary.contrastText,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (actividadesState.search.isNotEmpty)
                    Wrap(
                      children: [
                        Chip(
                          label:
                              Text('Buscando por: ${actividadesState.search}'),
                          deleteIcon: const Icon(Icons.clear),
                          onDeleted: () {
                            ref
                                .read(actividadesProvider.notifier)
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
                          //     value: actividadesState
                          //         .busquedaActividad.cajaFecha1,
                          //     getDate: (String date) {
                          //       ref
                          //           .read(actividadesProvider.notifier)
                          //           .resetQuery(
                          //               busquedaActividad:
                          //                   actividadesState
                          //                       .busquedaActividad
                          //                       .copyWith(cajaFecha1: date));
                          //     },
                          //   ),
                          // ),
                          // Expanded(
                          //   child: CustomDatePickerButton(
                          //     label: 'Fecha Fin',
                          //     value: actividadesState
                          //         .busquedaActividad.cajaFecha2,
                          //     getDate: (String date) {
                          //       ref
                          //           .read(actividadesProvider.notifier)
                          //           .resetQuery(
                          //               busquedaActividad:
                          //                   actividadesState
                          //                       .busquedaActividad
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
                              value: actividadesState.input,
                              onChanged: (String? value) {
                                ref
                                    .read(actividadesProvider.notifier)
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
                              actividadesState.orden
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                            ),
                            onPressed: () {
                              ref.read(actividadesProvider.notifier).resetQuery(
                                    orden: !actividadesState.orden,
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
                      itemCount: actividadesState.actividades.length,
                      itemBuilder: (context, index) {
                        final actividad = actividadesState.actividades[index];
                        return ActividadCard(
                          actividad: actividad,
                          size: size,
                          redirect: true,
                          loadActividad: loadActividad,
                          onDelete: () async {
                            // if (isAdmin) {
                            //   final res = await cupertinoModal(
                            //       context,
                            //       size,
                            //       '¿Esta seguro de eliminar este registro: ${actividad.ccNomCliente}?',
                            //       ['SI', 'NO']);
                            //   if (res == 'SI') {
                            //     // deleteActividad(actividad.cajaId);
                            //   }
                            // }
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.hScreen(12),
                  )
                ],
              ),
            ),
            if (actividadesState.isLoading)
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
        //           //   value: '${actividadesState.saldoAPagar}',
        //           //   onPressed: () {},
        //           // ),
        //           // ResumenButton(
        //           //   backgroundColor: Colors.green.shade100,
        //           //   textColor: Colors.green.shade700,
        //           //   label: 'Valor Total',
        //           //   value: '${actividadesState.valorTotalFacturas}',
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            loadActividad(Actividad.defaultActividad());
            context.push('/actividad/0');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
