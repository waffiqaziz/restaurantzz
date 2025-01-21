import 'package:flutter/material.dart';

class RestaurantzzTheme {
  final TextTheme textTheme;

  const RestaurantzzTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff335a0c),
      surfaceTint: Color(0xff41691b),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff568030),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff526440),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffd6ebbe),
      onSecondaryContainer: Color(0xff3d4e2d),
      tertiary: Color(0xff005b47),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff008468),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfff9faef),
      onSurface: Color(0xff1a1c16),
      onSurfaceVariant: Color(0xff43493b),
      outline: Color(0xff73796a),
      outlineVariant: Color(0xffc3c9b7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f312a),
      inversePrimary: Color(0xffa6d479),
      primaryFixed: Color(0xffc1f193),
      onPrimaryFixed: Color(0xff0d2000),
      primaryFixedDim: Color(0xffa6d479),
      onPrimaryFixedVariant: Color(0xff2a5001),
      secondaryFixed: Color(0xffd5e9bc),
      onSecondaryFixed: Color(0xff111f04),
      secondaryFixedDim: Color(0xffb9cda2),
      onSecondaryFixedVariant: Color(0xff3b4c2b),
      tertiaryFixed: Color(0xff8bf6d3),
      onTertiaryFixed: Color(0xff002117),
      tertiaryFixedDim: Color(0xff6edab7),
      onTertiaryFixedVariant: Color(0xff00513e),
      surfaceDim: Color(0xffd9dbd1),
      surfaceBright: Color(0xfff9faef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3f4ea),
      surfaceContainer: Color(0xffedefe4),
      surfaceContainerHigh: Color(0xffe8e9de),
      surfaceContainerHighest: Color(0xffe2e3d9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa6d479),
      surfaceTint: Color(0xffa6d479),
      onPrimary: Color(0xff1b3700),
      primaryContainer: Color(0xff547d2d),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xffb9cda2),
      onSecondary: Color(0xff253516),
      secondaryContainer: Color(0xff334423),
      onSecondaryContainer: Color(0xffc6daae),
      tertiary: Color(0xff6edab7),
      onTertiary: Color(0xff00382a),
      tertiaryContainer: Color(0xff008165),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff12140e),
      onSurface: Color(0xffe2e3d9),
      onSurfaceVariant: Color(0xffc3c9b7),
      outline: Color(0xff8d9383),
      outlineVariant: Color(0xff43493b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe2e3d9),
      inversePrimary: Color(0xff41691b),
      primaryFixed: Color(0xffc1f193),
      onPrimaryFixed: Color(0xff0d2000),
      primaryFixedDim: Color(0xffa6d479),
      onPrimaryFixedVariant: Color(0xff2a5001),
      secondaryFixed: Color(0xffd5e9bc),
      onSecondaryFixed: Color(0xff111f04),
      secondaryFixedDim: Color(0xffb9cda2),
      onSecondaryFixedVariant: Color(0xff3b4c2b),
      tertiaryFixed: Color(0xff8bf6d3),
      onTertiaryFixed: Color(0xff002117),
      tertiaryFixedDim: Color(0xff6edab7),
      onTertiaryFixedVariant: Color(0xff00513e),
      surfaceDim: Color(0xff12140e),
      surfaceBright: Color(0xff373a33),
      surfaceContainerLowest: Color(0xff0c0f09),
      surfaceContainerLow: Color(0xff1a1c16),
      surfaceContainer: Color(0xff1e201a),
      surfaceContainerHigh: Color(0xff282b24),
      surfaceContainerHighest: Color(0xff33362f),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );
}
