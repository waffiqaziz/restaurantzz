import 'package:flutter/material.dart';

TextTheme createTextTheme(BuildContext context) {
  // Define your custom text theme with the Nunito font
  TextTheme baseTextTheme = Theme.of(context).textTheme;

  return baseTextTheme.copyWith(
    displayLarge: baseTextTheme.displayLarge?.copyWith(fontFamily: 'Nunito'),
    displayMedium: baseTextTheme.displayMedium?.copyWith(fontFamily: 'Nunito'),
    displaySmall: baseTextTheme.displaySmall?.copyWith(fontFamily: 'Nunito'),
    headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontFamily: 'Nunito'),
    headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontFamily: 'Nunito'),
    headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontFamily: 'Nunito'),
    titleLarge: baseTextTheme.titleLarge?.copyWith(fontFamily: 'Nunito'),
    titleMedium: baseTextTheme.titleMedium?.copyWith(fontFamily: 'Nunito'),
    titleSmall: baseTextTheme.titleSmall?.copyWith(fontFamily: 'Nunito'),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontFamily: 'Nunito'),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontFamily: 'Nunito'),
    bodySmall: baseTextTheme.bodySmall?.copyWith(fontFamily: 'Nunito'),
    labelLarge: baseTextTheme.labelLarge?.copyWith(fontFamily: 'Nunito'),
    labelMedium: baseTextTheme.labelMedium?.copyWith(fontFamily: 'Nunito'),
    labelSmall: baseTextTheme.labelSmall?.copyWith(fontFamily: 'Nunito'),
  );
}
