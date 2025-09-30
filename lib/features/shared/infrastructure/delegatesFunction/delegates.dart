import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/delegate/generic_delegate.dart';
import 'package:ultrared/features/shared/delegate/item_generic_search.dart';

String normalize(String? s) => (s ?? '').trim().toLowerCase();

Future<T?> setITemGenericDelegate<T>({
  required BuildContext context,
  required List<T> initialItems,
  required String Function(T item) titleBuilder,
  required int time,
}) async {
  final res = await showSearch<SearchGenericResult<T>>(
    context: context,
    query: '',
    delegate: GenericDelegate<T>(
      time: time,
      itemWidgetBuilder: (item, onItemSelected) {
        return ItemGenericSearch(
          item: item,
          onItemSelected: onItemSelected,
          title: titleBuilder(item),
        );
      },
      setSearch: (search) {},
      initialItems: initialItems,
      searchItems: ({search = ''}) async {
        final q = normalize(search);
        if (q.isEmpty) return initialItems;
        return initialItems
            .where((element) => normalize(titleBuilder(element)).contains(q))
            .toList();
      },
    ),
  );
  return res?.item;
}
