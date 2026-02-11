import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/pppoe/domain/entities/actividad.dart';
import 'package:ultrared/features/pppoe/presentation/provider/conexion_provider.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart'; 
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/widgets/form/title_divider.dart';

class ConexionScreen extends ConsumerWidget {
  const ConexionScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context, ref) {
    final conexionState = ref.watch(conexionFormProvider);

    ref.listen(
      conexionFormProvider,
      (_, next) {
        if (next.error.isEmpty) return;
        NotificationsService.show(context, next.error, SnackbarCategory.error);
      },
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(conexionState.conexionForm.id == null
              ? 'Nueva Conexión'
              : 'Editar Conexión'),
        ),
        body: conexionState.isLoading
            // ||
            //         sharedDataState.responseGetCiudades.error.isNotEmpty
            ? const FullScreenLoader()
            : _ConexionForm(
                conexion: conexionState.conexionForm,
              ),
        floatingActionButton:
            conexionState.isLoading ? null : _FloatingButton(),
      ),
    );
  }
}

class _FloatingButton extends ConsumerWidget {
  const _FloatingButton();

  @override
  Widget build(BuildContext context, ref) {
    final conexionState = ref.watch(conexionFormProvider);
    final conexionNotifier = ref.watch(conexionFormProvider.notifier);
    return FloatingActionButton(
      onPressed: () async {
        if (conexionState.formStatus.isPosting) {
          return;
        }
        final exitoso = await conexionNotifier.onFormSubmit();

        if (exitoso && context.mounted) {
          context.pop();
          NotificationsService.show(
              context, 'Conexion Creada', SnackbarCategory.success);
        }
      },
      child: conexionState.formStatus.isPosting
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

class _ConexionForm extends ConsumerStatefulWidget {
  final Conexion conexion;
  const _ConexionForm({required this.conexion});

  @override
  _ConexionFormState createState() => _ConexionFormState();
}

class _ConexionFormState extends ConsumerState<_ConexionForm> {
  // late TextEditingController obsVenController = TextEditingController(); 
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar lista de ciudades
    });
    // obsVenController =
    //     TextEditingController(text: widget.conexion.actaCalidadIns); 
  }

  @override
  void dispose() {
    // obsVenController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final conexionState = ref.watch(conexionFormProvider);
    // final conexionNotifier = ref.watch(conexionFormProvider.notifier);
    // final updateForm = conexionNotifier.updateState;
    // final conexionFormCopyWith = conexionState.conexionForm.copyWith;
    // final colors = Theme.of(context).colorScheme;
    // final size = Responsive.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // DatoForm(label:'DocCliente', value:  conexionState.validacionConexion.actaDocCliente ?? ''),
            // DatoForm(label:'Ciudad', value:  conexionState.validacionConexion.actaCiudad ?? ''),
            // DatoForm(label:'Sector', value:  conexionState.validacionConexion.actaSector ?? ''),
            // DatoForm(label:'Fecha Instalación', value:  conexionState.validacionConexion.actaFechaInstalacion ?? ''),
            // DatoForm(label:'Doc Vendedor', value:  conexionState.validacionConexion.actaDocVendedor ?? ''),
            const TitleDivider(title: 'Cliente'),
            // this.actaDocCliente,
            // this.actaCiudad,
            // this.actaSector,
            // this.actaFechaInstalacion,
            // this.actaDocVendedor,
            // this.planNombreInternet,

            SizedBox(
              height: 150,
            )
          ],
        ),
      ),
    );
  }
}
