import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;
  final String orderCode;

  const OrderStatusTimeline({
    super.key,
    required this.status,
    required this.orderCode,
  });

  @override
  Widget build(BuildContext context) {
    final int currentStage = status.stageNumber;
    final isDark = AppTheme.isDark(context);

    String badgeText;
    Color badgeBg;
    Color badgeTextColor;

    if (status == OrderStatus.cancelled) {
      badgeText = 'تم الإلغاء';
      badgeBg = AppTheme.errorContainer;
      badgeTextColor = AppTheme.error;
    } else if (currentStage >= 3) {
      badgeText = 'المرحلة 3 من 3 (مكتمل)';
      badgeBg = isDark ? const Color(0xFF1E3825) : AppTheme.tertiaryFixed;
      badgeTextColor = isDark ? const Color(0xFFA9F3BF) : AppTheme.onTertiaryContainer;
    } else if (currentStage == 2) {
      badgeText = 'المرحلة 2 من 3';
      badgeBg = isDark ? const Color(0xFF3B2418) : AppTheme.primary.withValues(alpha: 0.12);
      badgeTextColor = isDark ? AppTheme.accent(context) : AppTheme.primary;
    } else {
      badgeText = 'المرحلة 1 من 3';
      badgeBg = isDark ? const Color(0xFF3B2418) : AppTheme.primary.withValues(alpha: 0.12);
      badgeTextColor = isDark ? AppTheme.accent(context) : AppTheme.primary;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مراحل الطلب',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (status == OrderStatus.cancelled) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: AppTheme.error, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تم إلغاء هذا الطلب واسترجاع المبلغ للعميل.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Vertical Timeline Steps
            _buildTimelineStep(
              context: context,
              stepNumber: 1,
              isCompleted: currentStage > 1,
              isActive: currentStage == 1,
              isLast: false,
              title: 'تم استلام طلبك',
              time: currentStage == 1 ? 'الآن' : 'مكتمل',
              isNowTag: currentStage == 1,
              description: 'تم تأكيد طلبك وإرسال الإشعار للمحمصة للبدء فوراً',
              icon: Icons.check,
            ),
            _buildTimelineStep(
              context: context,
              stepNumber: 2,
              isCompleted: currentStage > 2,
              isActive: currentStage == 2,
              isLast: false,
              title: 'قيد التحضير والتخمير',
              time: currentStage == 2 ? 'الآن' : (currentStage > 2 ? 'مكتمل' : 'قريباً'),
              isNowTag: currentStage == 2,
              description: 'يقوم الباريستا بطحن المحصول الطازج والتحضير بعناية',
              icon: Icons.coffee_maker_outlined,
            ),
            _buildTimelineStep(
              context: context,
              stepNumber: 3,
              isCompleted: status == OrderStatus.completed,
              isActive: status == OrderStatus.ready,
              isLast: true,
              title: status == OrderStatus.completed ? 'تم الاستلام بنجاح' : 'جاهز في ركن الاستلام',
              time: status == OrderStatus.ready
                  ? 'الآن'
                  : (status == OrderStatus.completed ? 'مكتمل' : 'متوقع'),
              isNowTag: status == OrderStatus.ready,
              description: status == OrderStatus.completed
                  ? 'صحة وعافية! نتمنى لك تجربة استثنائية'
                  : 'تفضل باستلام كوبك الدافئ من شباك الاستلام بكود $orderCode',
              icon: status == OrderStatus.completed ? Icons.done_all : Icons.shopping_bag_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required BuildContext context,
    required int stepNumber,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
    required String title,
    required String time,
    required String description,
    required IconData icon,
    bool isNowTag = false,
  }) {
    Color iconBgColor;
    Color iconColor;

    if (isCompleted && !isActive) {
      iconBgColor = const Color(0xFF226B42);
      iconColor = Colors.white;
    } else if (isActive) {
      iconBgColor = stepNumber == 3 ? const Color(0xFF226B42) : AppTheme.accent(context);
      iconColor = AppTheme.isDark(context) ? const Color(0xFF1E0F0A) : Colors.white;
    } else {
      iconBgColor = AppTheme.surfaceLow(context);
      iconColor = AppTheme.textSecondary(context);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator column with icon and connecting line
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: iconBgColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isCompleted && !isActive ? Icons.done : icon,
                  size: 18,
                  color: iconColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF226B42)
                          : AppTheme.cardBorder(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w600,
                          color: isActive
                              ? (stepNumber == 3
                                  ? const Color(0xFF4CAF50)
                                  : AppTheme.accent(context))
                              : AppTheme.textHeading(context),
                        ),
                      ),
                      if (isNowTag)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'الآن',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        )
                      else
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary(context),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textSecondary(context),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
