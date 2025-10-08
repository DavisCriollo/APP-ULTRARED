import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart'; 
import 'package:ultrared/features/shared/domain/repositores/upload_files_repository.dart';

final uploadDeleteFilesProvider = Provider<UploadFilesRepository>((ref) {
  final dio = ref.watch(authProvider.notifier).dio;
  return UploadFilesRepository(
    dio: dio,
  );
});
