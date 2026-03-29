import 'package:flutter/material.dart';

// ============================================================================
// 设计系统: "The Botanical Ledger"
// 植物学账本 — 以自然绿调为基底的沉稳设计语言
// ============================================================================

/// 不在 [ColorScheme] 中的额外颜色常量
class BotanicalColors {
  BotanicalColors._();

  static const primaryDim = Color(0xFF49564B);
  static const secondaryDim = Color(0xFF3F593F);
  static const tertiaryDim = Color(0xFF465747);
  static const errorDim = Color(0xFF791903);

  static const primaryFixed = Color(0xFFD7E6D8);
  static const primaryFixedDim = Color(0xFFC9D8CA);
  static const secondaryFixed = Color(0xFFCCEBC8);
  static const secondaryFixedDim = Color(0xFFBEDDBB);
  static const tertiaryFixed = Color(0xFFEBFFE8);
  static const tertiaryFixedDim = Color(0xFFDDF0DA);
}

/// 设计系统阴影
class AppShadows {
  AppShadows._();

  /// 编辑式卡片阴影 — 适用于内容卡片
  static final editorial = BoxShadow(
    color: const Color(0xFF2D3432).withValues(alpha: 0.06),
    blurRadius: 32,
    offset: const Offset(0, 10),
    spreadRadius: -4,
  );

  /// 自定义阴影 — 通用场景
  static final custom = BoxShadow(
    color: const Color(0xFF2D3432).withValues(alpha: 0.06),
    blurRadius: 32,
    offset: const Offset(0, 8),
  );

  /// 浮动元素阴影 — FAB、弹窗等
  static final floating = BoxShadow(
    color: const Color(0xFF2D3432).withValues(alpha: 0.08),
    blurRadius: 48,
    offset: const Offset(0, 16),
  );
}

/// 设计系统圆角
class AppRadius {
  AppRadius._();

  static const double sm = 8; // 0.5rem
  static const double md = 16; // 1rem（默认）
  static const double lg = 32; // 2rem
  static const double xl = 48; // 3rem
  static const double full = 9999; // 胶囊形
}

/// 设计系统间距
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// 应用主题
class AppTheme {
  AppTheme._();

  static const _plusJakartaSansFamily = 'PlusJakartaSans';
  static const _manropeFamily = 'Manrope';

  // --------------------------------------------------------------------------
  // 颜色方案（手动定义，不使用 fromSeed）
  // --------------------------------------------------------------------------
  static const _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF556257),
    onPrimary: Color(0xFFEEFDEE),
    primaryContainer: Color(0xFFD7E6D8),
    onPrimaryContainer: Color(0xFF47554A),
    secondary: Color(0xFF4B664B),
    onSecondary: Color(0xFFE9FFE5),
    secondaryContainer: Color(0xFFCCEBC8),
    onSecondaryContainer: Color(0xFF3E583E),
    tertiary: Color(0xFF526352),
    onTertiary: Color(0xFFEBFEE8),
    tertiaryContainer: Color(0xFFEBFFE8),
    onTertiaryContainer: Color(0xFF526352),
    error: Color(0xFFA73B21),
    onError: Color(0xFFFFF7F6),
    errorContainer: Color(0xFFFD795A),
    onErrorContainer: Color(0xFF6E1400),
    surface: Color(0xFFF8FAF8),
    onSurface: Color(0xFF2D3432),
    onSurfaceVariant: Color(0xFF59615F),
    outline: Color(0xFF757C7A),
    outlineVariant: Color(0xFFACB3B1),
    inverseSurface: Color(0xFF0B0F0E),
    onInverseSurface: Color(0xFF9B9D9C),
    inversePrimary: Color(0xFFEBFBEC),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F4F2),
    surfaceContainer: Color(0xFFEAEFEC),
    surfaceContainerHigh: Color(0xFFE4E9E7),
    surfaceContainerHighest: Color(0xFFDDE4E1),
    surfaceDim: Color(0xFFD4DCD9),
    surfaceBright: Color(0xFFF8FAF8),
    surfaceTint: Color(0xFF556257),
  );

  // --------------------------------------------------------------------------
  // 字体配置
  // --------------------------------------------------------------------------

  /// 标题字体 — Plus Jakarta Sans
  static TextStyle _plusJakarta({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: _plusJakartaSansFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// 正文字体 — Manrope
  static TextStyle _manrope({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: _manropeFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// 文字主题
  static TextTheme get _textTheme => TextTheme(
    // Display — Plus Jakarta Sans ExtraBold
    displayLarge: _plusJakarta(
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
    ),
    displayMedium: _plusJakarta(fontSize: 45, fontWeight: FontWeight.w800),
    displaySmall: _plusJakarta(fontSize: 36, fontWeight: FontWeight.w800),

    // Headline — Plus Jakarta Sans Bold
    headlineLarge: _plusJakarta(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: _plusJakarta(fontSize: 28, fontWeight: FontWeight.w700),
    headlineSmall: _plusJakarta(fontSize: 24, fontWeight: FontWeight.w700),

    // Title — Plus Jakarta Sans SemiBold
    titleLarge: _plusJakarta(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: _plusJakarta(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleSmall: _plusJakarta(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),

    // Body — Manrope Regular
    bodyLarge: _manrope(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: _manrope(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: _manrope(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),

    // Label — Manrope Medium / Bold
    labelLarge: _manrope(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
    labelMedium: _manrope(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: _manrope(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // --------------------------------------------------------------------------
  // 亮色主题
  // --------------------------------------------------------------------------
  static ThemeData get lightTheme {
    final cs = _colorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      textTheme: _textTheme,

      // ---- AppBar ----
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _plusJakarta(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),

      // ---- Card ----
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: EdgeInsets.zero,
      ),

      // ---- ElevatedButton（胶囊形，主色背景） ----
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: _manrope(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ---- OutlinedButton（胶囊形，描边） ----
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(color: cs.outline),
          shape: const StadiumBorder(),
          textStyle: _manrope(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ---- TextButton（胶囊形） ----
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          shape: const StadiumBorder(),
          textStyle: _manrope(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ---- 输入框 ----
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: _manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: cs.onSurfaceVariant,
        ),
      ),

      // ---- NavigationBar ----
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cs.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.onPrimaryContainer, size: 24);
          }
          return IconThemeData(color: cs.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            );
          }
          return _manrope(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: cs.onSurfaceVariant,
          );
        }),
      ),

      // ---- FAB（胶囊形，主色） ----
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        highlightElevation: 0,
        shape: const StadiumBorder(),
      ),

      // ---- Dialog ----
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg - 8), // 24
        ),
        titleTextStyle: _plusJakarta(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        contentTextStyle: _manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: cs.onSurfaceVariant,
        ),
      ),

      // ---- BottomSheet ----
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.lg),
            topRight: Radius.circular(AppRadius.lg),
          ),
        ),
      ),

      // ---- Divider ----
      dividerTheme: DividerThemeData(
        color: cs.surfaceContainer,
        space: 1,
        thickness: 1,
      ),

      // ---- Switch ----
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.primary;
          }
          return cs.surfaceContainerHighest;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cs.onPrimary;
          }
          return cs.outline;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return cs.outline;
        }),
      ),

      // ---- Scaffold ----
      scaffoldBackgroundColor: cs.surface,
    );
  }
}
