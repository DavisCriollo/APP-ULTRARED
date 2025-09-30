import 'dart:async'; 
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

typedef SearchCallback<T> = Future<List<T>> Function({String search});

class SearchGenericResult<T> {
  final T? item;
  final bool? setBusqueda;
  final bool? wasLoading;
  SearchGenericResult({this.item, this.setBusqueda, this.wasLoading = false});
}

class GenericDelegate<T> extends SearchDelegate<SearchGenericResult<T>> {
  final SearchCallback<T> searchItems;
  final void Function(String search) setSearch;
  final Widget Function(T item, void Function(BuildContext, T) onItemSelected)
      itemWidgetBuilder;
  final int time;
  final bool onlySelect;
  final Widget? customWidget; // Nuevo parámetro opcional
  List<T> initialItems;
  StreamController<List<T>> debounceItems = StreamController.broadcast();
  StreamController<bool> loadingStream = StreamController.broadcast();
  Timer? _debounceTimer;

  GenericDelegate({
    required this.searchItems,
    required this.initialItems,
    required this.setSearch,
    required this.itemWidgetBuilder,
    this.time = 250,
    this.onlySelect = true,
    this.customWidget, // Inicializamos el nuevo parámetro
  }) : super(
          searchFieldLabel: 'Buscar',
          searchFieldStyle: const TextStyle(
            fontSize: 17.0,
          ),
        );

  // Resto del código...
  void clearStreams() {
    debounceItems.close();
    loadingStream.close();
  }

  void _onQueryChanged(String search) {
    Future.microtask(() => setSearch(search));
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    loadingStream.add(true);

    _debounceTimer = Timer(
      Duration(milliseconds: time),
      () async {
        if (search.isEmpty) {
          if (!debounceItems.isClosed) {
            // debounceItems.add([]);
          }
          if (!loadingStream.isClosed) {
            loadingStream.add(false);
          }
        }
        final items = await searchItems(search: search);
        initialItems = items;

        if (!debounceItems.isClosed) {
          debounceItems.add(items);
        }
        if (!loadingStream.isClosed) {
          loadingStream.add(false);
        }
      },
    );
  }

  StreamBuilder<List<T>> buildResultsAndSuggestions() {
    return StreamBuilder<List<T>>(
      initialData: initialItems,
      stream: debounceItems.stream,
      builder: (context, snapshotItems) {
        final items = snapshotItems.data ?? [];

        return StreamBuilder<bool>(
          initialData: false,
          stream: loadingStream.stream,
          builder: (context, snapshotLoading) {
            final isLoading = snapshotLoading.data ?? false;

            if (items.isEmpty) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // No hay resultados
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No hay registros',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => itemWidgetBuilder(
                items[index],
                (context, item) {
                  clearStreams();
                  close(context, SearchGenericResult(item: item));
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      StreamBuilder(
        stream: loadingStream.stream,
        builder: (context, snapshot) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              snapshot.data ?? false
                  ? SpinPerfect(
                      duration: const Duration(seconds: 1),
                      spins: 10,
                      infinite: true,
                      animate: query.isNotEmpty,
                      child: IconButton(
                        onPressed: () => query = '',
                        icon: const Icon(Icons.refresh),
                      ),
                    )
                  : FadeIn(
                      animate: query.isNotEmpty,
                      child: IconButton(
                        onPressed: () => query = '',
                        icon: const Icon(Icons.clear),
                      ),
                    ),
              if (customWidget != null)
                customWidget!, // Agregar el widget opcional
            ],
          );
        },
      ),
      StreamBuilder(
        stream: loadingStream.stream,
        builder: (context, snapshot) {
          return onlySelect
              ? const SizedBox()
              : IconButton(
                  onPressed: () {
                    if (!onlySelect) {
                      _debounceTimer?.cancel();
                      clearStreams();
                      close(
                        context,
                        SearchGenericResult(
                          setBusqueda: true,
                          wasLoading: snapshot.data ?? false,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                );
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        clearStreams();

        close(context, SearchGenericResult());
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    Future.microtask(() async {
      bool wasLoading = true;

      StreamSubscription<bool> subscription =
          loadingStream.stream.listen((bool isLoading) {
        wasLoading = isLoading;
      });

      await subscription.cancel();

      if (context.mounted) {
        if (!onlySelect) {
          clearStreams();
          _debounceTimer!.cancel();
          close(context,
              SearchGenericResult(setBusqueda: true, wasLoading: wasLoading));
        }
      }
    });

    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return buildResultsAndSuggestions();
  }
}
