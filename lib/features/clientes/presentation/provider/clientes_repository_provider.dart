import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/clientes/domain/repositores/clientes_repository.dart';

final clientesRepositoryProvider = Provider<ClientesRepository>((ref) {
  final dio = ref.watch(authProvider.notifier).dio;
  return ClientesRepository(
    dio: dio,
  );
});
