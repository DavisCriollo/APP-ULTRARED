import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/provider/cuenta_por_cobrar_provider.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/widgets/pago_card.dart';
import 'package:ultrared/features/shared/helpers/format.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/form/dato_form.dart';
import 'package:ultrared/features/shared/widgets/form/title_divider.dart';
import 'package:ultrared/features/shared/widgets/modal/cupertino_modal.dart';

class CuentaPorCobrar extends ConsumerWidget {
  final int ccId;
  const CuentaPorCobrar({super.key, required this.ccId});
  @override
  Widget build(BuildContext context, ref) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(contextProvider.notifier).state = context;
    // });
    ref.listen(
      cuentaPorCobrarFormProvider(ccId),
      (_, next) {
        if (next.error.isEmpty) return;
        NotificationsService.show(context, next.error, SnackbarCategory.error);
      },
    );
    final cuentaPorCobrarState = ref.watch(cuentaPorCobrarFormProvider(ccId));
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ccId == 0 ? 'Nueva Caja' : 'Editar Cuenta por Cobrar'),
        ),
        body: cuentaPorCobrarState.isLoading
            ? const FullScreenLoader()
            : _CuentaPorCobrarForm(
                ccId: ccId,
              ),
        floatingActionButton: cuentaPorCobrarState.isLoading
            ? null
            : _FloatingButton(
                ccId: ccId,
              ),
      ),
    );
  }
}

class _FloatingButton extends ConsumerWidget {
  final int ccId;
  const _FloatingButton({
    required this.ccId,
  });

  @override
  Widget build(BuildContext context, ref) {
    final cuentaPorCobrarState = ref.watch(cuentaPorCobrarFormProvider(ccId));
    // final cuentaPorCobrarNotifier =
    //     ref.watch(cuentaPorCobrarFormProvider(ccId).notifier);

    return FloatingActionButton(
      onPressed: () async {
        context.push('/pago/$ccId');
        // if (cuentaPorCobrarState.isPosting) {
        //   return;
        // }
        // final exitoso = await cuentaPorCobrarNotifier.onFormSubmit();

        // if (exitoso && context.mounted) {
        //   context.pop();
        //   NotificationsService.show(
        //       context,
        //       cuentaPorCobrarState.cuentaPorCobrarForm.ccFactura,
        //       SnackbarCategory.success);
        // }
      },
      child: cuentaPorCobrarState.isPosting
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

class _CuentaPorCobrarForm extends ConsumerStatefulWidget {
  final int ccId;
  const _CuentaPorCobrarForm({
    required this.ccId,
  });

  @override
  _CuentaPorCobrarFormState createState() => _CuentaPorCobrarFormState();
}

class _CuentaPorCobrarFormState extends ConsumerState<_CuentaPorCobrarForm> {
  // late TextEditingController docController = TextEditingController();
  // late TextEditingController nombreController = TextEditingController();
  // late TextEditingController dirController = TextEditingController();
  // TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // docController = TextEditingController(text: widget.cuentaPorCobrar.perDocNumero);
    // nombreController = TextEditingController(text: widget.cuentaPorCobrar.perNombre);
    // dirController = TextEditingController(text: widget.cuentaPorCobrar.perDireccion);
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
    final cuentaPorCobrarState =
        ref.watch(cuentaPorCobrarFormProvider(widget.ccId));
    final cuentaPorCobrarNotifier =
        ref.watch(cuentaPorCobrarFormProvider(widget.ccId).notifier);

    final size = Responsive.of(context);

    // final updateForm = cuentaPorCobrarNotifier.updateState;
    // final cuentaPorCobrarFormCopyWith =
    //     cuentaPorCobrarState.cuentaPorCobrarForm.copyWith;
    // final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const TitleDivider(title: 'Datos Principales', fontSize: 18),
            DatoForm(
              label: 'RUC:',
              value: cuentaPorCobrarState.cuentaPorCobrarForm.ccRucCliente,
            ),
            DatoForm(
              label: 'Nombre:',
              value: cuentaPorCobrarState.cuentaPorCobrarForm.ccNomCliente,
            ),
            const TitleDivider(title: 'Factura'),
            DatoForm(
              label: 'N°:',
              value: cuentaPorCobrarState.cuentaPorCobrarForm.ccFactura,
            ),
            DatoForm(
              label: 'Fecha:',
              value: Format.formatFecha(
                  cuentaPorCobrarState.cuentaPorCobrarForm.ccFechaFactura),
            ),
            DatoForm(
              label: 'Procedencia:',
              value: cuentaPorCobrarState.cuentaPorCobrarForm.ccProcedencia,
            ),
            DatoForm(
              label: 'Estado:',
              value: cuentaPorCobrarState.cuentaPorCobrarForm.ccEstado,
            ),
            DatoForm(
              label: 'Fecha Abono:',
              value: Format.formatFecha(
                  cuentaPorCobrarState.cuentaPorCobrarForm.ccFechaAbono),
            ),
            DatoForm(
              label: 'Fecha Registro:',
              value: Format.formatFechaHora(
                  cuentaPorCobrarState.cuentaPorCobrarForm.ccFecReg),
            ),
            const TitleDivider(title: 'Valores'),
            DatoForm(
              label: 'Valor Factura:',
              value:
                  '\$${cuentaPorCobrarState.cuentaPorCobrarForm.ccValorFactura}',
            ),
            DatoForm(
              label: 'Valor Retención:',
              value:
                  '\$${cuentaPorCobrarState.cuentaPorCobrarForm.ccValorRetencion}',
            ),
            DatoForm(
              label: 'Valor a Pagar:',
              value:
                  '\$${cuentaPorCobrarState.cuentaPorCobrarForm.ccValorAPagar}',
            ),
            DatoForm(
              label: 'Abono:',
              value: '\$${cuentaPorCobrarState.cuentaPorCobrarForm.ccAbono}',
            ),
            DatoForm(
              label: 'Saldo:',
              value: '\$${cuentaPorCobrarState.cuentaPorCobrarForm.ccSaldo}',
              color: Colors.red,
            ),
            TitleDivider(
              title:
                  "Pagos: ${cuentaPorCobrarState.cuentaPorCobrarForm.ccPagos.length}",
              action: IconButton(
                onPressed: () {
                  context.push('/pago/${widget.ccId}');
                },
                icon: const Icon(Icons.add),
              ),
            ),
            ...cuentaPorCobrarState.cuentaPorCobrarForm.ccPagos.map((pago) {
              return PagoCard(
                pago: pago,
                size: size,
                redirect: false,
                onDelete: (uuid) async {
                  final res = await cupertinoModal(context, size,
                      '¿Está seguro de ANULAR este pago?', ['SI', 'NO']);
                  if (res == 'SI') {
                    cuentaPorCobrarNotifier.anularPago(uuid);
                  }
                },
              );
            }).toList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
