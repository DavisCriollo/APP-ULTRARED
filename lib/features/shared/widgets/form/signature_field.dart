import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureField extends StatefulWidget {
  final String? initialImageBase64;
  final void Function(String base64)? onSave;
  final void Function()? onClear;
  const SignatureField(
      {super.key, this.initialImageBase64, this.onSave, this.onClear});

  @override
  State<SignatureField> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<SignatureField> {
  final SignatureController _controller =
      SignatureController(penStrokeWidth: 2, penColor: Colors.black);

  String? _savedBase64;

  @override
  void initState() {
    super.initState();
    _savedBase64 = widget.initialImageBase64;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.isNotEmpty) {
      final Uint8List? data = await _controller.toPngBytes();
      if (data != null) {
        final base64 = 'data:image/png;base64,${base64Encode(data)}';
        setState(() => _savedBase64 = base64);
        widget.onSave?.call(base64);
      }
    }
  }

  void _clear() {
    _controller.clear();
    setState(() => _savedBase64 = null);
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_savedBase64 != null && _savedBase64!.isNotEmpty) {
      // Mostrar imagen guardada
      final uri = _savedBase64!;
      final bytes = base64Decode(uri.split(',').last);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Image.memory(bytes, fit: BoxFit.contain),
          Row(
            children: [
              TextButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.change_circle),
                  label: const Text('Rehacer')),
            ],
          )
        ],
      );
    }

    // Area para firmar
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Signature(
            controller: _controller,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
                onPressed: _clear,
                icon: const Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
                label: const Text('Limpiar')),
            const SizedBox(width: 8),
            ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(
                  Icons.save,
                  color: Colors.green,
                ),
                label: const Text('Guardar')),
          ],
        ),
      ],
    );
  }
}
