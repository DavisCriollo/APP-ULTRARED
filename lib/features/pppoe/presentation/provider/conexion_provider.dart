import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/pppoe/domain/entities/actividad.dart';
import 'package:ultrared/features/pppoe/presentation/provider/conexiones_provider.dart';
import 'package:ultrared/features/shared/domain/entities/ciudad.dart';
import 'package:ultrared/features/shared/domain/repositores/upload_files_repository.dart';
import 'package:ultrared/features/shared/infrastructure/form/form_status.dart';
import 'package:ultrared/features/shared/provider/socket.dart';
import 'package:ultrared/features/shared/provider/upload_delete_files_provider.dart';

final conexionFormProvider =
    StateNotifierProvider.autoDispose<ConexionFormNotifier, ConexionFormState>(
        (ref) {
  final conexionesProviderNotifier = ref.read(conexionesProvider.notifier);
  final usuario = ref.read(authProvider).user!;

  final socket = ref.watch(socketProvider);
  final UploadFilesRepository uploadFilesRepository =
      ref.read(uploadDeleteFilesProvider);
  return ConexionFormNotifier(
    socket: socket,
    createUpdateConexion: conexionesProviderNotifier.createUpdateConexion, 
    usuario: usuario,
    uploadFilesRepository: uploadFilesRepository,
  );
});

class ConexionFormNotifier extends StateNotifier<ConexionFormState> {
  final Future<void> Function(Map<String, dynamic>, bool) createUpdateConexion;
  final User usuario;

  final io.Socket socket; 
  final UploadFilesRepository uploadFilesRepository;
  ConexionFormNotifier({ 
    required this.createUpdateConexion,
    required this.usuario,
    required this.socket,
    required this.uploadFilesRepository,
  }) : super(ConexionFormState(
          conexionForm: Conexion.defaultConexion(),
          conexionActive: Conexion.defaultConexion(),
          validacionConexion: ValidacionConexion(),
          formStatus: Formstatus(),
          // ccIdParam: ccIdParam,

          // placasData: [conexion.venOtrosDetalles],
        ));

  void loadConexion(Conexion conexionToActive) async {
    state = state.copyWith(
      isLoading: false,
      conexionForm:
          conexionToActive.id == null ? conexionToActive : conexionToActive,
      conexionActive: conexionToActive,
    );
  }

  void defaultConexion() {
    state = state.copyWith(
      isLoading: true,
      conexionForm: Conexion.defaultConexion(),
    );
  }

  void updateState({Conexion? conexionForm}) {
    state = state.copyWith(
      conexionForm: conexionForm ?? state.conexionForm,
    );
  }

  void addimagenestoDelete(String url) {
    state = state.copyWith(imagenestoDelete: [...state.imagenestoDelete, url]);
  }

  Future<bool> onFormSubmit() async {
    // Marcar todos los campos como tocados
    final validacion = state.validacionConexion.validar(state.conexionForm);
    if (!validacion.isValid) {
      state = state.copyWith(
        validacionConexion: validacion,
      );

      return false;
    }
    if (state.formStatus.isPosting) {
      return false;
    }

    state = state.copyWith(
      formStatus: state.formStatus.copyWith(
        isPosting: true,
      ),
    );

    try {
      // final resDocumentos = await uploadFilesRepository.uploadFiles(
      //     imagenes: state.conexionForm.actaFotos,
      //     tipo: 'documento',
      //     urlToDelete: state.imagenestoDelete);
      // if (resDocumentos.error.isNotEmpty) {
      //   state = state.copyWith(
      //     error: resDocumentos.error,
      //     formStatus: state.formStatus.copyWith(
      //       isPosting: true,
      //     ),
      //   );
      // }
      final conexionMap = {
        ...state.conexionForm.toJson(),
        "rucempresa": usuario.rucempresa,
        "rol": usuario.rol,
        "actaUser": usuario.usuario,
        "actaEmpresa": usuario.rucempresa,
        "tabla": "acta_entrega_recepcion",

        // actaFotos: resDocumentos,
        // nombres_tecnicos: tecnicos.join(", "),
      };

      createUpdateConexion(conexionMap, state.conexionForm.id != null);
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

  void setSectores(List<CiuSector> sectores) {
    state = state.copyWith(sectoresData: sectores);
  }
}

class ConexionFormState {
  //* VENTA
  final bool isLoading;
  final String error;

//* VENTA-FORM
  final Conexion conexionActive;
  final Conexion conexionForm;
  final ValidacionConexion validacionConexion;
  final Formstatus formStatus;
  //*params
  final List<CiuSector> sectoresData;
  final List<String> imagenestoDelete;
  ConexionFormState({
    //* VENTA
    this.isLoading = false,
    this.error = '',
    //* VENTA-FORM
    required this.conexionActive,
    required this.conexionForm,
    required this.validacionConexion,
    required this.formStatus,
    //*params
    this.sectoresData = const [],
    this.imagenestoDelete = const [],
  }); // Provide default value here

  ConexionFormState copyWith({
    bool? isLoading,
    String? error,
    //* VENTA-FORM
    Conexion? conexionActive,
    Conexion? conexionForm,
    Formstatus? formStatus,
    ValidacionConexion? validacionConexion,
    //*params
    List<CiuSector>? sectoresData,
    List<String>? imagenestoDelete,
  }) {
    return ConexionFormState(
      //* VENTA
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      //* VENTA-FORM

      conexionActive: conexionActive ?? this.conexionActive,
      conexionForm: conexionForm ?? this.conexionForm,
      formStatus: formStatus ?? this.formStatus,
      validacionConexion: validacionConexion ?? this.validacionConexion,
      //*params
      sectoresData: sectoresData ?? this.sectoresData,
      imagenestoDelete: imagenestoDelete ?? this.imagenestoDelete,
    );
  }
}
