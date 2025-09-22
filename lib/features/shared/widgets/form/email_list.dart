import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class EmailList extends StatelessWidget {
  final List<String> emails;
  final void Function(String email) eliminarEmail;
  const EmailList(
      {super.key, required this.emails, required this.eliminarEmail});

  @override
  Widget build(BuildContext context) {
    final size = Responsive.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      children: emails.map((e) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.all(size.iScreen(0.2)),
          padding: EdgeInsets.symmetric(
            vertical: size.iScreen(0.1),
            horizontal: size.iScreen(0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e,
                style: TextStyle(
                  fontSize: size.iScreen(1.4),
                  fontWeight: FontWeight.normal,
                ),
              ),
              IconButton(
                onPressed: () {
                  eliminarEmail(e);
                },
                icon: const Icon(
                  Icons.close_rounded,
                ),
                color: Colors.red,
                iconSize: size.iScreen(1.5),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
