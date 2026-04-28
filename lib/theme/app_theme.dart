import 'package:flutter/material.dart';

/// アプリ全体のブランドカラーとグラデーション。
class AppColors {
  AppColors._();

  // ベース：くすみ系のローズ＋ラベンダー
  static const Color primary = Color(0xFFE91E8C); // 推し色っぽい鮮やかピンク
  static const Color primaryDark = Color(0xFFB81472);
  static const Color secondary = Color(0xFF8E63FF); // ラベンダー
  static const Color tertiary = Color(0xFFFFB347); // アクセント黄
  static const Color background = Color(0xFFFDF7FB); // ほんのりピンクの背景
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF4EEF6);
  static const Color outline = Color(0xFFE3D6E5);

  // ステータスカラー
  static const Color statusDeadline = Color(0xFFEF4D6F); // 締切間近
  static const Color statusReservation = Color(0xFF3B82F6); // 予約受付中
  static const Color statusActive = Color(0xFF22C55E); // 開催中
  static const Color statusUpcoming = Color(0xFF8E63FF); // 近日開始
  static const Color statusBefore = Color(0xFF94A3B8); // 予約受付前
  static const Color statusEnded = Color(0xFFB7B5BD); // 終了
}

class AppGradients {
  AppGradients._();

  /// ヘッダー等で使うピンク→紫の推し活グラデ
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF7AB6), Color(0xFFB67CFF)],
  );

  static const LinearGradient deadline = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6F8E), Color(0xFFFF8AA1)],
  );

  static const LinearGradient active = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF38D196), Color(0xFF2BC0E4)],
  );

  static const LinearGradient reservation = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6DA9FF), Color(0xFF7C84FF)],
  );

  static const LinearGradient upcoming = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB67CFF), Color(0xFFE08CFF)],
  );

  /// 各カードのカテゴリ画像エリア用に、カテゴリごとに使い分ける淡いグラデ
  static const List<List<Color>> categoryPalette = [
    [Color(0xFFFFD2E1), Color(0xFFFFE9C7)],
    [Color(0xFFE7DFFF), Color(0xFFD7EBFF)],
    [Color(0xFFD8F5E5), Color(0xFFCDEBFF)],
    [Color(0xFFFEE6CB), Color(0xFFFFD2D2)],
    [Color(0xFFE2DBFF), Color(0xFFFCE0EF)],
    [Color(0xFFCEEFFA), Color(0xFFE6D6FF)],
  ];
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    surface: AppColors.surface,
  );

  const baseFamily = 'NotoSans';

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: null, // システムデフォルト（日本語フォント）に任せる
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontFamily: baseFamily,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.25,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      bodyLarge: TextStyle(fontSize: 14, height: 1.45),
      bodyMedium: TextStyle(fontSize: 13, height: 1.45),
      bodySmall: TextStyle(fontSize: 12, height: 1.4),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Color(0xFF2A1F33),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF2A1F33),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.outline, width: 0.6),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceMuted,
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      side: BorderSide.none,
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 0.6,
      space: 0.6,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      hintStyle: const TextStyle(color: Color(0xFF9C8FA3), fontSize: 13),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.outline),
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      indicatorColor: AppColors.primary.withValues(alpha: 0.14),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : const Color(0xFF6B5C72),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.primary : const Color(0xFF6B5C72),
          size: 24,
        );
      }),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}
