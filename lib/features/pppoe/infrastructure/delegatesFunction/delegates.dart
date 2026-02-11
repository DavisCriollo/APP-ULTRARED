import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/pppoe/domain/entities/actividad.dart';
import 'package:ultrared/features/pppoe/presentation/provider/conexiones_provider.dart';
import 'package:ultrared/features/pppoe/presentation/widgets/conexion_card.dart';
import 'package:ultrared/features/shared/delegate/generic_delegate.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

Future<SearchGenericResult<Conexion>?> searchConexiones(
    {required BuildContext context,
    required WidgetRef ref,
    required ConexionesState conexionesState,
    required Responsive size,
    required void Function(Conexion conexionToActive) loadConexion,
    required bool activo,
    required ConexionEstado estado}) async {
  return showSearch(
      query: conexionesState.search,
      context: context,
      delegate: GenericDelegate(
        onlySelect: false,
        itemWidgetBuilder: (item, onItemSelected) {
          return ConexionCard(
            loadConexion: loadConexion,
            redirect: false,
            conexion: item,
            size: size,
            activo: activo,
            onDelete: () async {},
            estado: estado,
          );
        },
        setSearch: ref.read(conexionesProvider.notifier).setSearch,
        initialItems: conexionesState.searchedConexiones,
        searchItems: ({search = ''}) {
          return ref
              .read(conexionesProvider.notifier)
              .searchConexionesByQuery(search: search);
        },
      ));
}
