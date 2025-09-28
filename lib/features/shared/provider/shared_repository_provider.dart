import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/domain/repositores/shared_repository.dart';

final sharedRepositoryProvider = Provider<SharedRepository>((ref) {
  final dio = ref.watch(authProvider.notifier).dio;
  return SharedRepository(
    dio: dio,
  );
});
