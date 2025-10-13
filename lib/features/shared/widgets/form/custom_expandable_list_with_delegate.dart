import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/widgets/form/custom_badge.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expansion_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomExpandableListWithDelegate extends StatelessWidget {
  final String label;
  final void Function(List<String>) onDeleteValue;
  final List<String> values;
  final bool? tel;
  final String? errorMessage;
  final void Function()? onTap;

  const CustomExpandableListWithDelegate({
    super.key,
    required this.label,
    required this.onDeleteValue,
    required this.values,
    this.tel,
    this.errorMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomExpansionTile(
      errorMessage: errorMessage,
      label: label,
      values: values,
      suffixIcon: onTap == null
          ? null
          : CustomBadge(
              value: '${values.length}',
              child: IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: onTap,
              ),
            ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: values.map((value) {
                  return ListTile(
                    title: Text(
                      value,
                      style: const TextStyle(fontSize: 12),
                    ),
                    leading: tel != null
                        ? IconButton(
                            icon: const Icon(FontAwesomeIcons.whatsapp,
                                size: 16, color: Colors.green),
                            onPressed: () async {
                              final Uri whatsappUrl =
                                  Uri.parse("https://wa.me/$value");

                              try {
                                await launchUrl(whatsappUrl,
                                    mode: LaunchMode.externalApplication);
                              } catch (e) {
                                if (context.mounted) {
                                  NotificationsService.show(
                                      context,
                                      "No se puede abrir WhatsApp",
                                      SnackbarCategory.error);
                                }
                              }
                            },
                          )
                        : null,
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                      onPressed: () {
                        List<String> updatedValues = List.from(values);
                        updatedValues
                            .remove(value); // Elimina el valor del arreglo
                        onDeleteValue(
                            updatedValues); // Llama a la función de eliminación con el arreglo actualizado
                      },
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ],
    );
  }
}
