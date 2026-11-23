import 'package:flutter/material.dart';

/// وحدة التحكم المركزية بنمط وثيم التطبيق (فاتح / داكن)
class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);
}

/// فئة الألوان الموحدة للتطبيق مطابقة تماماً للمنظومة اللونية المعتمدة لتطبيق القهوة
class AppColors {
  // =========================================================================
  // ألوان تطبيق القهوة (المعتمدة بالصورة المرفقة)
  // =========================================================================

  // ── الوضع النهاري (Light Mode) ──────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFFFFFF);     // خلفية رئيسية #FFFFFF
  static const Color lightSecondaryBg = Color(0xFFF8F6F1);    // خلفية ثانوية #F8F6F1
  static const Color lightPrimary = Color(0xFF5D4037);        // لون أساسي #5D4037
  static const Color lightSecondary = Color(0xFF8B6B5A);      // لون ثانوي #8B6B5A
  static const Color lightAccent = Color(0xFFD7B899);         // لون Accent #D7B899

  // ── الوضع الليلي (Dark Mode) ────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);      // خلفية رئيسية #121212
  static const Color darkSecondaryBg = Color(0xFF1E1E1E);     // خلفية ثانوية #1E1E1E
  static const Color darkPrimary = Color(0xFFD4A373);         // لون أساسي #D4A373
  static const Color darkSecondary = Color(0xFFA67C52);       // لون ثانوي #A67C52
  static const Color darkAccent = Color(0xFFF5D7B1);          // لون Accent #F5D7B1

  // تعيينات للتوافق الخلفي عبر الشاشات
  static const Color primary = lightPrimary;
  static const Color primaryContainer = lightPrimary;
  static const Color primaryFixed = lightAccent;
  static const Color primaryFixedDim = lightSecondary;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = lightSecondaryBg;

  static const Color secondary = lightSecondary;
  static const Color secondaryContainer = lightAccent;
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = lightPrimary;
  static const Color secondaryFixed = lightAccent;
  static const Color secondaryFixedDim = lightSecondary;

  static const Color tertiary = Color(0xFF226B42);
  static const Color tertiaryContainer = Color(0xFFE8F5E9);
  static const Color tertiaryFixed = Color(0xFFA9F3BF);
  static const Color tertiaryFixedDim = Color(0xFF81C784);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF1B5E20);

  static const Color success = Color(0xFF226B42);
  static const Color successFixed = Color(0xFFA9F3BF);

  // Surfaces & Backgrounds - Light
  static const Color background = lightBackground;
  static const Color surface = lightBackground;
  static const Color surfaceBright = lightBackground;
  static const Color surfaceDim = lightSecondaryBg;
  static const Color surfaceContainerLowest = lightBackground;
  static const Color surfaceContainerLow = lightSecondaryBg;
  static const Color surfaceContainer = Color(0xFFF3EEE6);
  static const Color surfaceContainerHigh = Color(0xFFEBE6DC);
  static const Color surfaceContainerHighest = Color(0xFFE2DDD1);

  // Text & Icons - Light
  static const Color onSurface = Color(0xFF3E2723);
  static const Color onSurfaceVariant = Color(0xFF8B6B5A);
  static const Color outline = Color(0xFF8B6B5A);
  static const Color outlineVariant = Color(0xFFD7B899);

  // Surfaces & Backgrounds - Dark
  static const Color backgroundDark = darkBackground;
  static const Color surfaceDark = darkBackground;
  static const Color cardDark = darkSecondaryBg;
  static const Color surfaceContainerDark = darkSecondaryBg;
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onSurfaceVariantDark = darkAccent;

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);
}

/// سمة التطبيق الشاملة تدعم النمطين الفاتح والداكن وخط IBM Plex Sans Arabic الموحد
class AppTheme {
  // الخط الرسمي الموحد لجميع شاشات التطبيق — مدمج في أصول التطبيق ويعمل أوفلاين وأونلاين
  static const String fontIBM = 'IBM Plex Sans Arabic';

  /// TextStyle جاهز بخط IBM Plex Sans Arabic المدمج محلياً
  static TextStyle ibmPlexStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontIBM,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// اسم عائلة الخط
  static String get ibmFontFamily => fontIBM;

  // Alias for backward compatibility across all widgets
  static const Color primary = AppColors.primary;
  static const Color primaryContainer = AppColors.primaryContainer;
  static const Color primaryFixed = AppColors.primaryFixed;
  static const Color primaryFixedDim = AppColors.primaryFixedDim;
  static const Color onPrimary = AppColors.onPrimary;
  static const Color onPrimaryContainer = AppColors.onPrimaryContainer;

  static const Color secondary = AppColors.secondary;
  static const Color secondaryContainer = AppColors.secondaryContainer;
  static const Color onSecondary = AppColors.onSecondary;
  static const Color onSecondaryContainer = AppColors.onSecondaryContainer;
  static const Color secondaryFixed = AppColors.secondaryFixed;
  static const Color secondaryFixedDim = AppColors.secondaryFixedDim;

  static const Color tertiary = AppColors.tertiary;
  static const Color tertiaryContainer = AppColors.tertiaryContainer;
  static const Color tertiaryFixed = AppColors.tertiaryFixed;
  static const Color tertiaryFixedDim = AppColors.tertiaryFixedDim;
  static const Color onTertiary = AppColors.onTertiary;
  static const Color onTertiaryContainer = AppColors.onTertiaryContainer;

  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color surfaceContainerLowest = AppColors.surfaceContainerLowest;
  static const Color surfaceContainerLow = AppColors.surfaceContainerLow;
  static const Color surfaceContainer = AppColors.surfaceContainer;
  static const Color surfaceContainerHigh = AppColors.surfaceContainerHigh;
  static const Color surfaceContainerHighest = AppColors.surfaceContainerHighest;

  static const Color onSurface = AppColors.onSurface;
  static const Color onSurfaceVariant = AppColors.onSurfaceVariant;

  static const Color outline = AppColors.outline;
  static const Color outlineVariant = AppColors.outlineVariant;

  static const Color error = AppColors.error;
  static const Color errorContainer = AppColors.errorContainer;

  // =========================================================================
  // مساعدات الألوان الديناميكية الحية (تتكيف فورياً مع الوضعين الفاتح والداكن)
  // وفق منظومة الألوان المقترحة لتطبيق القهوة:
  // نهاري: رئيسية #FFFFFF | ثانوية #F8F6F1 | أساسي #5D4037 | ثانوي #8B6B5A | Accent #D7B899
  // ليلي:  رئيسية #121212 | ثانوية #1E1E1E | أساسي #D4A373 | ثانوي #A67C52 | Accent #F5D7B1
  // =========================================================================

  /// هل التطبيق حالياً في الوضع الليلي الداكن؟
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// لون خلفية الشاشة الكاملة (نهاري: #FFFFFF | ليلي: #121212)
  static Color scaffoldBg(BuildContext context) {
    return isDark(context) ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  }

  /// لون بطاقات المنتجات والأقسام (نهاري: #F8F6F1 | ليلي: #1E1E1E)
  static Color cardBg(BuildContext context) {
    return isDark(context) ? const Color(0xFF1E1E1E) : const Color(0xFFF8F6F1);
  }

  /// لون حدود البطاقات الخفيفة
  static Color cardBorder(BuildContext context) {
    return isDark(context) ? const Color(0xFF2C2C2C) : const Color(0xFFEBE6DC);
  }

  /// لون السطح الخفيف للبطاقات الداخلية والمربعات
  static Color surfaceLow(BuildContext context) {
    return isDark(context) ? const Color(0xFF262626) : const Color(0xFFF1EDE6);
  }

  /// لون السطح الأكثر انخفاضاً
  static Color surfaceLowest(BuildContext context) {
    return isDark(context) ? const Color(0xFF181818) : const Color(0xFFFFFFFF);
  }

  /// العناوين الكبرى الرئيسية (نهاري: #5D4037 | ليلي: #F5D7B1)
  static Color textHeading(BuildContext context) {
    return isDark(context) ? const Color(0xFFF5D7B1) : const Color(0xFF5D4037);
  }

  /// النصوص الأساسية (نهاري: #3E2723 | ليلي: #FFFFFF)
  static Color textPrimary(BuildContext context) {
    return isDark(context) ? const Color(0xFFFFFFFF) : const Color(0xFF3E2723);
  }

  /// النصوص الفرعية والتوضيحية (نهاري: #8B6B5A | ليلي: #A67C52)
  static Color textSecondary(BuildContext context) {
    return isDark(context) ? const Color(0xFFA67C52) : const Color(0xFF8B6B5A);
  }

  /// اللون البارز والأساسي (نهاري: #5D4037 | ليلي: #D4A373)
  static Color accent(BuildContext context) {
    return isDark(context) ? const Color(0xFFD4A373) : const Color(0xFF5D4037);
  }

  /// لون Accent الفرعي الدافئ (نهاري: #D7B899 | ليلي: #F5D7B1)
  static Color accentSecondary(BuildContext context) {
    return isDark(context) ? const Color(0xFFF5D7B1) : const Color(0xFFD7B899);
  }

  /// الذهبي الكراميلي لمحاصيل البن
  static Color goldAccent(BuildContext context) {
    return const Color(0xFFD4A373);
  }

  /// خلفية أزرار التصنيفات والرقائق غير المختارة (نهاري: #F8F6F1 | ليلي: #1E1E1E)
  static Color chipBg(BuildContext context) {
    return isDark(context) ? const Color(0xFF1E1E1E) : const Color(0xFFF8F6F1);
  }

  /// حدود أزرار التصنيفات غير المختارة
  static Color chipBorder(BuildContext context) {
    return isDark(context) ? const Color(0xFF2E2E2E) : const Color(0xFFEBE6DC);
  }

  /// لون الزر/التصنيف المختار (نهاري: #5D4037 | ليلي: #D4A373)
  static Color chipSelectedBg(BuildContext context) {
    return isDark(context) ? const Color(0xFFD4A373) : const Color(0xFF5D4037);
  }

  /// نص الزر/التصنيف المختار
  static Color chipSelectedText(BuildContext context) {
    return isDark(context) ? const Color(0xFF121212) : Colors.white;
  }

  /// خلفية عداد الكميات (+) و (-)
  static Color stepperBg(BuildContext context) {
    return isDark(context) ? const Color(0xFF262626) : const Color(0xFFEBE6DC);
  }

  /// خلفية شريط التنقل السفلي الفاخر (نهاري: #FFFFFF | ليلي: #1E1E1E)
  static Color bottomNavBg(BuildContext context) {
    return isDark(context) ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  }

  /// حدود شريط التنقل السفلي
  static Color bottomNavBorder(BuildContext context) {
    return isDark(context) ? const Color(0xFF2C2C2C) : const Color(0xFFEBE6DC);
  }

  /// الفواصل الأفقية
  static Color divider(BuildContext context) {
    return isDark(context) ? const Color(0xFF2A2A2A) : const Color(0xFFEBE6DC);
  }

  /// مساعد لتنسيق أي نص بخط IBM Plex Sans Arabic المدمج محلياً بمرونة فائقة
  static TextStyle ibmFont({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontIBM,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // =========================================================================
  // السمة النهارية (Light Theme)
  // =========================================================================
  static ThemeData get lightTheme {
    final baseLight = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF5D4037),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      fontFamily: fontIBM,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF5D4037),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF5D4037),
        onPrimaryContainer: Colors.white,
        secondary: Color(0xFF8B6B5A),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFD7B899),
        onSecondaryContainer: Color(0xFF5D4037),
        tertiary: Color(0xFF226B42),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFE8F5E9),
        onTertiaryContainer: Color(0xFF1B5E20),
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF93000A),
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF3E2723),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF8F6F1),
        surfaceContainer: Color(0xFFF3EEE6),
        surfaceContainerHigh: Color(0xFFEBE6DC),
        onSurfaceVariant: Color(0xFF8B6B5A),
        outline: Color(0xFF8B6B5A),
        outlineVariant: Color(0xFFD7B899),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFF8F6F1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFEBE6DC), width: 1),
        ),
      ),
    );

    return baseLight.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF5D4037)),
        titleTextStyle: TextStyle(
          fontFamily: fontIBM,
          color: Color(0xFF5D4037),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5D4037),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: fontIBM,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // السمة الليلية الفاخرة (Dark Theme - Coffee Palette)
  // =========================================================================
  static ThemeData get darkTheme {
    final baseDark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFD4A373),
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: fontIBM,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFD4A373), // لون أساسي #D4A373
        onPrimary: Color(0xFF121212),
        primaryContainer: Color(0xFF1E1E1E),
        onPrimaryContainer: Color(0xFFF5D7B1),
        secondary: Color(0xFFA67C52), // لون ثانوي #A67C52
        onSecondary: Color(0xFF121212),
        secondaryContainer: Color(0xFF262626),
        onSecondaryContainer: Color(0xFFF5D7B1),
        tertiary: Color(0xFFA9F3BF),
        onTertiary: Color(0xFF00331A),
        tertiaryContainer: Color(0xFF1E2818),
        onTertiaryContainer: Color(0xFFDAE7CA),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF121212), // خلفية رئيسية #121212
        onSurface: Color(0xFFFFFFFF),
        surfaceContainerLowest: Color(0xFF181818),
        surfaceContainerLow: Color(0xFF1E1E1E), // خلفية ثانوية #1E1E1E
        surfaceContainer: Color(0xFF242424),
        surfaceContainerHigh: Color(0xFF2C2C2C),
        onSurfaceVariant: Color(0xFFF5D7B1), // لون Accent #F5D7B1
        outline: Color(0xFFA67C52),
        outlineVariant: Color(0xFF2C2C2C),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
        ),
      ),
    );

    return baseDark.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        titleTextStyle: TextStyle(
          fontFamily: fontIBM,
          color: Color(0xFFF5D7B1),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4A373),
          foregroundColor: const Color(0xFF121212),
          elevation: 2,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: fontIBM,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
