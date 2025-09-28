import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/clientes/domain/entities/cliente.dart';
import 'package:ultrared/features/clientes/presentation/provider/clientes_repository_provider.dart';
import 'package:ultrared/features/shared/delegate/generic_delegate.dart';
import 'package:ultrared/features/shared/delegate/item_generic_search.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart'; 

Future<Cliente?> searchClientesForeignDelegate({
  required BuildContext context,
  required WidgetRef ref,
  required String query, 
}) async {
  final res = await showSearch(
    query: query,
    context: context,
    delegate: GenericDelegate(
      // customWidget: CustomButtonModal( 
      //   icon: Icons.add,
      //   onPressed: () {
      //     context.pop();
      //     context.push(
      //       '/cliente/0?ventaTab=$ventaTab&search=$queryUpdated',
      //     );
      //   },
      // ),
      itemWidgetBuilder: (clienteItem, onItemSelected) => ItemGenericSearch(
        item: clienteItem,
        title:
            '${clienteItem.perDocNumero} - ${clienteItem.perNombre} - ${clienteItem.perOtros}',
        onItemSelected: onItemSelected,
      ),
      searchItems: ({search = ''}) async {
        final res = await ref
            .read(clientesRepositoryProvider)
            .searchClientesForeign(search: search);
        if (res.error.isNotEmpty) {
          if (context.mounted) {
            NotificationsService.show(
                context, res.error, SnackbarCategory.error);
          }
          return <Cliente>[];
        }
        return res.resultado;
      },
      setSearch: (arg) {
        // queryUpdated = arg;
      },
      initialItems: <Cliente>[],
    ),
  );
  return res?.item;
}
