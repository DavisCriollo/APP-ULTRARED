import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/cuentas_por_cobrar/domain/repositores/cuentas_por_cobrar_repository.dart';

final cuentasPorCobrarRepositoryProvider = Provider<CuentasPorCobrarRepository>((ref) {
  final dio = ref.watch(authProvider.notifier).dio;
  return CuentasPorCobrarRepository(dio: dio);
});
