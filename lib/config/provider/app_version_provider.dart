import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Versión visible de la app. Sale de `version` en pubspec.yaml
/// (el número antes del +).
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

class AppVersionText extends ConsumerWidget {
  final String prefix;
  final TextStyle? style;

  const AppVersionText({
    super.key,
    required this.prefix,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider);
    final text = version.maybeWhen(
      data: (value) => '$prefix$value',
      orElse: () => prefix,
    );
    return Text(text, style: style);
  }
}
