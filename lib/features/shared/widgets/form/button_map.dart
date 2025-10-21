import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ultrared/features/actividades/domain/entities/ubicacion.dart';
import 'package:ultrared/features/shared/widgets/form/editable_map.dart'; 

class ButtonMap extends StatelessWidget {
  final Ubicacion ubicacion;
  final void Function(Ubicacion nuevaUbicacion) onUbicacionActualizada;

  const ButtonMap({
    super.key,
    required this.ubicacion,
    required this.onUbicacionActualizada,
  });

  Future<void> _abrirCoordenadas(BuildContext context) async {
    final lat = ubicacion.latitud;
    final lng = ubicacion.longitud;

    final wazeUrl = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(wazeUrl)) {
      await launchUrl(wazeUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      NotificationsService.show(
        context,
        'No se pudo abrir las coordenadas',
        SnackbarCategory.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.map),
          tooltip: 'Seleccionar ubicación',
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Selecciona la ubicación'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    child: EditableMap(
                      position: LatLng(ubicacion.latitud, ubicacion.longitud),
                      onPositionChanged: (newPos) {
                        onUbicacionActualizada(Ubicacion.fromLatLng(newPos));
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.directions),
          tooltip: 'Abrir en Waze o Google Maps',
          onPressed: () => _abrirCoordenadas(context),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lat: ${ubicacion.latitud.toStringAsFixed(6)}'),
            Text('Lng: ${ubicacion.longitud.toStringAsFixed(6)}'),
          ],
        ),
      ],
    );
  }
}