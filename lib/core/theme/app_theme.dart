import 'package:flutter/material.dart';

/// Material 3 from a single seed colour.
///
/// One seed and not a hand-picked palette: it derives a set that already meets
/// contrast in both brightnesses, which hand-picking rarely does.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF1B5E9B);

  static ThemeData get light => _from(Brightness.light);
  static ThemeData get dark => _from(Brightness.dark);

  static ThemeData _from(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
        ),
      ),
    );
  }
}
