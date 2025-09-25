import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:ultrared/features/actividades/presentation/provider/actividad_provider.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/screen/full_screen_loader.dart';

class ActividadScreen extends ConsumerWidget {
  const ActividadScreen({
    super.key,
  });
  @override
  Widget build(BuildContext context, ref) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(contextProvider.notifier).state = context;
    // });
    ref.listen(
      actividadFormProvider,
      (_, next) {
        if (next.error.isEmpty) return;
        NotificationsService.show(context, next.error, SnackbarCategory.error);
      },
    );
    final actividadState = ref.watch(actividadFormProvider);
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
            ? const FullScreenLoader()
            : _ActividadForm(),
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
  const _ActividadForm();

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

    // docController = TextEditingController(text: widget.actividad.perDocNumero);
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
    // final actividadNotifier = ref.watch(actividadFormProvider.notifier);

    // final updateForm = actividadNotifier.updateState;
    // final actividadFormCopyWith =
    //     actividadState.actividadForm.copyWith;
    // final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Text(actividadState.actividadActive.actaDocCliente)
          ],
        ),
      ),
    );
  }
}
