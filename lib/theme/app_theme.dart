import 'package:flutter/material.dart';

/// لوحة الألوان — مطابقة تمامًا لنسخة الويب (converter_vio.html)
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF000000);
  static const Color brandOrange = Color(0xFFFF9800);
  static const Color brandOrangeLight = Color(0xFFFFB74D);
  static const Color brandOrangeDark = Color(0xFFE68A00);
  static const Color white = Color(0xFFFFFFFF);
  static const Color rowGrey = Color(0xFF353535);
  static const Color secondaryGrey = Color(0xFF9E9E9E);
  static const Color cardDark1 = Color(0xFF1A1A1A);
  static const Color cardDark2 = Color(0xFF181818);
  static const Color cardDark3 = Color(0xFF161616);
  static const Color success = Color(0xFF4CAF50);
  static const Color activeRowBrown = Color(0xFF4A3A23);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Tajawal',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandOrange,
        surface: AppColors.background,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.white, fontFamily: 'Tajawal'),
      ),
      useMaterial3: true,
    );
  }

  static const double pillRadius = 999;
  static const double appMaxWidth = 450;
}
