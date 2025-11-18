import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/cuentas_por_cobrar/domain/entities/cuenta_por_cobrar.dart';
import 'package:ultrared/features/shared/helpers/format.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/card/card_mar_pad.dart';
import 'package:ultrared/features/shared/widgets/card/card_container.dart';

class CuentaPorCobrarCard extends ConsumerWidget {
  final CuentaPorCobrar cuentaPorCobrar;
  final Responsive size;
  final bool redirect;
  final bool isAdmin;
  final Future<void> Function() onDelete; // Función para eliminar con Future

  const CuentaPorCobrarCard({
    Key? key,
    required this.cuentaPorCobrar,
    required this.size,
    required this.redirect,
    required this.isAdmin,
    required this.onDelete, // Recibir la función de eliminación
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return CardMarPad(
      size: size,
      child: Slidable(
        key: ValueKey(cuentaPorCobrar.ccId),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                await onDelete(); // Llamar a la función de eliminación con await
              },
              foregroundColor: Colors.black,
              icon: Icons.delete,
              label: 'Eliminar',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: redirect
              ? () {
                  context.push('/cuenta_cobrar/${cuentaPorCobrar.ccId}');
                }
              : null,
          child: CardContainer(
            colors: colors,
            size: size,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '# ${cuentaPorCobrar.ccFactura}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.45),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        cuentaPorCobrar.ccNomCliente,
                        style: TextStyle(fontSize: size.iScreen(1.45)),
                      ),
                      Text(
                        cuentaPorCobrar.ccRucCliente,
                        style: TextStyle(
                          fontSize: size.iScreen(1.45),
                        ),
                      ),
                      Text(
                        Format.formatFechaHora(cuentaPorCobrar.ccFecReg),
                        style: TextStyle(fontSize: size.iScreen(1.45)),
                      ),
                      Text(
                        "Usuario: ${cuentaPorCobrar.ccUser}",
                        style: TextStyle(fontSize: size.iScreen(1.45)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Text(
                        "Factura: \$${cuentaPorCobrar.ccValorFactura}",
                        style: TextStyle(
                            fontSize: size.iScreen(1.5),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Abono: \$${cuentaPorCobrar.ccAbono}",
                        style: TextStyle(fontSize: size.iScreen(1.5)),
                      ),
                      Text(
                        "Saldo: \$${cuentaPorCobrar.ccSaldo}",
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      Text(
                        cuentaPorCobrar.ccEstado,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.iScreen(1.7),
                          color: cuentaPorCobrar.ccEstado == 'PENDIENTE'
                              ? Colors.orange
                              : cuentaPorCobrar.ccEstado == 'CANCELADO'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                      Text(
                        cuentaPorCobrar.ccOtrosDetalles,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.iScreen(1.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
