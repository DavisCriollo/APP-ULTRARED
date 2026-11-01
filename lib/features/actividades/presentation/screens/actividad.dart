import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividad_provider.dart';
import 'package:ultrared/features/actividades/presentation/widgets/cargo_card.dart';
import 'package:ultrared/features/actividades/presentation/widgets/equipo_instalado_card.dart';
import 'package:ultrared/features/actividades/presentation/widgets/show_dialog_cargo.dart';
import 'package:ultrared/features/actividades/presentation/widgets/show_dialog_equipo_instalado.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/clientes/infrastructure/delegatesFunction/delegates.dart';
import 'package:ultrared/features/shared/helpers/format.dart';
import 'package:ultrared/features/shared/helpers/whatsapp.dart';
import 'package:ultrared/features/shared/infrastructure/delegatesFunction/delegates.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/provider/shared_data_provider.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/form/button_map.dart';
import 'package:ultrared/features/shared/widgets/form/custom_date_picker_button.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expandable_email_list.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expandable_list_with_cards.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expandable_list_with_delegate.dart';
import 'package:ultrared/features/shared/widgets/form/image_gallery.dart';
import 'package:ultrared/features/shared/widgets/form/signature_field.dart';
import 'package:ultrared/features/shared/widgets/form/title_divider.dart';

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
              : 'Ver Actividad'),
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
    final actividadNotifier = ref.watch(actividadFormProvider.notifier);
    return FloatingActionButton(
      onPressed: () async {
        if (actividadState.formStatus.isPosting) {
          return;
        }
        final exitoso = await actividadNotifier.onFormSubmit();

        if (exitoso && context.mounted) {
          context.pop();
          NotificationsService.show(
              context, 'Actividad Creada', SnackbarCategory.success);
        }
      },
      child: actividadState.formStatus.isPosting
          ? SpinPerfect(
              duration: const Duration(seconds: 1),
              spins: 10,
              infinite: true,
              child: const Icon(Icons.refresh),
            )
          : const Icon(Icons.save),
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
  late TextEditingController obsVenController = TextEditingController();
  late TextEditingController obsTecController = TextEditingController();
  late TextEditingController ppoeController = TextEditingController();
  late TextEditingController claveController = TextEditingController();
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
    obsVenController =
        TextEditingController(text: widget.actividad.actaCalidadIns);
    obsTecController =
        TextEditingController(text: widget.actividad.actaDetalleEstado);
    ppoeController = TextEditingController(text: widget.actividad.actaRedWifi);
    claveController = TextEditingController(text: widget.actividad.actaClave);
  }

  @override
  void dispose() {
    obsVenController.dispose();
    obsTecController.dispose();
    ppoeController.dispose();
    claveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividadState = ref.watch(actividadFormProvider);
    final actividadNotifier = ref.watch(actividadFormProvider.notifier);
    final updateForm = actividadNotifier.updateState;
    final isTecnico =
        ref.read(authProvider.notifier).isRol(rolesToFind: ['TECNICO']);
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
            actividadForm: actividadFormCopyWith(
          actaCiudad: res.ciuNombre,
          actaSector: [],
        ));
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
            // DatoForm(label:'DocCliente', value:  actividadState.validacionActividad.actaDocCliente ?? ''),
            // DatoForm(label:'Ciudad', value:  actividadState.validacionActividad.actaCiudad ?? ''),
            // DatoForm(label:'Sector', value:  actividadState.validacionActividad.actaSector ?? ''),
            // DatoForm(label:'Fecha Instalación', value:  actividadState.validacionActividad.actaFechaInstalacion ?? ''),
            // DatoForm(label:'Doc Vendedor', value:  actividadState.validacionActividad.actaDocVendedor ?? ''),
            const TitleDivider(title: 'Cliente'),
            // this.actaDocCliente,
            // this.actaCiudad,
            // this.actaSector,
            // this.actaFechaInstalacion,
            // this.actaDocVendedor,
            // this.planNombreInternet,
            Text(isTecnico ? "isTecnico" : 'NO ES'),
            CustomInputField(
              errorMessage: actividadState.validacionActividad.actaDocCliente,
              onTap: isTecnico ? null : setClienteDelegate,
              readOnly: true,
              controller: TextEditingController(
                  text:
                      '${actividadState.actividadForm.actaDocCliente} ${actividadState.actividadForm.actaNombreCliente}'
                          .trim()),
              label: 'Cliente',
              onChanged: (p0) {},
              suffixIcon: IconButton(
                onPressed: isTecnico ? null : setClienteDelegate,
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
                if (isTecnico) {
                  return;
                }
                updateForm(
                    actividadForm: actividadFormCopyWith(actaEmailCliente: [
                  p0,
                  ...actividadState.actividadForm.actaEmailCliente
                ]));
              },
              onDeleteValue: (p0) {
                if (isTecnico) {
                  return;
                }
                updateForm(
                    actividadForm: actividadFormCopyWith(actaEmailCliente: p0));
              },
              values: actividadState.actividadForm.actaEmailCliente,
            ),
            // CustomExpandablePhoneList(
            //   label: 'Tel Cliente',
            //   onAddValue: (p0) {},
            //   onDeleteValue: (p0) {},
            //   values: actividadState.actividadForm.actaTelCliente,
            // ),

            CustomExpandableListWithDelegate(
              label: 'Tel Cliente',
              onDeleteValue: (p0) async {},
              trealingIcon: Icon(
                FontAwesomeIcons.whatsapp,
                color: Colors.green,
              ),
              onPressedTrealing: (value) async {
                launchWhatsApp(context, value);
              },
              values: actividadState.actividadForm.actaTelCliente,
            ),

            const TitleDivider(title: 'Ubicación'),
            CustomInputField(
              errorMessage: actividadState.validacionActividad.actaCiudad,
              onTap: isTecnico ? null : setCiudadDelegate,
              readOnly: true,
              controller: TextEditingController(
                  text: actividadState.actividadForm.actaCiudad),
              label: 'Sector',
              onChanged: (p0) {},
              suffixIcon: IconButton(
                onPressed: isTecnico ? null : setCiudadDelegate,
                icon: Icon(
                  Icons.search,
                  color: colors.primary,
                ),
              ),
            ),
            CustomExpandableListWithDelegate(
              errorMessage: actividadState.validacionActividad.actaSector,
              label: 'Lugares',
              onDeleteValue: (p0) {
                updateForm(
                  actividadForm: actividadFormCopyWith(actaSector: p0),
                );
              },
              values: actividadState.actividadForm.actaSector,
              onTap: isTecnico ? null : setNewSectorDelegate,
            ),
            ButtonMap(
              ubicacion: actividadState.actividadForm.actaUbicacion,
              onUbicacionActualizada: (nuevaUbicacion) {
                updateForm(
                  actividadForm: actividadFormCopyWith(
                    actaUbicacion: nuevaUbicacion,
                  ),
                );
              },
            ),
            const TitleDivider(title: 'Servicio'),
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
            if (actividadState.actividadForm.actaOpcion == "Nueva Instalación")
              CustomDatePickerButton(
                errorMessage:
                    actividadState.validacionActividad.actaFechaInstalacion,
                getDate: (value) {
                  updateForm(
                    actividadForm:
                        actividadFormCopyWith(actaFechaInstalacion: value),
                  );
                },
                label: 'Fecha Instalación',
                value: Format.formatFecha(
                    actividadState.actividadForm.actaFechaInstalacion),
              ),
            if (actividadState.actividadForm.actaOpcion == "Nueva Instalación")
              CustomInputField(
                errorMessage:
                    actividadState.validacionActividad.actaDocVendedor,
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
            if (actividadState.actividadForm.actaOpcion == "Nueva Instalación")
              CustomInputField(
                errorMessage:
                    actividadState.validacionActividad.planNombreInternet,
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
            if (actividadState.actividadForm.actaOpcion == "Visita Técnica" ||
                actividadState.actividadForm.actaOpcion == "Soporte Remoto")
              CustomInputField(
                onTap: setServicioDelegate,
                readOnly: true,
                controller: TextEditingController(
                    text: actividadState.actividadForm.actaServiciosVisita
                        .trim()),
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
            CustomInputField(
              controller: obsVenController,
              label: 'Observación Ventas',
              onChanged: (p0) {
                updateForm(
                    actividadForm: actividadFormCopyWith(actaCalidadIns: p0));
              },
              lines: 3,
              // errorMessage:
              //     clienteFState.clienteForm.perDocNumeroInput.errorMessage,
            ),
            CustomInputField(
              controller: obsTecController,
              label: 'Observación Técnico',
              onChanged: (p0) {
                updateForm(
                    actividadForm:
                        actividadFormCopyWith(actaDetalleEstado: p0));
              },
              lines: 3,
              // errorMessage:
              //     clienteFState.clienteForm.perDocNumeroInput.errorMessage,
            ),
            // IconButton(
            //   onPressed: () async {
            //     final res = await ref
            //         .read(uploadDeleteFilesProvider)
            //         .uploadFiles(
            //             imagenes: actividadState.actividadForm.actaFotos,
            //             tipo: 'archivo',
            //             urlToDelete: actividadState.imagenestoDelete,);

            //     print(res.resultado);
            //   },
            //   icon: Icon(Icons.cloud_upload),
            // ),
            const TitleDivider(title: 'Conexión'),
            CustomInputField(
              controller: ppoeController,
              label: 'PPPoE',
              onChanged: (p0) {
                updateForm(
                    actividadForm: actividadFormCopyWith(actaRedWifi: p0));
              },
              // errorMessage:
              //     clienteFState.clienteForm.perDocNumeroInput.errorMessage,
            ),
            CustomInputField(
              controller: claveController,
              label: 'Clave',
              onChanged: (p0) {
                updateForm(actividadForm: actividadFormCopyWith(actaClave: p0));
              },
              // errorMessage:
              //     clienteFState.clienteForm.perDocNumeroInput.errorMessage,
            ),
            ImageGallery(
              images: actividadState.actividadForm.actaFotos,
              size: size,
              onAdd: (imagenes) async {
                updateForm(
                    actividadForm: actividadFormCopyWith(actaFotos: [
                  ...actividadState.actividadForm.actaFotos,
                  ...imagenes
                ]));
              },
              onDelete: (url, isUploaded) {
                if (isUploaded) {
                  actividadNotifier.addimagenestoDelete(url);
                }
                updateForm(
                    actividadForm: actividadFormCopyWith(
                        actaFotos: actividadState.actividadForm.actaFotos
                            .where(
                              (element) => element.url != url,
                            )
                            .toList()));
              },
            ),
            const TitleDivider(title: 'Detalles'),
            CustomRadioBotton(
              selectedValue: actividadState.actividadForm.actaClienteRegulador,
              onChanged: (p0) {
                updateForm(
                    actividadForm:
                        actividadFormCopyWith(actaClienteRegulador: p0));
              },
              questionText: 'EL CLIENTE POSEE REGULADOR DE VOLTAJE:',
              size: size,
            ),
            CustomRadioBotton(
              selectedValue: actividadState.actividadForm.actaConfigRouter,
              onChanged: (p0) {
                updateForm(
                    actividadForm: actividadFormCopyWith(actaConfigRouter: p0));
              },
              questionText: 'CONFIGURACION ROUTER:',
              size: size,
            ),

            CustomRadioBotton(
              selectedValue: actividadState.actividadForm.actaCambioPatch,
              onChanged: (p0) {
                updateForm(
                    actividadForm: actividadFormCopyWith(actaCambioPatch: p0));
              },
              questionText: 'CAMBIO DE PATCH CORD FIBRA: ',
              size: size,
            ),
            const TitleDivider(title: 'Firma Del Cliente'),
            CustomRadioBotton(
              selectedValue:
                  actividadState.actividadForm.actaSeEncuentraCliente,
              onChanged: (p0) {
                updateForm(
                    actividadForm:
                        actividadFormCopyWith(actaSeEncuentraCliente: p0));
              },
              questionText: 'SE ENCUENTRA CLIENTE:',
              size: size,
            ),
            SignatureField(
                initialImageBase64: actividadState.actividadForm.actaEntFirma,
                onClear: () => updateForm(
                    actividadForm: actividadFormCopyWith(actaEntFirma: '')),
                onSave: (base64) => updateForm(
                      actividadForm:
                          actividadFormCopyWith(actaEntFirma: base64),
                    )),
            CustomExpandableListWithCards(
              label: 'Equipos Instalados',
              // errorMessage: '',
              values: actividadState.actividadForm.actaEquiposInstalados,
              onTap: () async {
                final res = await showEquipoInstaladoDialog(
                  context: context,
                  size: size,
                  editar: false,
                );
                if (res != null) {
                  updateForm(
                      actividadForm: actividadFormCopyWith(
                          actaEquiposInstalados: [
                        res,
                        ...actividadState.actividadForm.actaEquiposInstalados
                      ]));
                }
              },
              children: actividadState.actividadForm.actaEquiposInstalados
                  .map((value) {
                return EquipoInstaladoCard(
                  equipoInstalado: value,
                  loadActividad: (actividadToActive) async {
                    final res = await showEquipoInstaladoDialog(
                        context: context,
                        size: size,
                        editar: true,
                        equipoInstaladoToEdit: actividadToActive);
                    if (res != null) {
                      updateForm(
                          actividadForm: actividadFormCopyWith(
                              actaEquiposInstalados: actividadState
                                  .actividadForm.actaEquiposInstalados
                                  .map((e) => e.id == res.id ? res : e)
                                  .toList()));
                    }
                  },
                  onDelete: (actividadToDelete) async {
                    updateForm(
                        actividadForm: actividadFormCopyWith(
                            actaEquiposInstalados: actividadState
                                .actividadForm.actaEquiposInstalados
                                .where((e) => e.id != actividadToDelete.id)
                                .toList()));
                  },
                  size: size,
                );
              }).toList(),
            ),
            CustomExpandableListWithCards(
              label: 'Cargos',
              // errorMessage: '',
              values: actividadState.actividadForm.actaCargosAdicionales,
              onTap: () async {
                final res = await showCargoDialog(
                  context: context,
                  size: size,
                  editar: false,
                );
                if (res != null) {
                  updateForm(
                      actividadForm: actividadFormCopyWith(
                          actaCargosAdicionales: [
                        res,
                        ...actividadState.actividadForm.actaCargosAdicionales
                      ]));
                }
              },
              children: actividadState.actividadForm.actaCargosAdicionales
                  .map((value) {
                return CargoCard(
                  equipoInstalado: value,
                  loadActividad: (actividadToActive) async {
                    final res = await showCargoDialog(
                        context: context,
                        size: size,
                        editar: true,
                        equipoInstaladoToEdit: actividadToActive);
                    if (res != null) {
                      updateForm(
                          actividadForm: actividadFormCopyWith(
                              actaCargosAdicionales: actividadState
                                  .actividadForm.actaCargosAdicionales
                                  .map((e) => e.id == res.id ? res : e)
                                  .toList()));
                    }
                  },
                  onDelete: (actividadToDelete) async {
                    updateForm(
                        actividadForm: actividadFormCopyWith(
                            actaCargosAdicionales: actividadState
                                .actividadForm.actaCargosAdicionales
                                .where((e) => e.id != actividadToDelete.id)
                                .toList()));
                  },
                  size: size,
                );
              }).toList(),
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
