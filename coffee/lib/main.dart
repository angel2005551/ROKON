import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/order_model.dart';
import 'data/mock_data.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/create_order_screen.dart';
import 'screens/order_tracking_screen.dart';
import 'screens/staff_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await SupabaseService.initialize();
  runApp(const RokonCoffeeApp());
}

class RokonCoffeeApp extends StatelessWidget {
  const RokonCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'ركن | ROKON Coffee',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0; // Default to "اطلب قهوتك" as in Design A
  late List<OrderModel> _orders;
  late OrderModel _currentTrackingOrder;
  StreamSubscription? _ordersSubscription;

  @override
  void initState() {
    super.initState();
    _orders = List.from(MockData.mockOrdersList);
    _currentTrackingOrder = _orders.first;
    _fetchSupabaseOrders();
    _listenToRealtimeOrders();
  }

  void _listenToRealtimeOrders() {
    _ordersSubscription = SupabaseService().subscribeToOrders(
      onOrdersUpdated: (liveOrders) {
        if (mounted && liveOrders.isNotEmpty) {
          setState(() {
            _orders = liveOrders;
            final activeIndex = _orders
                .indexWhere((o) => o.id == _currentTrackingOrder.id);
            if (activeIndex != -1) {
              _currentTrackingOrder = _orders[activeIndex];
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchSupabaseOrders() async {
    final dbOrders = await SupabaseService().getOrders();
    if (mounted && dbOrders.isNotEmpty) {
      setState(() {
        _orders = dbOrders;
        _currentTrackingOrder = _orders.first;
      });
    }
  }

  void _onOrderPlaced(OrderModel newOrder) {
    setState(() {
      _orders.insert(0, newOrder);
      _currentTrackingOrder = newOrder;
      _currentIndex = 1; // Switch to tracking screen
    });

    // Sync to Supabase in background
    SupabaseService().placeOrder(newOrder).then((placedOrder) {
      if (mounted) {
        setState(() {
          final index = _orders.indexWhere((o) => o.orderCode == newOrder.orderCode);
          if (index != -1) {
            _orders[index] = placedOrder;
          }
          if (_currentTrackingOrder.orderCode == newOrder.orderCode) {
            _currentTrackingOrder = placedOrder;
          }
        });
      }
    });
  }

  void _onOrderStatusChanged(OrderModel updatedOrder) {
    setState(() {
      final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      if (_currentTrackingOrder.id == updatedOrder.id) {
        _currentTrackingOrder = updatedOrder;
      }
    });

    // Sync status change to Supabase
    SupabaseService().updateOrderStatus(
      updatedOrder.id,
      updatedOrder.status,
      cancelReason: updatedOrder.cancelReason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    final List<Widget> screens = [
      CreateOrderScreen(onOrderPlaced: _onOrderPlaced),
      OrderTrackingScreen(
        order: _currentTrackingOrder,
        onNavigateToOrder: () {
          setState(() {
            _currentIndex = 0;
          });
        },
        onOrderStatusChanged: _onOrderStatusChanged,
      ),
      StaffScreen(
        orders: _orders,
        onOrderStatusChanged: _onOrderStatusChanged,
        onRefresh: _fetchSupabaseOrders,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppTheme.scaffoldBg(context),
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SafeArea(
            top: false,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.50)
                        : const Color(0xFF5D4037).withValues(alpha: 0.12),
                    blurRadius: 26,
                    spreadRadius: -1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: isDark
                        ? const Color(0xFFD4A373).withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1C1A).withValues(alpha: 0.68)
                          : Colors.white.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFD4A373).withValues(alpha: 0.22)
                            : Colors.white.withValues(alpha: 0.75),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          context: context,
                          index: 0,
                          icon: Icons.coffee_outlined,
                          activeIcon: Icons.coffee_rounded,
                          label: 'اطلب قهوتك',
                        ),
                        _buildNavItem(
                          context: context,
                          index: 1,
                          icon: Icons.local_shipping_outlined,
                          activeIcon: Icons.local_shipping_rounded,
                          label: 'تتبع طلبك',
                        ),
                        _buildNavItem(
                          context: context,
                          index: 2,
                          icon: Icons.assignment_outlined,
                          activeIcon: Icons.assignment_rounded,
                          label: 'إدارة الطلبات',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = AppTheme.isDark(context);
    final activeColor = AppTheme.accent(context);
    final unselectedColor = isDark
        ? const Color(0xFFA67C52).withValues(alpha: 0.75)
        : AppTheme.textSecondary(context).withValues(alpha: 0.80);

    // الكبسولة الزجاجية المحددة للعنصر النشط مطابقة تماماً للصورة
    final activePillBg = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : activeColor.withValues(alpha: 0.13);

    final activePillBorder = isDark
        ? Colors.white.withValues(alpha: 0.20)
        : activeColor.withValues(alpha: 0.25);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activePillBg : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected ? activePillBorder : Colors.transparent,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.15)
                          : activeColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? activeColor : unselectedColor,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  style: AppTheme.ibmFont(
                    fontSize: isSelected ? 11.5 : 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? activeColor : unselectedColor,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
