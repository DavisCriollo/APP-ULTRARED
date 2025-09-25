import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/actividades/presentation/provider/actividades_provider.dart';
import 'package:ultrared/features/actividades/presentation/widgets/actividad_card.dart';
import 'package:ultrared/features/shared/delegate/generic_delegate.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

Future<SearchGenericResult<Actividad>?> searchActividades(
    {required BuildContext context,
    required WidgetRef ref,
    required ActividadesState actividadesState,
    required Responsive size,
    required void Function(Actividad actividadToActive) loadActividad}) async {
  return showSearch(
      query: actividadesState.search,
      context: context,
      delegate: GenericDelegate(
        onlySelect: false,
        itemWidgetBuilder: (item, onItemSelected) {
          return ActividadCard(
            loadActividad: loadActividad,
            redirect: false,
            actividad: item,
            size: size,
            onDelete: () async {},
          );
        },
        setSearch: ref.read(actividadesProvider.notifier).setSearch,
        initialItems: actividadesState.searchedActividades,
        searchItems: ({search = ''}) {
          return ref
              .read(actividadesProvider.notifier)
              .searchActividadesByQuery(search: search);
        },
      ));
}
