import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividad_provider.dart';
import 'package:ultrared/features/clientes/infrastructure/delegatesFunction/delegates.dart';
import 'package:ultrared/features/shared/infrastructure/delegatesFunction/delegates.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/provider/shared_data_provider.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expandable_email_list.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expandable_list_with_delegate.dart';

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
    // final sharedDataState = ref.watch(sharedDataProvider);
    ref.listen(sharedDataProvider, (_, next) {
      if (next.responseGetCiudades.error.isNotEmpty) {
        NotificationsService.show(
            context, next.responseGetCiudades.error, SnackbarCategory.error);
        ref.read(sharedDataProvider.notifier).clearErrorCiudades();
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
    // final actividadNotifier =
    //     ref.watch(actividadFormProvider(ccId).notifier);

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
  // late TextEditingController nombreController = TextEditingController();
  // late TextEditingController dirController = TextEditingController();
  // TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // final ciudades = ref.watch(sharedDataProvider.notifier).loadCiudades;

    // Evitar dependencias de InheritedWidgets en initState: ejecutar después del primer frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar lista de ciudades
      ref.read(sharedDataProvider.notifier).loadCiudades();
    });
    // docController =
    // TextEditingController(text: widget.actividad.actaDireccionCliente);
    // nombreController = TextEditingController(text: widget.actividad.perNombre);
    // dirController = TextEditingController(text: widget.actividad.perDireccion);
  }

  @override
  void dispose() {
    // docController.dispose();
    // nombreController.dispose();
    // dirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividadState = ref.watch(actividadFormProvider);
    final actividadNotifier = ref.watch(actividadFormProvider.notifier);
    final updateForm = actividadNotifier.updateState;
    final actividadFormCopyWith = actividadState.actividadForm.copyWith;
    final colors = Theme.of(context).colorScheme;

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
      final initialData = sharedData.responseGetCiudades.resultado;

      final res = await setITemGenericDelegate(
        context: context,
        initialItems: initialData,
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
          ],
        ),
      ),
    );
  }
}
