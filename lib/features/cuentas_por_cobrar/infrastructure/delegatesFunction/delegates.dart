import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:ultrared/features/cuentas_por_cobrar/domain/entities/cuenta_por_cobrar.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/provider/cuentas_por_cobrar_provider.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/widgets/cuenta_por_cobrar_card.dart';
import 'package:ultrared/features/shared/delegate/generic_delegate.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

Future<SearchGenericResult<CuentaPorCobrar>?> searchCuentasPorCobrar(
    {required BuildContext context,
    required WidgetRef ref,
    required CuentasPorCobrarState  cuentasPorCobrarState,
    required bool isAdmin,
    required Responsive size}) async {
  return showSearch(
      query: cuentasPorCobrarState.search,
      context: context,
      delegate: GenericDelegate(
        onlySelect: false,
        itemWidgetBuilder: (item, onItemSelected) {
          return CuentaPorCobrarCard(
            redirect: false,
            cuentaPorCobrar: item,
            size: size,
            isAdmin: isAdmin,
            onDelete: () async {},
          );
        },
        setSearch: ref.read(cuentasPorCobrarProvider.notifier).setSearch,
        initialItems: cuentasPorCobrarState.searchedCuentasPorCobrar,
        searchItems: ({search = ''}) {
          return ref
              .read(cuentasPorCobrarProvider.notifier)
              .searchCuentasPorCobrarByQuery(search: search);
        },
      ));
}
