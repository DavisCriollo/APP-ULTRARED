import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/provider/cuenta_por_cobrar_provider.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/provider/cuentas_por_cobrar_provider.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/form/custom_date_picker_button.dart';
import 'package:ultrared/features/shared/widgets/form/dato_form.dart';
import 'package:ultrared/features/shared/widgets/form/upload_input.dart';
import 'package:ultrared/features/shared/widgets/modal/cupertino_modal.dart';

class PagoScreen extends ConsumerWidget {
  final int ccId;
  const PagoScreen({super.key, required this.ccId});
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ccId == 0 ? 'Nueva Caja' : 'Editar Cuenta por Cobrar'),
        ),
        body: _CuentaPorCobrarForm(
          ccId: ccId,
        ),
        floatingActionButton: _FloatingButton(
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
    final size = Responsive.of(context);
    final cuentaPorCobrarState = ref.watch(cuentaPorCobrarFormProvider(ccId));
    final cuentaPorCobrarNotifier =
        ref.watch(cuentaPorCobrarFormProvider(ccId).notifier);

    return FloatingActionButton(
      onPressed: () async {
        if (cuentaPorCobrarState.isPostingPago) {
          return;
        }
        final res = await cupertinoModal(
            context,
            size,
            '¿Desea notificar al cliente sobre el pago realizado?',
            ['SI', 'NO']);

        final exitoso =
            await cuentaPorCobrarNotifier.onFormSubmitPago(res == 'SI');

        if (exitoso && context.mounted) {
          context.pop();
          NotificationsService.show(
              context,
              cuentaPorCobrarState.cuentaPorCobrarForm.ccFactura,
              SnackbarCategory.success);
        }
      },
      child:
          cuentaPorCobrarState.isPostingPago || cuentaPorCobrarState.isLoading
              ? SpinPerfect(
                  duration: const Duration(seconds: 1),
                  spins: 10,
                  infinite: true,
                  child: const Icon(Icons.refresh),
                )
              : const Icon(Icons.save_as),
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

    final updateForm = cuentaPorCobrarNotifier.setCcPagoForm;
    final pagoFormCopyWith = cuentaPorCobrarState.pagoForm.copyWith;
    final colors = Theme.of(context).colorScheme;
    final cuentasPorCobrarState = ref.watch(cuentasPorCobrarProvider);
    final usuario = ref.read(authProvider).user!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SectionTitleDivider(title: 'Agregando Pago', fontSize: 18),
            SectionTitleDivider(
              title:
                  'Saldo: ${cuentaPorCobrarState.cuentaPorCobrarForm.ccSaldo}',
            ),
            if (cuentaPorCobrarState.pagoForm.uuid.isNotEmpty)
              SwitchListTile(
                dense: true, // Hace que el SwitchListTile sea más compacto
                value: cuentaPorCobrarState.pagoForm.estado == 'ACTIVO',
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                title: Text(
                  'Estado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.iScreen(1.8),
                  ),
                ),

                activeColor: colors.secondary
                    .withAlpha(75), // Color del interruptor cuando está activo
                activeTrackColor:
                    colors.secondary, // Color de la pista cuando está activo

                onChanged: cuentaPorCobrarState.pagoForm.uuid.isEmpty
                    ? null // Deshabilitar el interruptor si la caja es nueva
                    : (value) {
                        updateForm(pagoFormCopyWith(
                            estado: value ? "ACTIVO" : "ANULADO"));
                      },
              ),
            CustomSelectField(
              bold: false,
              size: size,
              label: 'Tipo',
              value: cuentaPorCobrarState.pagoForm.ccTipo,
              onChanged: (String? value) async {
                updateForm(pagoFormCopyWith(
                  ccTipo: value,
                  ccDeposito: value != 'EFECTIVO'
                      ? 'NINGUNO'
                      : cuentaPorCobrarState.pagoForm.ccDeposito,
                  ccBanco: value != 'EFECTIVO' ? 'Banco Del Pichincha' : '',
                ));
              },
              options: [
                Option(label: 'Seleccione...', value: '', enabled: false),
                Option(
                  label: "EFECTIVO",
                  value: "EFECTIVO",
                ),
                Option(
                  label: "RETENCION",
                  value: "RETENCION",
                ),
                Option(
                  label: "CHEQUE",
                  value: "CHEQUE",
                ),
                Option(
                  label: "TRANSFERENCIA",
                  value: "TRANSFERENCIA",
                ),
                Option(
                  label: "DEPOSITO",
                  value: "DEPOSITO",
                ),
                Option(
                  label: "TARJETA",
                  value: "TARJETA",
                ),
                Option(
                  label: "CRUCE COMPRA",
                  value: "CRUCE COMPRA",
                ),
                Option(
                  label: "DEBITO BANCARIO",
                  value: "DEBITO BANCARIO",
                ),
                Option(
                  label: "DONACION",
                  value: "DONACION",
                ),
                Option(
                  label: "CRÉDITO",
                  value: "CRÉDITO",
                ),
              ],
            ),
            UploadInput(
              label: 'Comprobante',
              onChanged: (p0) {
                updateForm(pagoFormCopyWith(ccComprobante: p0));
              },
              value: cuentaPorCobrarState.pagoForm.ccComprobante,
              setLoading: (p0) {
                cuentaPorCobrarNotifier.setLoading(p0);
              },
              isLoading: cuentaPorCobrarState.isLoading,
            ),
            CustomInputField(
              readOnly: cuentaPorCobrarState.pagoForm.ccTipo == 'EFECTIVO',
              label: 'Número',
              initialValue: cuentaPorCobrarState.pagoForm.ccNumero.toString(),
              onChanged: (p0) {
                updateForm(pagoFormCopyWith(
                  ccNumero: p0,
                ));
              },
              errorMessage: cuentaPorCobrarState.pagoForm.ccTipo != 'EFECTIVO'
                  ? cuentaPorCobrarState.pagoForm.ccNumeroInput.errorMessage
                  : null,
            ),
            CustomSelectField(
              bold: false,
              size: size,
              label: 'Banco',
              value: cuentaPorCobrarState.pagoForm.ccBanco,
              onChanged: (String? value) async {
                updateForm(pagoFormCopyWith(ccBanco: value));
              },
              enabled: cuentaPorCobrarState.pagoForm.ccTipo != 'EFECTIVO',
              options: [
                Option(label: 'Seleccione...', value: '', enabled: false),
                ...cuentasPorCobrarState.bancos.map((e) {
                  return Option(
                    label: e.banNombre,
                    value: e.banNombre,
                  );
                }).toList(),
              ],
            ),
            CustomSelectField(
              bold: false,
              size: size,
              label: 'Deposito',
              value: cuentaPorCobrarState.pagoForm.ccDeposito,
              onChanged: (String? value) async {
                updateForm(pagoFormCopyWith(ccDeposito: value));
              },
              enabled: cuentaPorCobrarState.pagoForm.ccTipo != 'EFECTIVO',
              options: [
                Option(label: 'Seleccione...', value: '', enabled: false),
                Option(
                  label: "SI",
                  value: "SI",
                ),
                Option(
                  label: "NO",
                  value: "NO",
                ),
                Option(
                  label: "NINGUNO",
                  value: "NINGUNO",
                ),
              ],
            ),
            CustomDatePickerButton(
              errorMessage:
                  cuentaPorCobrarState.pagoForm.ccFechaAbonoInput.errorMessage,
              label: 'Fec. Abono',
              value: cuentaPorCobrarState.pagoForm.ccFechaAbono,
              getDate: (String date) {
                updateForm(pagoFormCopyWith(ccFechaAbono: date));
              },
            ),
            CustomInputField(
              label: 'Valor',

              errorMessage:
                  cuentaPorCobrarState.pagoForm.ccValorInput.errorMessage,
              keyboardType: TextInputType.number,
              initialValue: cuentaPorCobrarState.pagoForm.ccValor.toString(),
              onChanged: (p0) {
                updateForm(pagoFormCopyWith(ccValor: double.tryParse(p0) ?? 0));
              },
              // errorMessage: clienteForm.perCanton.errorMessage,
            ),
            CustomInputField(
              label: 'Detalle',

              keyboardType: TextInputType.number,
              initialValue: cuentaPorCobrarState.pagoForm.ccDetalle.toString(),
              onChanged: (p0) {
                updateForm(pagoFormCopyWith(ccDetalle: p0));
              },
              // errorMessage: clienteForm.perCanton.errorMessage,
            ),
            DatoForm(label: 'Usuario', value: usuario.usuario),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class SectionTitleDivider extends StatelessWidget {
  final String title;
  final double fontSize;
  const SectionTitleDivider({
    super.key,
    required this.title,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
        ),
        const Expanded(
          child: Divider(thickness: 1),
        ),
      ],
    );
  }
}
