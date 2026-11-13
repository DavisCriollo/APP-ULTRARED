import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/pppoe/presentation/provider/conexiones_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ultrared/features/pppoe/domain/entities/actividad.dart';
import 'package:ultrared/features/shared/helpers/format.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/card/card_container.dart';
import 'package:ultrared/features/shared/widgets/card/card_mar_pad.dart';
import 'package:ultrared/features/shared/widgets/modal/cupertino_modal.dart';
import 'package:ultrared/main.dart';

class ConexionCard extends ConsumerWidget {
  final Conexion conexion;
  final Responsive size;
  final bool redirect;
  final Future<void> Function() onDelete; // Función para eliminar con Future
  final void Function(Conexion conexionToActive) loadConexion;
  final bool activo;
  final ConexionEstado estado;

  final Future<bool> Function(
    String name,
    String id,
    bool status,
  )? changeEstado;
  const ConexionCard({
    super.key,
    required this.conexion,
    required this.activo,
    required this.size,
    required this.redirect,
    required this.onDelete, // Recibir la función de eliminación
    required this.loadConexion, // Recibir la función de eliminación
    this.changeEstado,
    required this.estado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return CardMarPad(
      size: size,
      child: Slidable(
        key: ValueKey(conexion.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              backgroundColor: colors.primary.contrastText,
              onPressed: (a) async {
                String resC = await cupertinoModal(
                      context,
                      size,
                      conexion.disabled == 'true'
                          ? '¿Deseas ACTIVAR esta conexión?'
                          : '¿Deseas DESACTIVAR esta conexión?',
                      [
                        "SI",
                        "NO",
                      ],
                      warning: conexion.disabled == 'false',
                    ) ??
                    '';
                if (resC == 'SI') {
                  final resultado = changeEstado != null
                      ? await changeEstado!(
                          conexion.name,
                          conexion.id!,
                          conexion.disabled == 'true' ? true : false,
                        )
                      : null;
                  print(resultado);
                  if (resultado == true) {
                    NotificationsService.show(
                      context,
                      'Estado de la conexión cambiado',
                      SnackbarCategory.success,
                    );
                  }
                }
                // if (changeEstadoConexion != null && resC.isNotEmpty) {}
              },
              foregroundColor: colors.primary,
              icon: Icons.change_circle,
              label: 'Cambiar Estado',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: redirect
              ? () {
                  if (estado == ConexionEstado.secret) {
                    context.push('/conexion/${conexion.id}');
                    loadConexion(conexion);
                  }
                }
              : null,
          child: CardContainer(
            colors: colors,
            size: size,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Columna izquierda: identificación, ubicación, cliente y teléfonos
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        conexion.name,
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),

                      // Nombre del cliente

                      // Servicio
                      Text(
                        'Servicio: ${conexion.service}',
                        style: TextStyle(fontSize: size.iScreen(1.3)),
                      ),

                      // Comentario
                      if (conexion.comment.isNotEmpty)
                        Text(
                          'Nota: ${conexion.comment}',
                          style: TextStyle(
                            fontSize: size.iScreen(1.3),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                // Columna derecha: mostrar dependiendo si está activo o inactivo
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Validar si está ACTIVO o INACTIVO
                      if (activo)
                        // ACTIVOS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _abrirIp(context, conexion.address),
                              child: Text(
                                'IP: ${conexion.address}',
                                style: TextStyle(
                                  fontSize: size.iScreen(1.4),
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),

                            // Fecha de inicio
                            Text(
                              Format.formatFechaHora(conexion.startedAtIso),
                              style: TextStyle(fontSize: size.iScreen(1.3)),
                            ),

                            // Tiempo de actividad
                            Text(
                              'T: ${conexion.uptimeDhms}',
                              style: TextStyle(
                                fontSize: size.iScreen(1.3),
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        )
                      else
                        // INACTIVOS
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Perfil
                            Text(
                              conexion.localAdress,
                              style: TextStyle(
                                fontSize: size.iScreen(1.4),
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text(
                              conexion.profile,
                              style: TextStyle(
                                fontSize: size.iScreen(1.4),
                              ),
                            ),

                            // Última desconexión
                            Text(
                              Format.formatFechaHora(conexion.lastLoggedOut),
                              style: TextStyle(
                                fontSize: size.iScreen(1.3),
                                color: Colors.grey,
                              ),
                            ),

                            // Estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: conexion.disabled == 'true'
                                    ? Colors.red.darken(0.1)
                                    : Colors.green.darken(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                conexion.disabled == 'true'
                                    ? 'INACTIVO'
                                    : 'ACTIVO',
                                style: TextStyle(
                                  fontSize: size.iScreen(1.3),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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

Future<void> _abrirIp(BuildContext context, String address) async {
  final url = Uri.parse('http://$address');
  try {
    await launchUrl(url);
  } catch (e) {
    if (!context.mounted) return;
    NotificationsService.show(
      context,
      'No se pudo abrir la URL',
      SnackbarCategory.error,
    );
  }
}
