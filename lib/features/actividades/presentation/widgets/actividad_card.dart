import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/features/actividades/domain/entities/actividad.dart';
import 'package:ultrared/features/shared/helpers/format.dart';
import 'package:ultrared/features/shared/helpers/whatsapp.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/card/card_container.dart';
import 'package:ultrared/features/shared/widgets/card/card_mar_pad.dart';
import 'package:ultrared/features/shared/widgets/modal/cupertino_modal.dart';
import 'package:ultrared/main.dart';

class ActividadCard extends ConsumerWidget {
  final Actividad actividad;
  final Responsive size;
  final bool redirect;
  final Future<void> Function() onDelete; // Función para eliminar con Future
  final void Function(Actividad actividadToActive) loadActividad;
  final Future<void> Function(Actividad actividad)? changeEstadoActividad;
  const ActividadCard({
    super.key,
    required this.actividad,
    required this.size,
    required this.redirect,
    required this.onDelete, // Recibir la función de eliminación
    required this.loadActividad, // Recibir la función de eliminación
    this.changeEstadoActividad,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return CardMarPad(
      size: size,
      child: Slidable(
        key: ValueKey(actividad.actaId),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              backgroundColor: colors.primary.contrastText,
              onPressed: (a) async {
                String resC = await cupertinoModal(
                      context,
                      size,
                      'Cambio de estado',
                      [
                        "PENDIENTE",
                        "EN PROCESO",
                        "SUSPENDIDO",
                        "PROCESADO",
                        "ANULADO",
                      ],
                      warning: false,
                    ) ??
                    '';
                print(resC);
                if (changeEstadoActividad != null && resC.isNotEmpty) {
                  changeEstadoActividad!(
                    actividad.copyWith(actaEstado: resC),
                  );
                }
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
                  context.push('/actividad/${actividad.actaId}');
                  loadActividad(actividad);
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
                      // Estado con color
                      Text(
                        actividad.actaEstado,
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                          fontWeight: FontWeight.w600,
                          color: actividad.actaEstado == 'ANULADO'
                              ? Colors.red
                              : actividad.actaEstado == 'EN PROCESO'
                                  ? Colors.blue
                                  : actividad.actaEstado == 'SUSPENDIDO'
                                      ? Colors.purple
                                      : actividad.actaEstado == 'PROCESADO'
                                          ? Colors.green
                                          : actividad.actaEstado == 'PENDIENTE'
                                              ? Colors.orange
                                              : null,
                        ),
                      ),

                      // Id (resaltar si tiene actaRedWifi)
                      Text(
                        '# ${actividad.actaId}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                          fontWeight: FontWeight.bold,
                          color: (actividad.actaRedWifi.toString().isNotEmpty)
                              ? (Colors.teal)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Ciudad y sector
                      Text(
                        '${actividad.actaCiudad} · ${actividad.actaSector.join(", ")}',
                        style: TextStyle(fontSize: size.iScreen(1.4)),
                      ),

                      // Documento y nombre del cliente
                      Text(
                        '${actividad.actaDocCliente} ${actividad.actaNombreCliente}',
                        style: TextStyle(fontSize: size.iScreen(1.4)),
                      ),

                      // Teléfonos (si existen)
                      Column(
                        children: actividad.actaTelCliente.map(
                          (e) {
                            return Row(
                              children: [
                                Text(e),
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    onPressed: () {
                                      launchWhatsApp(context, e);
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.whatsapp,
                                      size:
                                          25, // Puedes ajustar este valor según lo pequeño que lo quieras
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ).toList(),
                      )
                      // Text(
                      //   .join(", "),
                      //   style: TextStyle(fontSize: size.iScreen(1.4)),
                      // ),
                    ],
                  ),
                ),
                // Columna derecha: tipo, opción, servicios, estado correo, usuario y fecha
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Tipo
                      Text(
                        actividad.actaTipo,
                        style: TextStyle(
                            fontSize: size.iScreen(1.4),
                            fontWeight: FontWeight.w600),
                      ),

                      // Opción con color para "Nueva Instalación"
                      Text(
                        actividad.actaOpcion,
                        style: TextStyle(
                          fontSize: size.iScreen(1.4),
                          color: actividad.actaOpcion == 'Nueva Instalación'
                              ? Colors.green
                              : null,
                        ),
                      ),

                      // Servicios (o guion si es nueva instalación)
                      Text(
                        actividad.actaOpcion == 'Nueva Instalación'
                            ? ' - '
                            : (actividad.actaServiciosVisita),
                        style: TextStyle(fontSize: size.iScreen(1.4)),
                      ),

                      // Estado del correo con colores
                      Text(
                        actividad.correoNuevoRegistro,
                        style: TextStyle(
                          fontSize: size.iScreen(1.4),
                          color: actividad.correoNuevoRegistro == 'PENDIENTE'
                              ? Colors.orange
                              : actividad.correoNuevoRegistro == 'ENVIADO'
                                  ? Colors.green
                                  : (actividad.correoNuevoRegistro ==
                                              'NO ENVIADO' ||
                                          actividad.correoNuevoRegistro ==
                                              'ERROR')
                                      ? Colors.red
                                      : null,
                        ),
                      ),

                      // Usuario responsable (nombre)
                      Text(
                        actividad.actaUser,
                        style: TextStyle(fontSize: size.iScreen(1.4)),
                      ),

                      // Fecha formateada (intenta parsear)
                      Text(
                        Format.formatFechaHora(actividad.actaFecReg),
                        style: TextStyle(fontSize: size.iScreen(1.4)),
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
