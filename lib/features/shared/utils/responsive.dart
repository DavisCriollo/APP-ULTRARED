import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tipo de dispositivo según el lado corto de la pantalla (convención Material).
enum ScreenType {
  /// < 360 dp (teléfonos pequeños)
  compactPhone,

  /// 360–599 dp (teléfonos estándar)
  phone,

  /// 600–899 dp (tablets pequeñas / phablets en horizontal si se permitiera)
  tablet,

  /// >= 900 dp (tablets grandes)
  largeTablet,
}

/// Utilidad de layout responsivo (evolución de SINCOP Seguridad).
///
/// - Porcentajes: [wScreen], [hScreen], [iScreen] (API original).
/// - Breakpoints para teléfono / tablet.
/// - Escala respecto a un diseño base (390×844) con límites min/max.
/// - Anchura máxima de contenido en tablet para formularios legibles.
class Responsive {
  /// Diseño de referencia (iPhone 14 / similar).
  static const Size designSize = Size(390, 844);

  static const double _tabletBreakpoint = 600;
  static const double _largeTabletBreakpoint = 900;
  static const double _compactPhoneBreakpoint = 360;

  final double width;
  final double height;
  final double inch;
  final double textScale;
  final EdgeInsets viewPadding;
  final Orientation orientation;

  Responsive({
    required this.width,
    required this.height,
    required this.inch,
    this.textScale = 1,
    this.viewPadding = EdgeInsets.zero,
    this.orientation = Orientation.portrait,
  });

  factory Responsive.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Responsive.fromSize(
      mq.size,
      textScale: mq.textScaler.scale(1),
      viewPadding: mq.viewPadding,
      orientation: mq.orientation,
    );
  }

  factory Responsive.fromView() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    return Responsive.fromSize(logicalSize);
  }

  factory Responsive.fromSize(
    Size size, {
    double textScale = 1,
    EdgeInsets viewPadding = EdgeInsets.zero,
    Orientation orientation = Orientation.portrait,
  }) {
    final diagonal = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );
    return Responsive(
      width: size.width,
      height: size.height,
      inch: diagonal,
      textScale: textScale,
      viewPadding: viewPadding,
      orientation: orientation,
    );
  }

  // --- Métricas de dispositivo ---

  double get shortestSide => math.min(width, height);

  double get longestSide => math.max(width, height);

  ScreenType get screenType {
    final s = shortestSide;
    if (s < _compactPhoneBreakpoint) return ScreenType.compactPhone;
    if (s < _tabletBreakpoint) return ScreenType.phone;
    if (s < _largeTabletBreakpoint) return ScreenType.tablet;
    return ScreenType.largeTablet;
  }

  bool get isPhone =>
      screenType == ScreenType.compactPhone || screenType == ScreenType.phone;

  bool get isTablet =>
      screenType == ScreenType.tablet || screenType == ScreenType.largeTablet;

  /// Escala horizontal respecto al diseño base (con tope para no desbordar).
  double get scaleWidth => (width / designSize.width).clamp(0.82, 1.35);

  /// Escala vertical respecto al diseño base.
  double get scaleHeight => (height / designSize.height).clamp(0.82, 1.25);

  /// Escala equilibrada (la más estable entre dispositivos).
  double get scale => math.min(scaleWidth, scaleHeight);

  /// Ancho útil descontando notch / barras del sistema.
  double get usableWidth => width - viewPadding.horizontal;

  double get usableHeight => height - viewPadding.vertical;

  /// Ancho máximo recomendado para formularios / cards en tablet.
  double get maxContentWidth {
    if (!isTablet) return usableWidth;
    return math.min(usableWidth * 0.72, wScreen(68));
  }

  /// Ancho de lectura cómodo para listas y formularios en tablet.
  double get readableContentWidth =>
      isTablet ? math.min(usableWidth * 0.82, 780) : usableWidth;

  /// Margen lateral que centra el contenido en tablet.
  ///
  /// Vale 0 en teléfono, así que sumarlo al padding horizontal de una pantalla
  /// no altera en absoluto el layout móvil.
  double get sideInset {
    if (!isTablet) return 0;
    return math.max(0, (usableWidth - readableContentWidth) / 2);
  }

  // --- Factores internos por tipo de pantalla ---

  double get _widthFactor => switch (screenType) {
        ScreenType.compactPhone => 1.02,
        ScreenType.phone => 1.0,
        ScreenType.tablet => 0.88,
        ScreenType.largeTablet => 0.82,
      };

  double get _heightFactor => switch (screenType) {
        ScreenType.compactPhone => 1.0,
        ScreenType.phone => 1.0,
        ScreenType.tablet => 1.0,
        ScreenType.largeTablet => 1.02,
      };

  /// La diagonal de una tablet casi duplica la de un teléfono, así que sin
  /// compensar, tipografía e íconos crecerían ~80% y desbordarían los layouts.
  /// Estos factores devuelven la tablet a una escala visual de teléfono
  /// conservando la jerarquía relativa. Los valores de teléfono no cambian.
  double get _diagonalFactor => switch (screenType) {
        ScreenType.compactPhone => 0.98,
        ScreenType.phone => 1.0,
        ScreenType.tablet => 0.78,
        ScreenType.largeTablet => 0.66,
      };

  // --- API original (porcentaje) con clamp y ajuste tablet ---

  /// Porcentaje del ancho de pantalla (ajustado y acotado).
  double wScreen(double percent) => _clampW(width * percent / 100 * _widthFactor);

  /// Porcentaje del alto de pantalla (ajustado y acotado).
  double hScreen(double percent) => _clampH(height * percent / 100 * _heightFactor);

  /// Porcentaje de la diagonal (íconos, radios, sombras).
  ///
  /// No usar para [letterSpacing]: el mínimo de 8 px estira las letras.
  double iScreen(double percent) =>
      _clampI(inch * percent / 100 * _diagonalFactor);

  /// Tamaño de texto (% de diagonal), acotado para móvil/tablet.
  double textSize(double diagonalPercent) =>
      _clampFont(inch * diagonalPercent / 100 * _diagonalFactor);

  // --- API basada en diseño de referencia (píxeles del mockup) ---

  /// Convierte píxeles de ancho del diseño base al dispositivo actual.
  double w(double designPixels) => _clampW(designPixels * scaleWidth);

  /// Convierte píxeles de alto del diseño base al dispositivo actual.
  double h(double designPixels) => _clampH(designPixels * scaleHeight);

  /// Tamaño escalado (fuentes, íconos) respetando accesibilidad del sistema.
  double sp(double designPixels) =>
      _clampFont(designPixels * scale * textScale);

  // --- Alias semánticos ---

  /// Alias de [textSize] (tipografía). No confundir con [iScreen].
  double font(double diagonalPercent) => textSize(diagonalPercent);

  double icon(double diagonalPercent) => iScreen(diagonalPercent);

  double radius(double widthPercent) => wScreen(widthPercent);

  // --- Espaciados semánticos (porcentaje de alto) ---

  double get gapXs => hScreen(0.5);
  double get gapSm => hScreen(0.8);
  double get gapMd => hScreen(1.2);
  double get gapLg => hScreen(2);
  double get gapXl => hScreen(3);

  // --- Helpers de padding / margin ---

  EdgeInsets paddingSymmetric({
    required double horizontalPercent,
    required double verticalPercent,
  }) =>
      EdgeInsets.symmetric(
        horizontal: wScreen(horizontalPercent),
        vertical: hScreen(verticalPercent),
      );

  EdgeInsets marginLtrb({
    required double leftPercent,
    required double topPercent,
    required double rightPercent,
    required double bottomPercent,
  }) =>
      EdgeInsets.fromLTRB(
        wScreen(leftPercent),
        hScreen(topPercent),
        wScreen(rightPercent),
        hScreen(bottomPercent),
      );

  /// Padding horizontal estándar de pantalla.
  EdgeInsets get screenPaddingHorizontal =>
      EdgeInsets.symmetric(horizontal: wScreen(isTablet ? 8 : 6));

  // --- Clamps por categoría ---

  double _clampW(double value) {
    final (min, max) = switch (screenType) {
      ScreenType.compactPhone => (0.0, width),
      ScreenType.phone => (0.0, width),
      ScreenType.tablet => (0.0, width),
      ScreenType.largeTablet => (0.0, width),
    };
    return value.clamp(min, max);
  }

  double _clampH(double value) {
    return value.clamp(0, height);
  }

  double _clampI(double value) {
    final max = switch (screenType) {
      ScreenType.compactPhone => inch * 0.12,
      ScreenType.phone => inch * 0.14,
      ScreenType.tablet => inch * 0.11,
      ScreenType.largeTablet => inch * 0.10,
    };
    return value.clamp(8, max);
  }

  double _clampFont(double value) {
    final (min, max) = switch (screenType) {
      ScreenType.compactPhone => (10.0, 26.0),
      ScreenType.phone => (11.0, 28.0),
      ScreenType.tablet => (12.0, 32.0),
      ScreenType.largeTablet => (13.0, 36.0),
    };
    return value.clamp(min, max);
  }
}
