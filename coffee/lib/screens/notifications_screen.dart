import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_parent_widget.dart';
import '../services/supabase_service.dart';
import '../models/order_model.dart';

enum NotificationType { order, promo, system }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'all'; // 'all', 'orders', 'promos'

  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _fetchLiveNotifications();
  }

  void _initNotifications() {
    _notifications = [
      NotificationItem(
        id: 'n3',
        title: 'محصول حصري جديد: ركن قيدب V60 ✨',
        body: 'معالجة مجففة لاهوائية مع إيحاءات التوت الأزرق وعسل الزهور متوفرة الآن.',
        time: 'أمس',
        type: NotificationType.promo,
        isRead: true,
      ),
      NotificationItem(
        id: 'n4',
        title: 'خصم ضيافة رُكـن الأولى (-٦٠٠ ر.ي)',
        body: 'تم تفعيل خصم الضيافة الترحيبي تلقائياً لطلبك القادم عبر التطبيق.',
        time: 'منذ يومين',
        type: NotificationType.promo,
        isRead: true,
      ),
    ];
  }

  Future<void> _fetchLiveNotifications() async {
    try {
      final orders = await SupabaseService().getOrders();
      if (!mounted || orders.isEmpty) return;

      final List<NotificationItem> liveItems = [];
      for (final o in orders.take(5)) {
        String title;
        String body;
        switch (o.status) {
          case OrderStatus.received:
            title = 'تم استلام طلبك #${o.orderCode} 📝';
            body = 'طلبك قيد المراجعة لدى فريق باريستا رُكن وسيبدأ تحضيره قريباً.';
            break;
          case OrderStatus.inPrep:
            title = 'بدأ تحضير طلبك #${o.orderCode} ☕';
            body = 'يقوم الباريستا ${o.baristaName} بطحن الحبوب والتحضير بعناية.';
            break;
          case OrderStatus.ready:
            title = 'طلبك #${o.orderCode} جاهز للاستلام! 🎉';
            body = 'كوبك الدافئ بانتظارك الآن عند شباك الاستلام بكود ${o.orderCode}.';
            break;
          case OrderStatus.completed:
            title = 'تم تسليم الطلب #${o.orderCode} بنجاح ✅';
            body = 'صحة وعافية! نرجو أن ينال كوب ركن إعجابك، شاركنا تجربتك.';
            break;
          case OrderStatus.cancelled:
            title = 'تم إلغاء الطلب #${o.orderCode} ❌';
            body = o.cancelReason != null && o.cancelReason!.isNotEmpty
                ? 'سبب الإلغاء: ${o.cancelReason}'
                : 'تم إلغاء الطلب بناءً على رغبتك أو تعذر التجهيز.';
            break;
        }

        liveItems.add(
          NotificationItem(
            id: 'live_${o.id}',
            title: title,
            body: body,
            time: 'طلب حقيقي',
            type: NotificationType.order,
            isRead: o.status == OrderStatus.completed || o.status == OrderStatus.cancelled,
          ),
        );
      }

      setState(() {
        _notifications.insertAll(0, liveItems);
      });
    } catch (_) {}
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isRead = true;
      }
    });
    final isDark = AppTheme.isDark(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديد جميع الإشعارات كمقروءة',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? const Color(0xFF121212) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.accent(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final filteredList = _notifications.where((item) {
      if (_activeFilter == 'orders') {
        return item.type == NotificationType.order;
      }
      if (_activeFilter == 'promos') {
        return item.type == NotificationType.promo;
      }
      return true;
    }).toList();

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return CustomParentWidget(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.scaffoldBg(context),
        iconTheme: IconThemeData(color: AppTheme.textHeading(context)),
        title: Row(
          children: [
            Text(
              'الإشعارات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textHeading(context),
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount جديد',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.isDark(context) ? const Color(0xFF1E0F0A) : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: Icon(Icons.done_all, size: 16, color: AppTheme.accent(context)),
              label: Text(
                'تحديد كمقروء',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent(context),
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
            ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Filter Chips
          Row(
            children: [
              _buildFilterChip('all', 'الكل (${_notifications.length})'),
              const SizedBox(width: 8),
              _buildFilterChip(
                'orders',
                'الطلبات (${_notifications.where((n) => n.type == NotificationType.order).length})',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'promos',
                'العروض والجديد (${_notifications.where((n) => n.type == NotificationType.promo).length})',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Notifications List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLow(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 40,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'لا توجد إشعارات في هذا القسم',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHeading(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'سنقوم بإشعارك عند وجود أي تحديثات حول طلباتك.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF4A1818) : const Color(0xFFFFDAD6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A),
                          ),
                        ),
                        onDismissed: (_) => _deleteNotification(item.id),
                        child: _buildNotificationTile(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _activeFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _activeFilter = filter);
      },
      selectedColor: AppTheme.chipSelectedBg(context),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? AppTheme.chipSelectedText(context)
            : AppTheme.textSecondary(context),
      ),
      backgroundColor: AppTheme.chipBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppTheme.chipBorder(context),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    final isDark = AppTheme.isDark(context);
    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (item.type) {
      case NotificationType.order:
        icon = Icons.local_cafe;
        iconBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F6F1);
        iconColor = AppTheme.accent(context);
        break;
      case NotificationType.promo:
        icon = Icons.local_offer;
        iconBg = isDark ? const Color(0xFF262626) : const Color(0xFFD7B899).withValues(alpha: 0.35);
        iconColor = isDark ? const Color(0xFFF5D7B1) : const Color(0xFF8B6B5A);
        break;
      case NotificationType.system:
        icon = Icons.info;
        iconBg = isDark ? const Color(0xFF1A261A) : const Color(0xFFE8F5E9);
        iconColor = isDark ? const Color(0xFFA9F3BF) : const Color(0xFF226B42);
        break;
    }

    return InkWell(
      onTap: () {
        setState(() => item.isRead = true);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead
              ? AppTheme.cardBg(context)
              : AppTheme.surfaceLow(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? AppTheme.cardBorder(context)
                : AppTheme.accent(context).withValues(alpha: 0.4),
            width: item.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            color: AppTheme.textHeading(context),
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppTheme.accent(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(context),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
