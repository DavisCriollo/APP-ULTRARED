import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/cuentas_por_cobrar/domain/entities/cc_pago.dart';
import 'package:ultrared/features/cuentas_por_cobrar/domain/entities/cuenta_por_cobrar.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/provider/cuentas_por_cobrar_provider.dart';
import 'package:ultrared/features/shared/helpers/parse.dart';
import 'package:ultrared/features/shared/infrastructure/inputs/generic_required_input_number.dart';
import 'package:ultrared/features/shared/provider/socket.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:uuid/uuid.dart';

final cuentaPorCobrarFormProvider = StateNotifierProvider.family
    .autoDispose<CuentaPorCobrarFormNotifier, CuentaPorCobrarFormState, int>(
        (ref, ccId) {
  final cuentasPorCobrarProviderNotifier =
      ref.read(cuentasPorCobrarProvider.notifier);
  final user = ref.read(authProvider).user!;
  final rol = user.rol;
  final rucempresa = user.rucempresa;
  final usuario = user.usuario;
  final socket = ref.watch(socketProvider);
  return CuentaPorCobrarFormNotifier(
    socket: socket,
    createUpdateCuentaPorCobrar:
        cuentasPorCobrarProviderNotifier.createUpdateCuentaPorCobrar,
    ccIdParam: ccId,
    getCuentaPorCobrarById:
        cuentasPorCobrarProviderNotifier.getCuentaPorCobrarById,
    rol: rol,
    rucempresa: rucempresa,
    usuario: usuario,
  );
});

class CuentaPorCobrarFormNotifier
    extends StateNotifier<CuentaPorCobrarFormState> {
  final Future<void> Function(Map<String, dynamic>, bool)
      createUpdateCuentaPorCobrar;
  final List<String> rol;
  final String rucempresa;
  final String usuario;
  final io.Socket socket;
  final Future<GetCuentaPorCobrarResponse> Function(int venId)
      getCuentaPorCobrarById;

  CuentaPorCobrarFormNotifier({
    required this.getCuentaPorCobrarById,
    required ccIdParam,
    required this.createUpdateCuentaPorCobrar,
    required this.socket,
    required this.rol,
    required this.rucempresa,
    required this.usuario,
  }) : super(CuentaPorCobrarFormState(
          cuentaPorCobrarForm: CuentaPorCobrarForm.fromCuentaPorCobrar(
              CuentaPorCobrar.defaultCuentaPorCobrar()),
          ccIdParam: ccIdParam,
          pagoForm: CcPagoForm.fromCcPago(CcPago.defaultCcPago()),

          // placasData: [cuentaPorCobrar.venOtrosDetalles],
        )) {
    loadCuentaPorCobrar();
    _initializeSocketListeners();
  }

  void _initializeSocketListeners() {
    socket.on("server:actualizadoExitoso", _onActualizadoExitoso);
  }

  void _onActualizadoExitoso(dynamic data) {
    try {
      if (mounted) {
        if (data['tabla'] == 'cuentasporcobrar' &&
            data['rucempresa'] == rucempresa) {
          // Edita de la lista de cuentasPorCobrar
          final updatedCuentaPorCobrar = CuentaPorCobrar.fromJson(data);
          if (updatedCuentaPorCobrar.ccId == state.cuentaPorCobrarForm.ccId) {
            state = state.copyWith(
              cuentaPorCobrarForm: CuentaPorCobrarForm.fromCuentaPorCobrar(
                updatedCuentaPorCobrar,
              ),
              pagoForm: CcPagoForm.fromCcPago(CcPago.defaultCcPago()).copyWith(
                  ccDetalle: updatedCuentaPorCobrar.ccFactura,
                  ccValor: Parse.parseDynamicToDouble(
                      updatedCuentaPorCobrar.ccSaldo)),
            );
          }
        }
      }
    } catch (e) {}
  }

  void loadCuentaPorCobrar() async {
    if (state.ccIdParam == 0) {
      state = state.copyWith(
        isLoading: false,
      );
      return;
    }
    final res = await getCuentaPorCobrarById(state.ccIdParam);
    if (!mounted) return;
    if (res.error.isNotEmpty) {
      state = state.copyWith(
        isLoading: true,
        error: res.error,
      );
      _resetError();
      return;
    }

    state = state.copyWith(
      isLoading: false,
      cuentaPorCobrarForm: CuentaPorCobrarForm.fromCuentaPorCobrar(
        res.cuentaPorCobrar!,
      ),
      pagoForm: CcPagoForm.fromCcPago(CcPago.defaultCcPago()).copyWith(
          ccDetalle: res.cuentaPorCobrar!.ccFactura,
          ccValor: Parse.parseDynamicToDouble(res.cuentaPorCobrar!.ccSaldo)),
    );
  }

  void updateState({CuentaPorCobrarForm? cuentaPorCobrarForm}) {
    state = state.copyWith(
      cuentaPorCobrarForm: cuentaPorCobrarForm ?? state.cuentaPorCobrarForm,
    );
    _touchedEverything(false);
  }

  void setCcPagoForm(CcPagoForm ccPagoForm) {
    state = state.copyWith(
      pagoForm: ccPagoForm,
    );
    _touchedEverythingPago(false);
  }

  void _touchedEverything(bool submit) {
    if (submit) {
      state = state.copyWith(
          cuentaPorCobrarForm: state.cuentaPorCobrarForm.copyWith(
              // venRucCliente: state.cuentaPorCobrarForm.venRucCliente,
              ),
          isFormValid: Formz.validate([
            // GenericRequiredInput.dirty(state.cuentaPorCobrarForm.venRucCliente),
          ]));
    } else {
      state = state.copyWith(
          isFormValid: Formz.validate([
        // GenericRequiredInput.dirty(state.cuentaPorCobrarForm.venRucCliente),
      ]));
    }
  }

  Future<bool> onFormSubmitPago(bool enviarCorreo) async {
    // Marcar todos los campos como tocados
    _touchedEverythingPago(true);

    // Esperar un breve momento para asegurar que el estado se actualice

    // Verificar si el formulario es válido y si ya se está posteando
    if (!state.isFormValidPago) {
      return false;
    }
    if (state.isPostingPago) {
      return false;
    }
    // if (!(["EFECTIVO", "CRUCE COMPRA", "DONACION"]
    //         .contains(state.pagoForm.ccTipo)) &&
    //     state.pagoForm.ccComprobante.isEmpty) {
    //   state = state.copyWith(
    //     error: "El tipo de pago seleccionado requiere un comprobante.",
    //   );
    //   _resetError();
    //   return false;
    // }
    if (Parse.parseDynamicToDouble(state.cuentaPorCobrarForm.ccSaldo) <
        Parse.parseDynamicToDouble(state.pagoForm.ccValor)) {
      state = state.copyWith(
        error: "El valor del pago no puede ser mayor al saldo pendiente.",
      );
      _resetError();
      return false;
    }

    // Actualizar el estado para indicar que se está posteando
    state = state.copyWith(isPostingPago: true);

    try {
      state = state.copyWith(
        cuentaPorCobrarForm: state.cuentaPorCobrarForm.copyWith(
          ccPagos: [
            state.pagoForm
                .copyWith(uuid: const Uuid().v4(), ccUsuario: usuario),
            ...state.cuentaPorCobrarForm.ccPagos,
          ],
        ),
        pagoForm: CcPagoForm.fromCcPago(CcPago.defaultCcPago()).copyWith(
            ccDetalle: state.cuentaPorCobrarForm.ccFactura,
            ccValor:
                Parse.parseDynamicToDouble(state.cuentaPorCobrarForm.ccSaldo)),
      );
      final cuentaPorCobrarMap = {
        ...state.cuentaPorCobrarForm.toCuentaPorCobrar().toJson(),
        "rucempresa": rucempresa,
        "enviarCorreo": enviarCorreo,
        "rol": rol,
        "venUser": usuario,
        "venEmpresa": rucempresa,
        "tabla": "cuentasporcobrar",
      };

      // print(cuentaPorCobrarMap);
      createUpdateCuentaPorCobrar(
          cuentaPorCobrarMap, state.cuentaPorCobrarForm.ccId != 0);
      // Actualizar el estado para indicar que ya no se está posteando
      state = state.copyWith(
        isPostingPago: false,
      );
      return true;
    } catch (e) {
      // Actualizar el estado para indicar que ya no se está posteando
      state = state.copyWith(isPostingPago: false);

      return false;
    }
  }

  Future<bool> anularPago(String uuid) async {
    // Marcar todos los campos como tocados
    _touchedEverything(true);

    // Esperar un breve momento para asegurar que el estado se actualice

    // Verificar si el formulario es válido y si ya se está posteando
    if (!state.isFormValid) {
      return false;
    }
    if (state.isPosting) {
      return false;
    }
    // Actualizar el estado para indicar que se está posteando
    state = state.copyWith(isPosting: true);

    try {
      state = state.copyWith(
        cuentaPorCobrarForm: state.cuentaPorCobrarForm.copyWith(
          ccPagos: state.cuentaPorCobrarForm.ccPagos.map(
            (pago) {
              if (pago.uuid == uuid) {
                return CcPagoForm.fromCcPago(
                  pago.copyWith(
                    ccEstado: "ANULADO",
                    estado: "ANULADO",
                  ),
                ).toCcPago();
              }
              return pago;
            },
          ).toList(),
        ),
        pagoForm: CcPagoForm.fromCcPago(CcPago.defaultCcPago()),
      );
      final cuentaPorCobrarMap = {
        ...state.cuentaPorCobrarForm.toCuentaPorCobrar().toJson(),
        "rucempresa": rucempresa,
        "rol": rol,
        "venUser": usuario,
        "venEmpresa": rucempresa,
        "tabla": "cuentasporcobrar",
      };

      // print(cuentaPorCobrarMap);
      createUpdateCuentaPorCobrar(
          cuentaPorCobrarMap, state.cuentaPorCobrarForm.ccId != 0);
      // Actualizar el estado para indicar que ya no se está posteando
      state = state.copyWith(
        isPosting: false,
      );
      return true;
    } catch (e) {
      // Actualizar el estado para indica que ya no se está posteando
      state = state.copyWith(isPosting: false);

      return false;
    }
  }

  void _touchedEverythingPago(bool submit) {
    state = state.copyWith(
        isFormValidPago: Formz.validate(
      [
        GenericRequiredInput.dirty(state.pagoForm.ccTipo),
        GenericRequiredInput.dirty(state.pagoForm.ccDeposito),
        GenericRequiredInputNumber.dirty(state.pagoForm.ccValor,
            condition: true),
        GenericRequiredInputNumber.dirty(
            Parse.parseDynamicToDouble(state.pagoForm.ccNumero),
            condition: state.pagoForm.ccTipo != 'EFECTIVO'),
        GenericRequiredInput.dirty(state.pagoForm.ccFechaAbono),
      ],
    ));
    // if (submit) {
    //   state = state.copyWith(
    //       isFormValid: Formz.validate([
    //     // GenericRequiredInput.dirty(state.cuentaPorCobrarForm.venRucCliente),
    //     GenericRequiredInput.dirty(state.pagoForm.ccTipo),
    //     GenericRequiredInput.dirty(state.pagoForm.ccDeposito),
    //     GenericRequiredInputNumber.dirty(state.pagoForm.ccValor),
    //     GenericRequiredInput.dirty(state.pagoForm.ccFechaAbono),
    //   ]));
    // } else {
    //   state = state.copyWith(
    //       isFormValid: Formz.validate([
    //     // GenericRequiredInput.dirty(state.cuentaPorCobrarForm.venRucCliente),
    //   ]));
    // }
  }

  void _resetError() {
    state = state.copyWith(error: '');
  }

  @override
  void dispose() {
    socket.off("server:actualizadoExitoso", _onActualizadoExitoso);

    super.dispose();
  }

  setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

class CuentaPorCobrarFormState {
  // final CuentaPorCobrar cuentaPorCobrar;
  final int ccIdParam;
  final bool isLoading;
  final String error;

  //* FORMULARIO
  final bool isFormValid;
  final bool isPosted;
  final bool isPosting;
  final CuentaPorCobrarForm cuentaPorCobrarForm;
  final bool isFormValidPago;
  final bool isPostedPago;
  final bool isPostingPago;
  final CcPagoForm pagoForm;

  CuentaPorCobrarFormState({
// //* VENTA
    required this.ccIdParam,

    // required this.cuentaPorCobrar,
    this.isLoading = true,
    this.error = '',
//* VENTA-FORM
    required this.cuentaPorCobrarForm,
    this.isFormValid = false,
    this.isPosted = false,
    this.isPosting = false,
    //* PAGO FORM
    required this.pagoForm,
    this.isFormValidPago = false,
    this.isPostedPago = false,
    this.isPostingPago = false,
  }); // Provide default value here

  CuentaPorCobrarFormState copyWith({
    int? ccIdParam,
    bool? isLoading,
    bool? isFormValid,
    bool? isPosted,
    bool? isPosting,
    CuentaPorCobrarForm? cuentaPorCobrarForm,
    String? error,
    bool? isFormValidPago,
    bool? isPostedPago,
    bool? isPostingPago,
    CcPagoForm? pagoForm,
  }) {
    return CuentaPorCobrarFormState(
      ccIdParam: ccIdParam ?? this.ccIdParam,
      isLoading: isLoading ?? this.isLoading,
      isFormValid: isFormValid ?? this.isFormValid,
      isPosted: isPosted ?? this.isPosted,
      isPosting: isPosting ?? this.isPosting,
      cuentaPorCobrarForm: cuentaPorCobrarForm ?? this.cuentaPorCobrarForm,
      error: error ?? this.error,
      isFormValidPago: isFormValidPago ?? this.isFormValidPago,
      isPostedPago: isPostedPago ?? this.isPostedPago,
      isPostingPago: isPostingPago ?? this.isPostingPago,
      pagoForm: pagoForm ?? this.pagoForm,
    );
  }
}
