import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class CustomDatePickerButton extends StatelessWidget {
  final String? errorMessage;
  final Function(String value) getDate;
  final String label;
  final String value;
  final bool disabled; // Nuevo parámetro para deshabilitar el botón

  const CustomDatePickerButton({
    super.key,
    this.errorMessage,
    required this.getDate,
    required this.label,
    required this.value,
    this.disabled = false, // Inicializado como false por defecto
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = Responsive.of(context);
    return SizedBox(
      width: size.wScreen(100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max, // Utiliza todo el ancho disponible
        children: [
          SizedBox(
            width: size.wScreen(1000), // Ocupa todo el ancho disponible
            child: ElevatedButton(
              onPressed: disabled
                  ? null // Si está deshabilitado, no se puede presionar
                  : () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.toLocal().year}-${pickedDate.toLocal().month.toString().padLeft(2, '0')}-${pickedDate.toLocal().day.toString().padLeft(2, '0')}";
                        getDate(formattedDate);
                      }
                    },
              style: OutlinedButton.styleFrom(
          
                alignment:
                    Alignment.centerLeft, // Alinear contenido a la izquierda
                side: BorderSide(
                  color: errorMessage != null
                      ? Colors.red
                      : disabled
                          ? Colors.grey // Borde gris si está deshabilitado
                          : colors.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 1, right: 4),
                    child: Icon(Icons.calendar_month),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: disabled
                              ? Colors.grey // Texto gris si está deshabilitado
                              : errorMessage != null
                                  ? Colors.red
                                  : colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left, // Alinear texto a la izquierda
                      ),
                      Text(
                        value == '' ? 'Seleccione' : value,
                        style: TextStyle(
                          color: disabled
                              ? Colors.grey // Texto gris si está deshabilitado
                              : errorMessage != null
                                  ? Colors.red
                                  : colors.primary,
                        ),
                        textAlign: TextAlign.left, // Alinear texto a la izquierda
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}