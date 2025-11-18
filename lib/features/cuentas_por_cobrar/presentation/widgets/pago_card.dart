import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ultrared/features/cuentas_por_cobrar/domain/entities/cc_pago.dart';
import 'package:ultrared/features/shared/helpers/format.dart';
import 'package:ultrared/features/shared/provider/download_pdf.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/card/card_mar_pad.dart';
import 'package:ultrared/features/shared/widgets/card/card_container.dart';

class PagoCard extends ConsumerWidget {
  final CcPago pago;
  final Responsive size;
  final bool redirect;
  final Future<void> Function(String)
      onDelete; // Función para eliminar con Future

  const PagoCard({
    super.key,
    required this.pago,
    required this.size,
    required this.redirect,
    required this.onDelete, // Recibir la función de eliminación
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return CardMarPad(
      size: size,
      child: Slidable(
        key: ValueKey(pago.ccNumero),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            if (pago.ccEstado != 'ANULADO')
              SlidableAction(
                onPressed: (context) async {
                  await onDelete(pago
                      .uuid); // Llamar a la función de eliminación con await
                },
                foregroundColor: Colors.red,
                icon: Icons.delete,
                label: 'Anular',
              ),
          ],
        ),
        child: GestureDetector(
          onTap: redirect ? () {} : null,
          child: CardContainer(
            colors: colors,
            size: size,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Banco: ${pago.ccBanco}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                      Text(
                        Format.formatFechaHora(pago.ccFechaAbono),
                        style: TextStyle(fontSize: size.iScreen(1.5)),
                      ),
                      Text(
                        pago.ccDetalle,
                        style: TextStyle( 
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Comprobante:",
                            style: TextStyle(fontSize: size.iScreen(1.5)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download),
                            color: Colors.green,
                            onPressed: () {
                              final downloadPDF = ref
                                  .read(downloadPdfProvider.notifier)
                                  .downloadPDF;

                              downloadPDF(context, pago.ccComprobante);
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        "Valor: \$${pago.ccValor}",
                        style: TextStyle(
                            fontSize: size.iScreen(1.5),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        pago.ccTipo,
                        style: TextStyle(
                            fontSize: size.iScreen(1.5),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Deposito: ${pago.ccDeposito}",
                        style: TextStyle(fontSize: size.iScreen(1.5)),
                      ),
                      Text(
                        pago.ccEstado,
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                          fontWeight: FontWeight.bold,
                          color: pago.ccEstado == 'ANULADO'
                              ? colors.error
                              : Colors.green,
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
