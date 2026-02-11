import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/pppoe/domain/repositores/conexiones_repository.dart';

final conexionesRepositoryProvider = Provider<ConexionesRepository>((ref) {
  final dio = ref.watch(authProvider.notifier).dio;
  final user = ref.watch(authProvider).user;
  return ConexionesRepository(dio: dio, usuario: user!);
});
