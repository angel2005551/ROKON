import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  tertiary,
  outline,
  danger,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final double height;
  final bool isLoading;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.height = 52,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? border;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = isDark ? const Color(0xFFD4A373) : const Color(0xFF5D4037);
        foregroundColor = isDark ? const Color(0xFF121212) : Colors.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFF8F6F1);
        foregroundColor = isDark ? const Color(0xFFF5D7B1) : const Color(0xFF5D4037);
        border = BorderSide(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEBE6DC),
          width: 1,
        );
        break;
      case ButtonVariant.tertiary:
        backgroundColor = const Color(0xFF226B42);
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? const Color(0xFFD4A373) : const Color(0xFF5D4037);
        border = BorderSide(
          color: isDark ? const Color(0xFFD4A373) : const Color(0xFFD7B899),
          width: 1.5,
        );
        break;
      case ButtonVariant.danger:
        backgroundColor = isDark ? const Color(0xFF381515) : const Color(0xFFFFDAD6);
        foregroundColor = isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A);
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(height / 2),
          side: border ?? BorderSide.none,
        ),
        elevation: variant == ButtonVariant.primary || variant == ButtonVariant.tertiary ? 2 : 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          splashColor: foregroundColor.withValues(alpha: 0.12),
          highlightColor: foregroundColor.withValues(alpha: 0.08),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: foregroundColor,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: foregroundColor),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: foregroundColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
