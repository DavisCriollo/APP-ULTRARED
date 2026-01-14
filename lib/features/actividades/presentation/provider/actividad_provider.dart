import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/actividades/domain/entities/ubicacion.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividades_provider.dart';
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/domain/entities/ciudad.dart';
import 'package:ultrared/features/shared/domain/repositores/upload_files_repository.dart';
import 'package:ultrared/features/shared/infrastructure/form/form_status.dart';
import 'package:ultrared/features/shared/provider/socket.dart';
import 'package:ultrared/features/shared/provider/upload_delete_files_provider.dart';

final actividadFormProvider = StateNotifierProvider.autoDispose<
    ActividadFormNotifier, ActividadFormState>((ref) {
  final actividadesProviderNotifier = ref.read(actividadesProvider.notifier);
  final usuario = ref.read(authProvider).user!;

  final socket = ref.watch(socketProvider);
  final UploadFilesRepository uploadFilesRepository =
      ref.read(uploadDeleteFilesProvider);
  return ActividadFormNotifier(
    socket: socket,
    createUpdateActividad: actividadesProviderNotifier.createUpdateActividad,
    getActividadById: actividadesProviderNotifier.getActividadById,
    usuario: usuario,
    uploadFilesRepository: uploadFilesRepository,
  );
});

class ActividadFormNotifier extends StateNotifier<ActividadFormState> {
  final Future<void> Function(Map<String, dynamic>, bool) createUpdateActividad;
  final User usuario;

  final io.Socket socket;
  final Future<GetActividadResponse> Function(int venId) getActividadById;
  final UploadFilesRepository uploadFilesRepository;
  ActividadFormNotifier({
    required this.getActividadById,
    required this.createUpdateActividad,
    required this.usuario,
    required this.socket,
    required this.uploadFilesRepository,
  }) : super(ActividadFormState(
          actividadForm: Actividad.defaultActividad(),
          actividadActive: Actividad.defaultActividad(),
          validacionActividad: ValidacionActividad(),
          formStatus: Formstatus(),
          // ccIdParam: ccIdParam,

          // placasData: [actividad.venOtrosDetalles],
        )) {
    getUbicacion();
  }

  void getUbicacion() async {
    state = state.copyWith(
      isLoading: true,
    );
    state = state.copyWith(ubicacionObtenida: await Ubicacion.obtenerActual());
    state = state.copyWith(
      isLoading: false,
    );
  }

  void loadActividad(Actividad actividadToActive) async {
    state = state.copyWith(
      isLoading: false,
      actividadForm: actividadToActive.actaId == 0
          ? actividadToActive.copyWith(actaUbicacion: state.ubicacionObtenida)
          : actividadToActive,
      actividadActive: actividadToActive,
    );
  }

  void defaultActividad() {
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

  void addimagenestoDelete(String url) {
    state = state.copyWith(imagenestoDelete: [...state.imagenestoDelete, url]);
  }

  Future<bool> onFormSubmit() async {
    // Marcar todos los campos como tocados
    final validacion = state.validacionActividad.validar(state.actividadForm);
    if (!validacion.isValid) {
      state = state.copyWith(
        validacionActividad: validacion,
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
      final resDocumentos = await uploadFilesRepository.uploadFiles(
          imagenes: state.actividadForm.actaFotos,
          tipo: 'documento',
          urlToDelete: state.imagenestoDelete);
      if (resDocumentos.error.isNotEmpty) {
        state = state.copyWith(
          error: resDocumentos.error,
          formStatus: state.formStatus.copyWith(
            isPosting: true,
          ),
        );
      }
      final actividadMap = {
        ...state.actividadForm
            .copyWith(
              actaFotos: resDocumentos.resultado,
              actaEntDoc: usuario.codigo,
              actaEntNombre: usuario.nombre,
            )
            .toJson(),
        "rucempresa": usuario.rucempresa,
        "rol": usuario.rol,
        "actaUser": usuario.usuario,
        "actaEmpresa": usuario.rucempresa,
        "tabla": "acta_entrega_recepcion",

        // actaFotos: resDocumentos,
        // nombres_tecnicos: tecnicos.join(", "),
      };

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

  void setSectores(List<CiuSector> sectores) {
    state = state.copyWith(sectoresData: sectores);
  }
}

class ActividadFormState {
  //* VENTA
  final bool isLoading;
  final String error;

//* VENTA-FORM
  final Actividad actividadActive;
  final Actividad actividadForm;
  final ValidacionActividad validacionActividad;
  final Formstatus formStatus;
  final Ubicacion? ubicacionObtenida;
  //*params
  final List<CiuSector> sectoresData;
  final List<String> imagenestoDelete;
  ActividadFormState({
    //* VENTA
    this.isLoading = true,
    this.error = '',
    //* VENTA-FORM
    required this.actividadActive,
    required this.actividadForm,
    required this.validacionActividad,
    required this.formStatus,
    this.ubicacionObtenida,
    //*params
    this.sectoresData = const [],
    this.imagenestoDelete = const [],
  }); // Provide default value here

  ActividadFormState copyWith({
    bool? isLoading,
    String? error,
    //* VENTA-FORM
    Actividad? actividadActive,
    Actividad? actividadForm,
    Formstatus? formStatus,
    ValidacionActividad? validacionActividad,
    Ubicacion? ubicacionObtenida,
    //*params
    List<CiuSector>? sectoresData,
    List<String>? imagenestoDelete,
  }) {
    return ActividadFormState(
      //* VENTA
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      //* VENTA-FORM

      actividadActive: actividadActive ?? this.actividadActive,
      actividadForm: actividadForm ?? this.actividadForm,
      formStatus: formStatus ?? this.formStatus,
      validacionActividad: validacionActividad ?? this.validacionActividad,
      ubicacionObtenida: ubicacionObtenida ?? this.ubicacionObtenida,
      //*params
      sectoresData: sectoresData ?? this.sectoresData,
      imagenestoDelete: imagenestoDelete ?? this.imagenestoDelete,
    );
  }
}
