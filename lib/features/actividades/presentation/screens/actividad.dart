import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/actividades/domain/entities/ubicacion.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividad_provider.dart';
import 'package:ultrared/features/clientes/infrastructure/delegatesFunction/delegates.dart';
import 'package:ultrared/features/shared/infrastructure/delegatesFunction/delegates.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/provider/shared_data_provider.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/form/custom_date_picker_button.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expandable_email_list.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expandable_list_with_delegate.dart';
import 'package:ultrared/features/shared/widgets/form/editable_map.dart';

class ActividadScreen extends ConsumerWidget {
  const ActividadScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context, ref) {
    final actividadState = ref.watch(actividadFormProvider);
    ref.listen(
      actividadFormProvider,
      (_, next) {
        if (next.error.isEmpty) return;
        NotificationsService.show(context, next.error, SnackbarCategory.error);
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
      if (next.responseGetVendedores.error.isNotEmpty) {
        NotificationsService.show(
            context, next.responseGetVendedores.error, SnackbarCategory.error);
        ref
            .read(sharedDataProvider.notifier)
            .clearError(ErrorSharedType.vendedores);
      }
      if (next.responseGetPlanes.error.isNotEmpty) {
        NotificationsService.show(
            context, next.responseGetPlanes.error, SnackbarCategory.error);
        ref
            .read(sharedDataProvider.notifier)
            .clearError(ErrorSharedType.planes);
      }
      if (next.responseGetServicios.error.isNotEmpty) {
        NotificationsService.show(
            context, next.responseGetServicios.error, SnackbarCategory.error);
        ref
            .read(sharedDataProvider.notifier)
            .clearError(ErrorSharedType.servicios);
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(actividadState.actividadForm.actaId == 0
              ? 'Nueva Actividad'
              : 'Editar Actividad'),
        ),
        body: actividadState.isLoading
            // ||
            //         sharedDataState.responseGetCiudades.error.isNotEmpty
            ? const FullScreenLoader()
            : _ActividadForm(
                actividad: actividadState.actividadForm,
              ),
        floatingActionButton:
            actividadState.isLoading ? null : _FloatingButton(),
      ),
    );
  }
}

class _FloatingButton extends ConsumerWidget {
  const _FloatingButton();

  @override
  Widget build(BuildContext context, ref) {
    final actividadState = ref.watch(actividadFormProvider);
    return FloatingActionButton(
      onPressed: () async {
        // if (actividadState.isPosting) {
        //   return;
        // }
        // final exitoso = await actividadNotifier.onFormSubmit();

        // if (exitoso && context.mounted) {
        //   context.pop();
        //   NotificationsService.show(
        //       context,
        //       actividadState.actividadForm.ccFactura,
        //       SnackbarCategory.success);
        // }
      },
      child: actividadState.formStatus.isPosting
          ? SpinPerfect(
              duration: const Duration(seconds: 1),
              spins: 10,
              infinite: true,
              child: const Icon(Icons.refresh),
            )
          : const Icon(Icons.add),
    );
  }
}

class _ActividadForm extends ConsumerStatefulWidget {
  final Actividad actividad;
  const _ActividadForm({required this.actividad});

  @override
  _ActividadFormState createState() => _ActividadFormState();
}

class _ActividadFormState extends ConsumerState<_ActividadForm> {
  // late TextEditingController docController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar lista de ciudades
      ref.read(sharedDataProvider.notifier).loadCiudades();
      ref.read(sharedDataProvider.notifier).loadVendedores();
      ref.read(sharedDataProvider.notifier).loadPlanes(
            tipoPlan: widget.actividad.actaTipo,
          );
      ref.read(sharedDataProvider.notifier).loadServicios();
    });
    // docController =
    // TextEditingController(text: widget.actividad.actaDireccionCliente);
  }

  @override
  void dispose() {
    // docController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividadState = ref.watch(actividadFormProvider);
    final actividadNotifier = ref.watch(actividadFormProvider.notifier);
    final updateForm = actividadNotifier.updateState;
    final actividadFormCopyWith = actividadState.actividadForm.copyWith;
    final colors = Theme.of(context).colorScheme;
    final size = Responsive.of(context);
    final sharedData = ref.watch(sharedDataProvider);

    setClienteDelegate() async {
      final cliente = await searchClientesForeignDelegate(
        context: context,
        query: '',
        ref: ref,
      );
      if (cliente != null) {
        updateForm(
          actividadForm: actividadState.actividadForm.copyWith(
            actaIdCliente: cliente.perId,
            actaDocCliente: cliente.perDocNumero,
            actaNombreCliente: cliente.perNombre,
            actaDireccionCliente: cliente.perDireccion,
            actaTelCliente: cliente.perCelular,
            actaEmailCliente: cliente.perEmail,
            actaCiudad: cliente.ciudad,
            actaSector: cliente.sector.isNotEmpty ? [cliente.sector] : [],
          ),
        );
      }
    }

    setCiudadDelegate() async {
      final res = await setITemGenericDelegate(
        time: 0,
        context: context,
        initialItems: sharedData.responseGetCiudades.resultado,
        titleBuilder: (item) => item.ciuNombre,
      );

      if (res != null) {
        actividadNotifier.setSectores(res.ciuSectores);
        updateForm(
            actividadForm: actividadFormCopyWith(actaCiudad: res.ciuNombre));
      }
    }

    void setNewSectorDelegate() async {
      final res = await setITemGenericDelegate(
        time: 0,
        context: context,
        initialItems: actividadState.sectoresData,
        titleBuilder: (item) {
          return item.nombre;
        },
      );
      if (res != null) {
        final currentSectors = actividadState.actividadForm.actaSector;
        final newSector = (res.nombre).trim();
        final exists = currentSectors
            .any((s) => s.trim().toLowerCase() == newSector.toLowerCase());
        if (newSector.isNotEmpty && !exists) {
          updateForm(
            actividadForm: actividadFormCopyWith(
                actaSector: [newSector, ...currentSectors]),
          );
        }
      }
    }

    setVendedorDelegate() async {
      final res = await setITemGenericDelegate(
        time: 0,
        context: context,
        initialItems: sharedData.responseGetVendedores.resultado,
        titleBuilder: (item) => '${item.perDocNumero} - ${item.perNombre}',
      );
      if (res != null) {
        updateForm(
            actividadForm: actividadFormCopyWith(
          actaIdVendedor: res.perId,
          actaDocVendedor: res.perDocNumero,
          actaNombreVendedor: res.perNombre,
        ));
      }
    }

    setPlanDelegate() async {
      final res = await setITemGenericDelegate(
        time: 0,
        context: context,
        initialItems: sharedData.responseGetPlanes.resultado,
        titleBuilder: (item) =>
            "${item.planNombre} ** \$${item.planValor} ** MB${item.planMegas}",
      );

      if (res != null) {
        updateForm(
            actividadForm: actividadFormCopyWith(
          planNombreInternet: res.planNombre,
          planValorInternet: res.planValor,
          planMegasInternet: res.planMegas,
          actaIdPlanInternet: res.planId,
        ));
      }
    }

    void changePlanes(String value) {
      ref.read(sharedDataProvider.notifier).loadPlanes(
            tipoPlan: value,
          );
      updateForm(
          actividadForm: actividadFormCopyWith(
        planNombreInternet: '',
        planValorInternet: '',
        planMegasInternet: '',
        actaIdPlanInternet: 0,
      ));
    }

    setServicioDelegate() async {
      final res = await setITemGenericDelegate(
        time: 0,
        context: context,
        initialItems: sharedData.responseGetServicios.resultado,
        titleBuilder: (item) => item.nombre,
      );

      if (res != null) {
        updateForm(
            actividadForm: actividadFormCopyWith(
          actaServiciosVisita: res.nombre,
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomInputField(
              onTap: setClienteDelegate,
              readOnly: true,
              controller: TextEditingController(
                  text:
                      '${actividadState.actividadForm.actaDocCliente} ${actividadState.actividadForm.actaNombreCliente}'
                          .trim()),
              label: 'Cliente',
              onChanged: (p0) {},
              suffixIcon: IconButton(
                onPressed: setClienteDelegate,
                icon: Icon(
                  Icons.search,
                  color: colors.primary,
                ),
              ),
            ),
            CustomInputField(
              readOnly: true,
              controller: TextEditingController(
                  text: actividadState.actividadForm.actaDireccionCliente),
              label: 'Dirección Cliente',
              onChanged: (p0) {},
            ),
            CustomExpandableEmailList(
              // errorMessage:
              //     clienteFState.clienteForm.perEmailInput.errorMessage,
              label: 'Correos',
              onAddValue: (p0) {
                updateForm(
                    actividadForm: actividadFormCopyWith(actaEmailCliente: [
                  p0,
                  ...actividadState.actividadForm.actaEmailCliente
                ]));
              },
              onDeleteValue: (p0) {
                updateForm(
                    actividadForm: actividadFormCopyWith(actaEmailCliente: p0));
              },
              values: actividadState.actividadForm.actaEmailCliente,
            ),
            CustomInputField(
              readOnly: true,
              controller: TextEditingController(
                  text: actividadState.actividadForm.actaTelCliente.join(', ')),
              label: 'Tel Cliente',
              onChanged: (p0) {},
            ),
            CustomInputField(
              onTap: setCiudadDelegate,
              readOnly: true,
              controller: TextEditingController(
                  text: actividadState.actividadForm.actaCiudad),
              label: 'Sector',
              onChanged: (p0) {},
              suffixIcon: IconButton(
                onPressed: setCiudadDelegate,
                icon: Icon(
                  Icons.search,
                  color: colors.primary,
                ),
              ),
            ),
            CustomExpandableListWithDelagate(
              label: 'Lugares',
              onDeleteValue: (p0) {
                updateForm(
                  actividadForm: actividadFormCopyWith(actaSector: p0),
                );
              },
              values: actividadState.actividadForm.actaSector,
              onTap: setNewSectorDelegate,
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Selecciona la ubicación'),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: EditableMap(
                          position: LatLng(
                            actividadState.actividadForm.actaUbicacion.latitud,
                            actividadState.actividadForm.actaUbicacion.longitud,
                          ),
                          onPositionChanged: (newPos) {
                            updateForm(
                              actividadForm: actividadFormCopyWith(
                                actaUbicacion: Ubicacion.fromLatLng(newPos),
                              ),
                            );
                            // Puedes guardar, mostrar o usar esta posición como quieras
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.map),
            ),
            CustomSelectField(
              bold: false,
              errorMessage: '',
              size: size,
              label: 'Tipo',
              value: actividadState.actividadForm.actaTipo,
              onChanged: (String? value) async {
                updateForm(
                  actividadForm: actividadFormCopyWith(actaTipo: value),
                );
                if (value != null) {
                  changePlanes(value);
                }
              },
              options: [
                Option(label: 'HOME', value: 'HOME'),
                Option(label: 'EMPRESARIAL', value: 'EMPRESARIAL'),
                Option(label: 'CORPORATIVO', value: 'CORPORATIVO'),
              ],
            ),
            CustomSelectField(
              bold: false,
              errorMessage: '',
              size: size,
              label: 'Opción instalación',
              value: actividadState.actividadForm.actaOpcion,
              onChanged: (String? value) async {
                updateForm(
                  actividadForm: actividadFormCopyWith(actaOpcion: value),
                );
              },
              options: [
                Option(label: "Nueva Instalación", value: "Nueva Instalación"),
                Option(label: "Visita Técnica", value: "Visita Técnica"),
                Option(label: "Soporte Remoto", value: "Soporte Remoto"),
              ],
            ),
            CustomDatePickerButton(
                getDate: (value) {
                  updateForm(
                    actividadForm:
                        actividadFormCopyWith(actaFechaInstalacion: value),
                  );
                },
                label: 'Fecha Instalación',
                value: actividadState.actividadForm.actaFechaInstalacion),
            CustomInputField(
              onTap: setVendedorDelegate,
              readOnly: true,
              controller: TextEditingController(
                  text:
                      '${actividadState.actividadForm.actaDocVendedor} ${actividadState.actividadForm.actaNombreVendedor}'
                          .trim()),
              label: 'Vendedor',
              onChanged: (p0) {},
              suffixIcon: IconButton(
                onPressed: setVendedorDelegate,
                icon: Icon(
                  Icons.search,
                  color: colors.primary,
                ),
              ),
            ),
            CustomInputField(
              onTap: setPlanDelegate,
              readOnly: true,
              controller: TextEditingController(
                  text:
                      "${actividadState.actividadForm.planNombreInternet} ** \$${actividadState.actividadForm.planValorInternet} ** MB${actividadState.actividadForm.planMegasInternet}"
                          .trim()),
              label: 'Plan',
              onChanged: (p0) {},
              suffixIcon: IconButton(
                onPressed: setPlanDelegate,
                icon: Icon(
                  Icons.search,
                  color: colors.primary,
                ),
              ),
            ),
            CustomInputField(
              onTap: setServicioDelegate,
              readOnly: true,
              controller: TextEditingController(
                  text:
                      actividadState.actividadForm.actaServiciosVisita.trim()),
              label: 'Servicio',
              onChanged: (p0) {},
              suffixIcon: IconButton(
                onPressed: setServicioDelegate,
                icon: Icon(
                  Icons.search,
                  color: colors.primary,
                ),
              ),
            ),
            SizedBox(
              height: 150,
            )
          ],
        ),
      ),
    );
  }
}
