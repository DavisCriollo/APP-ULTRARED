import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividades_provider.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/infrastructure/form/form_status.dart';
import 'package:ultrared/features/shared/provider/socket.dart';

final actividadFormProvider = StateNotifierProvider.autoDispose<
    ActividadFormNotifier, ActividadFormState>((ref) {
  final actividadesProviderNotifier = ref.read(actividadesProvider.notifier);
  final user = ref.read(authProvider).user!;
  final rol = user.rol;
  final rucempresa = user.rucempresa;
  final usuario = user.usuario;
  final socket = ref.watch(socketProvider);
  return ActividadFormNotifier(
    socket: socket,
    createUpdateActividad: actividadesProviderNotifier.createUpdateActividad,
    getActividadById: actividadesProviderNotifier.getActividadById,
    rol: rol,
    rucempresa: rucempresa,
    usuario: usuario,
  );
});

class ActividadFormNotifier extends StateNotifier<ActividadFormState> {
  final Future<void> Function(Map<String, dynamic>, bool) createUpdateActividad;
  final List<String> rol;
  final String rucempresa;
  final String usuario;
  final io.Socket socket;
  final Future<GetActividadResponse> Function(int venId) getActividadById;

  ActividadFormNotifier({
    required this.getActividadById,
    required this.createUpdateActividad,
    required this.socket,
    required this.rol,
    required this.rucempresa,
    required this.usuario,
  }) : super(ActividadFormState(
          actividadForm: Actividad.defaultActividad(),
          actividadActive: Actividad.defaultActividad(),
          formStatus: Formstatus(),
          // ccIdParam: ccIdParam,

          // placasData: [actividad.venOtrosDetalles],
        )) {
    // loadActividad();
  }

  void loadActividad(Actividad actividadToActive) async {
    state = state.copyWith(
      isLoading: false,
      actividadForm: actividadToActive,
      actividadActive: actividadToActive,
    );
  }

  void defaultActividad() async {
    state = state.copyWith(
      isLoading: true,
      actividadForm: Actividad.defaultActividad(),
    );
  }

  void updateState({Actividad? actividadForm}) {
    state = state.copyWith(
      actividadForm: actividadForm ?? state.actividadForm,
    );
  }

  void _touchedEverything(bool submit) {
    if (submit) {
      state = state.copyWith(
        formStatus: state.formStatus.copyWith(
            isPosted: true,
            // TODO: VALIDAR SI ES VALIDO
            isFormValid: false),
        // actividadForm: state.actividadForm.copyWith(
        //     // venRucCliente: state.actividadForm.venRucCliente,
        //     ),
      );
    }
  }

  Future<bool> onFormSubmitPago(bool enviarCorreo) async {
    // Marcar todos los campos como tocados
    _touchedEverything(true);

    // Esperar un breve momento para asegurar que el estado se actualice

    // Verificar si el formulario es válido y si ya se está posteando
    if (!state.formStatus.isFormValid) {
      return false;
    }
    if (state.formStatus.isPosting) {
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

    // Actualizar el estado para indicar que se está posteando
    state = state.copyWith(
      formStatus: state.formStatus.copyWith(
        isPosting: true,
      ),
    );

    try {
      // state = state.copyWith(
      //   actividadForm: state.actividadForm.copyWith(
      //     ccPagos: [
      //       state.pagoForm
      //           .copyWith(uuid: const Uuid().v4(), ccUsuario: usuario),
      //       ...state.actividadForm.ccPagos,
      //     ],
      //   ),
      // );
      final actividadMap = {
        // ...state.actividadForm.toActividad().toJson(),
        "rucempresa": rucempresa,
        "enviarCorreo": enviarCorreo,
        "rol": rol,
        "venUser": usuario,
        "venEmpresa": rucempresa,
        "tabla": "cuentasporcobrar",
      };

      // print(actividadMap);
      createUpdateActividad(actividadMap, state.actividadForm.actaId != 0);
      // Actualizar el estado para indicar que ya no se está posteando
      state = state.copyWith(
        formStatus: state.formStatus.copyWith(
          isPosting: false,
        ),
      );
      return true;
    } catch (e) {
      // Actualizar el estado para indicar que ya no se está posteando
      state = state.copyWith(
        formStatus: state.formStatus.copyWith(
          isPosting: false,
        ),
      );

      return false;
    }
  }

  void resetError() {
    state = state.copyWith(error: '');
  }

  setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

class ActividadFormState {
  //* VENTA
  final bool isLoading;
  final String error;

//* VENTA-FORM
  final Actividad actividadActive;
  final Actividad actividadForm;
  final Formstatus formStatus;
  ActividadFormState({
// //* VENTA
    this.isLoading = true,
    this.error = '',
//* VENTA-FORM
    required this.actividadActive,
    required this.actividadForm,
    required this.formStatus,
  }); // Provide default value here

  ActividadFormState copyWith({
    bool? isLoading,
    String? error,
    //* VENTA-FORM
    Actividad? actividadActive,
    Actividad? actividadForm,
    Formstatus? formStatus,
  }) {
    return ActividadFormState(
      //* VENTA
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      //* VENTA-FORM

      actividadActive: actividadActive ?? this.actividadActive,
      actividadForm: actividadForm ?? this.actividadForm,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
