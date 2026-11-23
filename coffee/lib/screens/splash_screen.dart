import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_parent_widget.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scaleAnimation = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.15, 1.0, curve: Curves.easeIn)),
    );

    _slideAnimation = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();

    // Navigate to MainNavigationShell after 2.6 seconds
    Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationShell(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    // ألوان ديناميكية وفق باليتة تطبيق القهوة المعتمدة
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
    final glowTop = isDark
        ? const Color(0xFF1E1E1E).withValues(alpha: 0.6)
        : const Color(0xFFF8F6F1).withValues(alpha: 0.8);
    final glowBottom = isDark
        ? const Color(0xFF262626).withValues(alpha: 0.5)
        : const Color(0xFFD7B899).withValues(alpha: 0.3);
    final logoBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF5D4037);
    final logoShadow =
        isDark ? const Color(0xFFD4A373) : const Color(0xFF5D4037);
    final titleColor =
        isDark ? const Color(0xFFF5D7B1) : const Color(0xFF5D4037);
    final tagBg = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF8F6F1);
    final tagTextColor =
        isDark ? const Color(0xFFD4A373) : const Color(0xFF5D4037);
    final subtitleColor =
        isDark ? const Color(0xFFA67C52) : const Color(0xFF8B6B5A);
    final progressColor =
        isDark ? const Color(0xFFD4A373) : const Color(0xFF5D4037);
    final dividerColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEBE6DC);

    return CustomParentWidget(
      enableSafeArea: false,
      backgroundColor: bgColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── خلفية: دوائر توهج محيطية ──────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) => Opacity(
                opacity: _glowAnimation.value * 0.9,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [glowTop, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) => Opacity(
                opacity: _glowAnimation.value * 0.8,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [glowBottom, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── المحتوى المركزي ────────────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // شعار التطبيق مع توهج
                        Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            color: logoBg,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: logoShadow.withValues(
                                    alpha: isDark ? 0.45 : 0.22),
                                blurRadius: 36,
                                spreadRadius: 0,
                                offset: const Offset(0, 14),
                              ),
                              if (isDark)
                                BoxShadow(
                                  color: const Color(0xFFD4A373)
                                      .withValues(alpha: 0.15),
                                  blurRadius: 40,
                                  spreadRadius: 6,
                                ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFFD7B899),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.local_cafe_rounded,
                              color: isDark
                                  ? const Color(0xFFD4A373)
                                  : Colors.white,
                              size: 56,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // اسم التطبيق مع انزلاق
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Column(
                            children: [
                              Text(
                                'رُكـن • ROKON',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                  letterSpacing: -0.5,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                              const SizedBox(height: 10),

                              // شعار الحروف الذهبي
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 5),
                                decoration: BoxDecoration(
                                  color: tagBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF2C2C2C)
                                        : const Color(0xFFEBE6DC),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'التحميص الحِرفي المباشر • قهوة مختصة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: tagTextColor,
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // فاصل أنيق
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 1,
                                    color: dividerColor,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? const Color(0xFFD4A373)
                                                .withValues(alpha: 0.6)
                                            : const Color(0xFF5D4037)
                                                .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 1,
                                    color: dividerColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── الجزء السفلي: مؤشر التحميل ────────────────────────────────
          Positioned(
            bottom: 52,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, _) => Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor.withValues(alpha: 0.75),
                        ),
                        backgroundColor:
                            progressColor.withValues(alpha: 0.15),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'جاري تحضير تجربة القهوة الخاصة بك...',
                      style: TextStyle(
                        fontSize: 11,
                        color: subtitleColor,
                        fontFamily: 'IBM Plex Sans Arabic',
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // نقاط اليمن
                    Text(
                      '🫘 صنعاء، اليمن',
                      style: TextStyle(
                        fontSize: 10,
                        color: subtitleColor.withValues(alpha: 0.6),
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
