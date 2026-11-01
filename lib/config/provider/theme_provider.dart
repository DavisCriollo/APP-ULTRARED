import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/config/config.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/infrastructure/services/key_value_storage_impl.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  final user = ref.watch(authProvider).user;
  final empresaPrimario = user?.colorSecundario;
  final empresaSecundario = user?.colorPrimario;
  final colorPrimario = (empresaPrimario == null || empresaPrimario.isEmpty)
      ? AppTheme.baseColorPrimario // Color base si no llega del login
      : empresaPrimario;
  final colorSecundario = (empresaSecundario == null || empresaSecundario.isEmpty)
      ? AppTheme.baseColorSecundario // Color base si no llega del login
      : empresaSecundario;
  const isDarkMode = false;
  final KeyValueStorageImpl storage = KeyValueStorageImpl();
  return ThemeNotifier(
    colorPrimario: colorPrimario,
    colorSecundario: colorSecundario,
    isDarkMode: isDarkMode,
    storage: storage,
  );
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  final KeyValueStorageImpl storage;
  static const String darkModeKey = 'isDarkMode';

  ThemeNotifier({
    required String colorPrimario,
    required String colorSecundario,
    required bool isDarkMode,
    required this.storage,
  }) : super(AppTheme(
          primary: colorPrimario,
          secondary: colorSecundario,
          isDarkMode: isDarkMode,
        ));

  void updateTheme(String primary, String secondary, bool isDarkMode) async {
    state = state.copyWith(
        primary: primary, secondary: secondary, isDarkMode: isDarkMode);
    await storage.setKeyValue<bool>(darkModeKey, isDarkMode);
  }

  void toggleDarkMode() async {
    final newMode = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newMode);
    await storage.setKeyValue<String>(darkModeKey, newMode ? 'dark' : 'light');
  }

  static Future<bool> loadPersistedDarkMode(KeyValueStorageImpl storage) async {
    return await storage.getValue<String>(darkModeKey) == 'dark';
  }
}
