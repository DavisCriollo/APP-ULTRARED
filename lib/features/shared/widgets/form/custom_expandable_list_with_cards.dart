import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/widgets/form/custom_badge.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expansion_tile.dart';

class CustomExpandableListWithCards extends StatelessWidget {
  final String label;
  final String? errorMessage;
  final List values;
  final void Function() onTap;
  final List<Widget> children;
  const CustomExpandableListWithCards({
    super.key,
    required this.label,
    this.errorMessage,
    required this.values,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return CustomExpansionTile(
      errorMessage: errorMessage,
      label: label,
      values: [],
      suffixIcon: CustomBadge(
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
                children: children,
              )
            ],
          ),
        ),
      ],
    );
  }
}
