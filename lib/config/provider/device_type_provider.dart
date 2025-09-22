import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceType { mobile, tablet, monitor }

final deviceTypeProvider = Provider<DeviceType>((ref) {
  final context = ref.watch(contextProvider);
  if (context == null) {
    return DeviceType.tablet;
  }
  final width = MediaQuery.of(context).size.width;

  if (width < 600) {
    return DeviceType.mobile;
  } else if (width < 1200) {
    return DeviceType.tablet;
  } else {
    return DeviceType.monitor;
  }
});

final contextProvider = StateProvider<BuildContext?>((ref) => null);
