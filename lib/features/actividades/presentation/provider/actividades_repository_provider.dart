import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/actividades/domain/repositores/cuentas_por_cobrar_repository.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';

final actividadesRepositoryProvider = Provider<ActividadesRepository>((ref) {
  final dio = ref.watch(authProvider.notifier).dio;
  final user = ref.watch(authProvider).user;
  return ActividadesRepository(dio: dio, usuario: user!);
});
