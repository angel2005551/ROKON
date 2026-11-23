import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';

/// ويدجت أب مخصص يلتف حول كل صفحات التطبيق ويوفر خلفية موحدة وتنسيق شريط النظام و SafeArea
/// ويدعم بالكامل هوية ألوان ركن الجديدة والوضعين النهاري والليلي
class CustomParentWidget extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool enableSafeArea;
  final bool enableBottomSafeArea;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function()? onRefresh;
  final bool dismissKeyboardOnTap;

  const CustomParentWidget({
    super.key,
    required this.child,
    this.backgroundColor,
    this.enableSafeArea = true,
    this.enableBottomSafeArea = true,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.padding,
    this.onRefresh,
    this.dismissKeyboardOnTap = true,
  });

  /// هيدر ركن الرسمي الموحد لجميع صفحات التطبيق
  static PreferredSizeWidget buildRokonAppBar({
    required BuildContext context,
    String title = 'ركن • ROKON',
    String subtitle = 'Order Coffee',
    Widget? leading,
    List<Widget>? actions,
    VoidCallback? onNotificationTap,
    bool showProfile = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
    final titleColor = AppTheme.textHeading(context);
    final iconColor = AppTheme.textSecondary(context);
    final accentColor = AppTheme.accent(context);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: bgColor.withValues(alpha: 0.95),
      leading: leading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF5D4037),
              borderRadius: BorderRadius.circular(10),
              border: isDark ? Border.all(color: const Color(0xFF2C2C2C)) : null,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFFD4A373).withValues(alpha: 0.2)
                      : const Color(0xFF5D4037).withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.local_cafe,
                color: isDark ? accentColor : Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: actions ??
          [
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 22),
                  color: iconColor,
                  tooltip: 'الإشعارات',
                  onPressed: onNotificationTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 4.0),
              child: IconButton(
                icon: const Icon(Icons.tune_rounded, size: 22),
                color: iconColor,
                tooltip: 'تفضيلات التطبيق والفرع',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = backgroundColor ?? AppTheme.scaffoldBg(context);

    Widget bodyContent = child;

    if (padding != null) {
      bodyContent = Padding(padding: padding!, child: bodyContent);
    }

    if (onRefresh != null) {
      bodyContent = RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppTheme.accent(context),
        backgroundColor: AppTheme.cardBg(context),
        child: bodyContent,
      );
    }

    if (enableSafeArea) {
      bodyContent = SafeArea(
        top: appBar == null,
        bottom: enableBottomSafeArea && bottomNavigationBar == null,
        child: bodyContent,
      );
    }

    if (dismissKeyboardOnTap) {
      bodyContent = GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: bodyContent,
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: effectiveBg,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar: appBar,
          body: bodyContent,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ),
      ),
    );
  }
}
