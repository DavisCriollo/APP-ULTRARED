import 'package:flutter/material.dart';

class ItemGenericSearch<T> extends StatelessWidget {
  final T item;
  final String title;
  final void Function(BuildContext context, T item) onItemSelected;

  const ItemGenericSearch(
      {super.key,
      required this.item,
      required this.onItemSelected,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title), // Customize this as needed
          onTap: () => onItemSelected(context, item),
        ),
        const Divider()
      ],
    );
  }
}
