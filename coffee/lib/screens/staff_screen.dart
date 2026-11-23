import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_parent_widget.dart';

class StaffScreen extends StatefulWidget {
  final List<OrderModel> orders;
  final Function(OrderModel) onOrderStatusChanged;
  final Future<void> Function()? onRefresh;

  const StaffScreen({
    super.key,
    required this.orders,
    required this.onOrderStatusChanged,
    this.onRefresh,
  });

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  String _activeFilter = 'all'; // 'all', 'new', 'prep', 'ready'
  final Set<String> _expandedOrderIds = {};

  // Station utility state
  bool _coffeeInStock = true;
  bool _soundEnabled = true;
  bool _isRefreshing = false;

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline,
                color: AppTheme.onTertiaryContainer, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.outlineVariant,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _advanceOrder(OrderModel order) {
    setState(() {
      if (order.status == OrderStatus.received) {
        order.status = OrderStatus.inPrep;
        _showToast('بدأ تحضير الطلب #${order.orderCode}');
      } else if (order.status == OrderStatus.inPrep) {
        order.status = OrderStatus.ready;
        _showToast('الطلب #${order.orderCode} جاهز على الرف!');
      } else if (order.status == OrderStatus.ready) {
        order.status = OrderStatus.completed;
        _showToast('تم تسليم الطلب #${order.orderCode} للعميل بنجاح');
      }
    });
    widget.onOrderStatusChanged(order);
  }

  void _toggleDetails(String id) {
    setState(() {
      if (_expandedOrderIds.contains(id)) {
        _expandedOrderIds.remove(id);
      } else {
        _expandedOrderIds.add(id);
      }
    });
  }

  void _refreshOrders() async {
    setState(() => _isRefreshing = true);
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    if (mounted) {
      setState(() => _isRefreshing = false);
      _showToast('تمت مزامنة الطلبات مع خادم سوبابيز بنجاح ✨');
    }
  }

  @override
  Widget build(BuildContext context) {
    final newCount =
        widget.orders.where((o) => o.status == OrderStatus.received).length;
    final prepCount =
        widget.orders.where((o) => o.status == OrderStatus.inPrep).length;
    final readyCount =
        widget.orders.where((o) => o.status == OrderStatus.ready).length;
    final cancelledCount =
        widget.orders.where((o) => o.status == OrderStatus.cancelled).length;
    final activeCount = newCount + prepCount;

    final double totalSales = widget.orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold(0.0, (sum, o) => sum + o.totalAmount);

    final filteredOrders = widget.orders.where((order) {
      if (_activeFilter == 'all') {
        return order.status != OrderStatus.completed &&
            order.status != OrderStatus.cancelled;
      }
      if (_activeFilter == 'new') return order.status == OrderStatus.received;
      if (_activeFilter == 'prep') return order.status == OrderStatus.inPrep;
      if (_activeFilter == 'ready') return order.status == OrderStatus.ready;
      if (_activeFilter == 'cancelled') return order.status == OrderStatus.cancelled;
      return true;
    }).toList();

    return CustomParentWidget(
      enableBottomSafeArea: false,
      appBar: CustomParentWidget.buildRokonAppBar(
        context: context,
        title: 'ركن • إدارة الطلبات',
        subtitle: 'محطة الإسبريسو والتقطير',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barista Greeting & Station Meta
            _buildStationGreeting(),
            const SizedBox(height: 14),

            // Live KPI Stat Cards (3 Grid)
            _buildKpiStatsGrid(
              totalCount: widget.orders.length,
              activeCount: activeCount,
              totalSales: totalSales,
            ),
            const SizedBox(height: 14),

            // Filter Chips (Live State Switcher)
            _buildFilterChips(
              allCount: activeCount,
              newCount: newCount,
              prepCount: prepCount,
              readyCount: readyCount,
              cancelledCount: cancelledCount,
            ),
            const SizedBox(height: 14),

            // Live Orders Feed
            if (filteredOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: AppTheme.outlineVariant),
                    SizedBox(height: 10),
                    Text(
                      'لا توجد طلبات في هذا القسم حالياً',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredOrders.map((order) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildOrderCard(order),
                );
              }),

            const SizedBox(height: 8),

            // Cafe Station Controls & Stock Utility Card
            _buildStationControlsCard(),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildStationGreeting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'لوحة الموظف - اليوم',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.outlineVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'محطة الإسبريسو ٢ • دوام الصباح',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cardBorder(context)),
            boxShadow: AppTheme.isDark(context)
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront, size: 16, color: AppTheme.accent(context)),
              const SizedBox(width: 4),
              Text(
                'فرع الأصبحي - صنعاء',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textHeading(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiStatsGrid({
    required int totalCount,
    required int activeCount,
    required double totalSales,
  }) {
    return Row(
      children: [
        // Stat 1: Total Orders
        Expanded(
          child: _buildKpiCard(
            icon: Icons.receipt_long,
            iconBg: AppTheme.chipBg(context),
            iconColor: AppTheme.accent(context),
            value: '$totalCount',
            label: 'إجمالي الطلبات',
          ),
        ),
        const SizedBox(width: 8),

        // Stat 2: Total Sales
        Expanded(
          child: _buildKpiCard(
            icon: Icons.payments,
            iconBg: AppTheme.chipBg(context),
            iconColor: AppTheme.accent(context),
            value: totalSales >= 1000
                ? '${(totalSales / 1000).toStringAsFixed(1)}k'
                : totalSales.toStringAsFixed(0),
            unit: 'ر.ي',
            label: 'إجمالي المبيعات',
          ),
        ),
        const SizedBox(width: 8),

        // Stat 3: Active Prep
        Expanded(
          child: _buildKpiCard(
            icon: Icons.timer,
            iconBg: AppTheme.chipBg(context),
            iconColor: AppTheme.accent(context),
            value: '$activeCount',
            label: 'طلبات قيد العمل',
            valueColor: AppTheme.accent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    String? unit,
    required String label,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder(context)),
        boxShadow: AppTheme.isDark(context)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppTheme.textHeading(context),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent(context),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: AppTheme.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips({
    required int allCount,
    required int newCount,
    required int prepCount,
    required int readyCount,
    required int cancelledCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton('all', 'الكل النشط', allCount, null),
          const SizedBox(width: 8),
          _buildFilterButton('new', 'جديد', newCount, AppTheme.accent(context)),
          const SizedBox(width: 8),
          _buildFilterButton(
              'prep', 'قيد التحضير', prepCount, const Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          _buildFilterButton('ready', 'جاهز', readyCount, const Color(0xFF4CAF50)),
          if (cancelledCount > 0) ...[
            const SizedBox(width: 8),
            _buildFilterButton(
                'cancelled', 'ملغي', cancelledCount, AppTheme.error),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    String filter,
    String label,
    int count,
    Color? dotColor,
  ) {
    final isSelected = _activeFilter == filter;

    return InkWell(
      onTap: () => setState(() => _activeFilter = filter),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.chipSelectedBg(context) : AppTheme.chipBg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.chipBorder(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null && !isSelected) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppTheme.chipSelectedText(context)
                    : AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.15)
                    : AppTheme.surfaceLow(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppTheme.chipSelectedText(context)
                      : AppTheme.textHeading(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isDark = AppTheme.isDark(context);
    final isExpanded = _expandedOrderIds.contains(order.id);
    final firstItem =
        order.items.isNotEmpty ? order.items.first : null;

    // Status specifics
    String badgeLabel;
    Color badgeBg;
    Color badgeTextColor;
    Widget? badgeIcon;

    String actionBtnLabel;
    Color actionBtnBg;
    Color actionBtnTextColor;
    IconData actionBtnIcon;

    if (order.status == OrderStatus.received) {
      badgeLabel = 'جديد';
      badgeBg = isDark ? const Color(0xFF381F17) : AppTheme.primaryFixed;
      badgeTextColor = isDark ? const Color(0xFFFFDCC3) : AppTheme.onPrimaryContainer;
      badgeIcon = Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppTheme.accent(context),
          shape: BoxShape.circle,
        ),
      );
      actionBtnLabel = 'ابدأ التحضير';
      actionBtnBg = AppTheme.accent(context);
      actionBtnTextColor = isDark ? const Color(0xFF121212) : Colors.white;
      actionBtnIcon = Icons.arrow_back; // points forward in RTL
    } else if (order.status == OrderStatus.inPrep) {
      badgeLabel = 'قيد التحضير';
      badgeBg = isDark ? const Color(0xFF262626) : const Color(0xFFF3EEE6);
      badgeTextColor = isDark ? const Color(0xFFF5D7B1) : const Color(0xFF8B6B5A);
      badgeIcon = Icon(Icons.sync, size: 13, color: AppTheme.accent(context));
      actionBtnLabel = 'تم - جاهز للاستلام';
      actionBtnBg = const Color(0xFF226B42);
      actionBtnTextColor = Colors.white;
      actionBtnIcon = Icons.check_circle;
    } else if (order.status == OrderStatus.ready) {
      badgeLabel = 'جاهز للاستلام';
      badgeBg = isDark ? const Color(0xFF1E3825) : AppTheme.tertiaryFixed;
      badgeTextColor = isDark ? const Color(0xFFA9F3BF) : AppTheme.onTertiaryContainer;
      badgeIcon = const Icon(Icons.check, size: 14, color: Color(0xFF226B42));
      actionBtnLabel = 'تم التسليم للعميل';
      actionBtnBg = AppTheme.accent(context);
      actionBtnTextColor = isDark ? const Color(0xFF1E0F0A) : Colors.white;
      actionBtnIcon = Icons.done_all;
    } else if (order.status == OrderStatus.cancelled) {
      badgeLabel = 'ملغي';
      badgeBg = AppTheme.errorContainer;
      badgeTextColor = AppTheme.error;
      badgeIcon = const Icon(Icons.cancel, size: 13, color: AppTheme.error);
      actionBtnLabel = 'طلب ملغي';
      actionBtnBg = Colors.transparent;
      actionBtnTextColor = AppTheme.error;
      actionBtnIcon = Icons.cancel_outlined;
    } else {
      badgeLabel = 'مكتمل';
      badgeBg = isDark ? const Color(0xFF1E3825) : AppTheme.tertiaryFixed;
      badgeTextColor = isDark ? const Color(0xFFA9F3BF) : AppTheme.onTertiaryContainer;
      badgeIcon = const Icon(Icons.check, size: 14, color: Color(0xFF226B42));
      actionBtnLabel = 'تم التسليم';
      actionBtnBg = AppTheme.accent(context);
      actionBtnTextColor = isDark ? const Color(0xFFD7B899) : Colors.white;
      actionBtnIcon = Icons.done_all;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder(context)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row (Avatar Initial, Name, Code, Time, Status Pill)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.surfaceLow(context),
                    child: Text(
                      order.customerName.isNotEmpty
                          ? order.customerName[0]
                          : 'ع',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            order.customerName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textHeading(context),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '#${order.orderCode}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary(context),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            order.status == OrderStatus.ready
                                ? Icons.pin_drop_outlined
                                : Icons.schedule,
                            size: 13,
                            color: order.status == OrderStatus.ready
                                ? const Color(0xFF4CAF50)
                                : AppTheme.textSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.status == OrderStatus.ready
                                ? 'جاهز على رف A-1 (${order.estimatedReadyTime})'
                                : '١٢:٠٥ م (منذ دقيقتين)',
                            style: TextStyle(
                              fontSize: 11,
                              color: order.status == OrderStatus.ready
                                  ? const Color(0xFF4CAF50)
                                  : AppTheme.textSecondary(context),
                              fontWeight: order.status == OrderStatus.ready
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    badgeIcon,
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Item Specification Box (Collapsible)
          InkWell(
            onTap: () => _toggleDetails(order.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          firstItem != null
                              ? (order.items.length > 1
                                  ? '${firstItem.coffee.name} (+${order.items.length - 1} آخر)'
                                  : firstItem.coffee.name)
                              : 'طلب قهوة مختصة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHeading(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} ر.ي',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    firstItem != null
                        ? '${order.items.length} صنف • ${firstItem.size} • ${firstItem.milk}'
                        : 'وسط (M) • حليب شوفان • بدون سكر',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),

                  // Progress Bar if inPrep
                  if (order.status == OrderStatus.inPrep) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مرحلة خفق الحليب والإسبريسو',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        Text(
                          '٧٠٪',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 5,
                        backgroundColor: AppTheme.cardBorder(context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accent(context)),
                      ),
                    ),
                  ],

                  // Expanded Barista Recipe Notes
                  if (isExpanded) ...[
                    Divider(
                        height: 16, color: AppTheme.divider(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الاستخلاص: ١٨ جم بن -> ٣٦ جم سائل',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        Text(
                          'استخلاص مزدوج',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ملاحظة العميل: درجة حرارة خفيفة للحليب (warm not boiling).',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppTheme.textHeading(context),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Cancellation Notice if order is cancelled
          if (order.status == OrderStatus.cancelled && order.cancelReason != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'سبب الإلغاء: ${order.cancelReason}',
                      style: const TextStyle(
                        fontSize: 12,
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
          const SizedBox(height: 12),

          // Progressive Action Button or Cancelled State Banner
          if (order.status == OrderStatus.cancelled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.cardBorder(context)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_circle_outline, size: 16, color: AppTheme.error),
                  SizedBox(width: 8),
                  Text(
                    'تم إلغاء الطلب واسترجاع المبلغ تلقائياً للعميل',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _advanceOrder(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionBtnBg,
                  foregroundColor: actionBtnTextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(actionBtnIcon, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      actionBtnLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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

  Widget _buildStationControlsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder(context)),
        boxShadow: AppTheme.isDark(context)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                ),
              ],
      ),
      child: Column(
        children: [
          // Header with Refresh action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune, size: 20, color: AppTheme.accent(context)),
                  const SizedBox(width: 8),
                  Text(
                    'التحكم بالمخزون السريع والنداء',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHeading(context),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _refreshOrders,
                child: Row(
                  children: [
                    _isRefreshing
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accent(context),
                            ),
                          )
                        : Icon(Icons.refresh,
                            size: 16, color: AppTheme.accent(context)),
                    const SizedBox(width: 4),
                    Text(
                      'تحديث',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 22, color: AppTheme.divider(context)),

          // Toggle 1: Coffee Stock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'قهوة اليوم (إثيوبيا غوجي)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHeading(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _coffeeInStock
                        ? 'متوفرة - متبقي ٧ أكواب'
                        : 'نفذت الكمية - ٠ كوب (غير معروضة)',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          _coffeeInStock ? const Color(0xFF4CAF50) : AppTheme.error,
                      fontWeight: _coffeeInStock
                          ? FontWeight.w500
                          : FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _coffeeInStock,
                activeTrackColor: const Color(0xFF4CAF50),
                onChanged: (val) {
                  setState(() => _coffeeInStock = val);
                  _showToast(val
                      ? 'تم تحديث المخزون: قهوة اليوم متوفرة'
                      : 'تنبيه: تم إيقاف طلب قهوة اليوم');
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Toggle 2: Audio chime
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تنبيهات صوت الجرس للطلبات',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHeading(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'رنين لطيف عند وصول طلب جديد',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _soundEnabled,
                activeTrackColor: AppTheme.accent(context),
                onChanged: (val) {
                  setState(() => _soundEnabled = val);
                  _showToast(
                      val ? 'تم تفعيل التنبيه الصوتي' : 'الوضع الصامت مفعل');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
