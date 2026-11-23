import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/order_model.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/order_status.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_parent_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel? order;
  final VoidCallback? onNavigateToOrder;
  final Function(OrderModel)? onOrderStatusChanged;

  const OrderTrackingScreen({
    super.key,
    this.order,
    this.onNavigateToOrder,
    this.onOrderStatusChanged,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

enum TrackingViewState { received, inPrep, ready, completed, loading, empty, cancelled }

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TrackingViewState _currentViewState;
  late OrderModel _activeOrder;

  // Countdown timer
  int _countdownSeconds = 480; // 08:00 minutes
  Timer? _timer;

  // Animation controller for steam & coffee liquid
  late AnimationController _animController;

  // QR Code Brightness Mode
  bool _isQrBright = false;

  void _updateViewStateFromOrder(OrderModel order) {
    switch (order.status) {
      case OrderStatus.received:
        _currentViewState = TrackingViewState.received;
        break;
      case OrderStatus.inPrep:
        _currentViewState = TrackingViewState.inPrep;
        break;
      case OrderStatus.ready:
        _currentViewState = TrackingViewState.ready;
        break;
      case OrderStatus.completed:
        _currentViewState = TrackingViewState.completed;
        break;
      case OrderStatus.cancelled:
        _currentViewState = TrackingViewState.cancelled;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _activeOrder = widget.order ?? MockData.defaultActiveOrder;
    _updateViewStateFromOrder(_activeOrder);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _startCountdown();
  }

  @override
  void didUpdateWidget(covariant OrderTrackingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.order != null) {
      setState(() {
        _activeOrder = widget.order!;
        _updateViewStateFromOrder(_activeOrder);
      });
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0 &&
          (_currentViewState == TrackingViewState.inPrep ||
              _currentViewState == TrackingViewState.received)) {
        setState(() {
          _countdownSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  String _formatCountdown(int totalSeconds) {
    if (_currentViewState == TrackingViewState.ready) {
      return 'جاهز الآن';
    }
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _copyOrderCode() {
    Clipboard.setData(ClipboardData(text: _activeOrder.orderCode));
    _showToast('تم نسخ رمز الطلب: ${_activeOrder.orderCode}');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.tertiaryFixed, size: 20),
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
        backgroundColor: AppTheme.onSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _simulatePullRefresh() {
    _showToast('جاري تحديث حالة القهوة الآن...');
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _showToast('تم تحديث حالة القهوة بنجاح ✨');
      }
    });
  }

  void _confirmPicked() {
    _showRatingModal();
  }

  void _showRatingModal() {
    int rating = 5;
    final tags = ['سرعة التحضير', 'حرارة مثالية', 'نكهة القهوة', 'باريستا محترف', 'تغليف أنيق'];
    final selectedTags = <String>{'نكهة القهوة', 'حرارة مثالية'};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'تقييم تجربة القهوة ☕',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'كيف كانت قهوتك من إعداد ${_activeOrder.baristaName}؟',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      icon: Icon(
                        starIndex <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 38,
                        color: starIndex <= rating
                            ? const Color(0xFFFFB800)
                            : AppTheme.textSecondary(context).withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        setModalState(() => rating = starIndex);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: tags.map((tag) {
                    final isSel = selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSel ? AppTheme.chipSelectedText(context) : AppTheme.textPrimary(context),
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppTheme.chipSelectedBg(context),
                      backgroundColor: AppTheme.chipBg(context),
                      onSelected: (selected) {
                        setModalState(() {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'إرسال التقييم وتأكيد الاستلام',
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showToast('شكراً لتقييمك الرائع! نرجو أن ينال كوب ركن إعجابك دائماً ☕');
                    setState(() {
                      _activeOrder.status = OrderStatus.completed;
                    });
                    widget.onOrderStatusChanged?.call(_activeOrder);
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() {
                          _currentViewState = TrackingViewState.completed;
                        });
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelModal() {
    final List<String> cancelReasons = [
      'تغيير الطلب',
      'انتظار طويل',
      'ظروف طارئة',
      'تكرار الطلب',
      'سبب آخر',
    ];
    String? selectedReason;
    final TextEditingController customReasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: AppTheme.cardBg(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: AppTheme.error, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هل تود إلغاء هذا الطلب؟',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHeading(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الباريستا بدأ بتحضير القهوة، في حال الإلغاء سيتم إرجاع المبلغ (${_activeOrder.totalAmount.toStringAsFixed(0)} ر.ي) إلى محفظتك أو بطاقتك.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary(context),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Reason Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLow(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.chipBorder(context)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedReason,
                        hint: Text(
                          'اختر سبب الإلغاء',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                        dropdownColor: AppTheme.cardBg(context),
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: AppTheme.textHeading(context),
                        ),
                        items: cancelReasons.map((reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedReason = val;
                          });
                        },
                      ),
                    ),
                  ),
                  // Custom reason text field when "سبب آخر" is selected
                  if (selectedReason == 'سبب آخر') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: customReasonCtrl,
                      textDirection: TextDirection.rtl,
                      maxLength: 100,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: AppTheme.textHeading(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب سبب الإلغاء...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary(context),
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceLow(context),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.chipBorder(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.chipBorder(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.error, width: 1.5),
                        ),
                        counterStyle: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'تراجع',
                          variant: ButtonVariant.secondary,
                          height: 44,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'تأكيد الإلغاء',
                          variant: ButtonVariant.danger,
                          height: 44,
                          onPressed: selectedReason == null ||
                                  (selectedReason == 'سبب آخر' &&
                                      customReasonCtrl.text.trim().isEmpty)
                              ? null
                              : () {
                                  final finalReason =
                                      selectedReason == 'سبب آخر'
                                          ? customReasonCtrl.text.trim()
                                          : selectedReason!;
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _activeOrder.status =
                                        OrderStatus.cancelled;
                                    _activeOrder.cancelReason = finalReason;
                                    _currentViewState =
                                        TrackingViewState.cancelled;
                                  });
                                  widget.onOrderStatusChanged?.call(_activeOrder);
                                  _showToast('تم إلغاء الطلب بسبب: $finalReason');
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      enableBottomSafeArea: false,
      appBar: CustomParentWidget.buildRokonAppBar(
        context: context,
        title: 'ركن • ROKON',
        subtitle: 'تتبع طلب القهوة',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Screen Header Bar (Back + Title + Order Code Pill)
            _buildHeaderBar(),
            const SizedBox(height: 12),

            // Pull-to-refresh Delight trigger
            _buildRefreshTrigger(),
            const SizedBox(height: 14),

            // View Switcher based on current order status
            if (_currentViewState == TrackingViewState.loading)
              _buildSkeletonLoadingView()
            else if (_currentViewState == TrackingViewState.cancelled)
              _buildCancelledStateView()
            else if (_currentViewState == TrackingViewState.completed)
              _buildCompletedStateView()
            else if (_currentViewState == TrackingViewState.empty)
              _buildEmptyStateView()
            else
              _buildActiveOrderView(),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: widget.onNavigateToOrder,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLow(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward, size: 18, color: AppTheme.textHeading(context)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تتبع طلبك',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                  ),
                ),
                Text(
                  'ركن القهوة المختصة',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Order Badge with Copy Action
        InkWell(
          onTap: _copyOrderCode,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.chipBg(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.chipBorder(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: AppTheme.accent(context),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _activeOrder.orderCode,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.copy_rounded, size: 15, color: AppTheme.accent(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshTrigger() {
    return InkWell(
      onTap: _simulatePullRefresh,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sync, size: 16, color: AppTheme.textSecondary(context)),
            const SizedBox(width: 6),
            Text(
              'اسحب أو انقر للتحديث الفوري لقطرات القهوة',
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrderView() {
    final bool isReady = _activeOrder.status == OrderStatus.ready;

    return Column(
      children: [
        // Hero Card: Animated Coffee Cup & Live Countdown
        _buildHeroExtractionCard(_activeOrder.status),
        const SizedBox(height: 14),

        // Timeline
        OrderStatusTimeline(
          status: _activeOrder.status,
          orderCode: _activeOrder.orderCode,
        ),
        const SizedBox(height: 14),

        // QR Code Verification Card
        _buildQrCard(),
        const SizedBox(height: 14),

        // Detailed Order Summary
        _buildOrderSummaryCard(),
        const SizedBox(height: 18),

        // Action Buttons Tray
        _buildActionButtonsTray(isReady),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeroExtractionCard(OrderStatus status) {
    final bool isReady = status == OrderStatus.ready;
    final bool isReceived = status == OrderStatus.received;

    String pillLabel;
    String pillTime;
    Color pillDotColor;

    if (isReady) {
      pillLabel = 'حالة الطلب:';
      pillTime = 'جاهز للاستلام الآن ✨';
      pillDotColor = const Color(0xFF4CAF50);
    } else if (isReceived) {
      pillLabel = 'حالة الطلب:';
      pillTime = 'تم الاستلام وبدء الطحن';
      pillDotColor = AppTheme.accent(context);
    } else {
      pillLabel = 'الوقت المقدر لتجهيز كوبك:';
      pillTime = _formatCountdown(_countdownSeconds);
      pillDotColor = const Color(0xFFF59E0B);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          children: [
            // Countdown / Status Timer Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: pillDotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pillLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pillTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: pillDotColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Animated Visual Coffee Cup
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: CoffeeCupPainter(
                          progress: isReady
                              ? 0.95
                              : (isReceived ? 0.35 : (0.60 + _animController.value * 0.05)),
                          steamPhase: _animController.value,
                          isReady: isReady,
                        ),
                      );
                    },
                  ),
                ),
                if (isReady)
                  const Positioned(
                    top: 10,
                    right: 20,
                    child: Text('✨', style: TextStyle(fontSize: 22)),
                  ),
                if (isReady)
                  const Positioned(
                    bottom: 15,
                    left: 20,
                    child: Text('☕', style: TextStyle(fontSize: 20)),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // State Title and Subtitle
            Text(
              _activeOrder.statusTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textHeading(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _activeOrder.statusSubtitle,
              style: TextStyle(
                fontSize: 12.5,
                color: AppTheme.textSecondary(context),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Barista Live Stamp
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow(context),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundImage: NetworkImage(_activeOrder.baristaAvatarUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الباريستا: ${_activeOrder.baristaName}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHeading(context),
                          ),
                        ),
                        Text(
                          _activeOrder.baristaRole,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.local_cafe, color: AppTheme.accent(context), size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: AppTheme.accent(context), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'رمز الاستلام السريع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textHeading(context),
                      ),
                    ),
                  ],
                ),
                // Brightness Toggle
                InkWell(
                  onTap: () {
                    setState(() {
                      _isQrBright = !_isQrBright;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLow(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isQrBright ? Icons.brightness_high : Icons.brightness_6,
                          size: 14,
                          color: AppTheme.accent(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isQrBright ? 'خفت السطوع' : 'سطوع الكود',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // QR Representation with toggleable high contrast container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isQrBright ? Colors.white : AppTheme.surfaceLow(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isQrBright ? AppTheme.accent(context) : AppTheme.cardBorder(context),
                  width: _isQrBright ? 3 : 1,
                ),
                boxShadow: _isQrBright
                    ? [
                        BoxShadow(
                          color: AppTheme.accent(context).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: QrImageView(
                      data: 'ROKON-${_activeOrder.orderCode}-${_activeOrder.branch}',
                      version: QrVersions.auto,
                      size: 140,
                      backgroundColor: _isQrBright ? Colors.white : Colors.transparent,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: _isQrBright
                            ? const Color(0xFF121212)
                            : (AppTheme.isDark(context)
                                ? const Color(0xFFD4A373)
                                : const Color(0xFF5D4037)),
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: _isQrBright
                            ? const Color(0xFF121212)
                            : (AppTheme.isDark(context)
                                ? const Color(0xFFD4A373)
                                : const Color(0xFF3E2723)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Simulated Barcode
                  SizedBox(
                    width: 160,
                    height: 24,
                    child: CustomPaint(
                      painter: BarcodePainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'رقم الطلب ${_activeOrder.orderCode}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textHeading(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'أظهره للموظف أو امسحه ضوئياً عند شباك الاستلام السريع',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفاصيل الفاتورة والطلب',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.chipBg(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_activeOrder.items.length} صنف مختار',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Render ALL items in the order
            ..._activeOrder.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: item.coffee.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: AppTheme.surfaceLow(context),
                          child: const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: AppTheme.surfaceLow(context),
                          child: Icon(Icons.coffee, color: AppTheme.accent(context)),
                        ),
                      ),
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
                                  '${item.coffee.name} (×${item.quantity})',
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
                                '${item.totalPrice.toStringAsFixed(0)} ر.ي',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildSpecChip(item.size),
                              _buildSpecChip(item.milk),
                              _buildSpecChip(item.sugar),
                              if (item.extras.isNotEmpty)
                                ...item.extras.map((ex) => _buildSpecChip(ex)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 6),

            // Structured Metadata Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLow(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _buildMetaRow(Icons.person_outline, 'صاحب الطلب:', _activeOrder.customerName),
                  const SizedBox(height: 8),
                  _buildMetaRow(Icons.storefront_outlined, 'فرع الاستلام:', _activeOrder.branch),
                  const SizedBox(height: 8),
                  _buildMetaRow(Icons.local_shipping_outlined, 'نوع الاستلام:', _activeOrder.pickupType),
                  const SizedBox(height: 8),
                  _buildMetaRow(Icons.credit_card_outlined, 'وسيلة الدفع:', _activeOrder.paymentMethod),
                  Divider(height: 20, color: AppTheme.divider(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المجموع الإجمالي:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textHeading(context),
                        ),
                      ),
                      Text(
                        '${_activeOrder.totalAmount.toStringAsFixed(0)} ر.ي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent(context),
                        ),
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
  }

  Widget _buildCompletedStateView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 64, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 16),
          Text(
            'صحة وعافية! تم استلام طلبك ☕',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textHeading(context),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'كود الطلب: ${_activeOrder.orderCode} • إعداد الباريستا: ${_activeOrder.baristaName}\nنتمنى لك تجربة قهوة استثنائية!',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(context),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          _buildOrderSummaryCard(),
          const SizedBox(height: 24),
          SizedBox(
            width: 240,
            child: CustomButton(
              text: 'اطلب قهوة جديدة',
              icon: Icons.local_cafe_outlined,
              onPressed: widget.onNavigateToOrder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.textSecondary(context),
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary(context)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary(context)),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.textHeading(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsTray(bool isReady) {
    return Column(
      children: [
        CustomButton(
          text: isReady ? 'تأكيد استلام الكوب والاستمتاع به' : 'تم الاستلام - اضغط للتأكيد',
          icon: Icons.check_circle_outline,
          variant: isReady ? ButtonVariant.tertiary : ButtonVariant.primary,
          onPressed: _confirmPicked,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'اتصل بالكافيه',
                icon: Icons.call_outlined,
                variant: ButtonVariant.secondary,
                height: 46,
                onPressed: () => _showToast('الاتصال بفرع الأصبحي - صنعاء: 9671500000+'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: 'إلغاء الطلب',
                icon: Icons.cancel_outlined,
                variant: ButtonVariant.danger,
                height: 46,
                onPressed: (_activeOrder.status == OrderStatus.cancelled ||
                        _activeOrder.status == OrderStatus.completed)
                    ? null
                    : _showCancelModal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonLoadingView() {
    return Column(
      children: [
        _buildSkeletonCard(height: 220),
        const SizedBox(height: 14),
        _buildSkeletonCard(height: 150),
        const SizedBox(height: 14),
        _buildSkeletonCard(height: 180),
      ],
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.accent(context).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLow(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.coffee_outlined, size: 70, color: AppTheme.accent(context)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد طلبات جارية حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textHeading(context),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'كوبك المفضل بانتظارك! ابدأ طلب قهوتك المختصة المحمصة طازجاً وسنحضرها فوراً.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary(context),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 240,
            child: CustomButton(
              text: 'اطلب قهوتك الآن',
              icon: Icons.local_cafe_outlined,
              onPressed: widget.onNavigateToOrder ??
                  () {
                    setState(() {
                      _currentViewState = TrackingViewState.inPrep;
                      _activeOrder.status = OrderStatus.inPrep;
                    });
                  },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledStateView() {
    final reason = _activeOrder.cancelReason ?? 'بدون سبب محدد';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppTheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_rounded, size: 60, color: AppTheme.error),
          ),
          const SizedBox(height: 20),
          const Text(
            'تم إلغاء الطلب',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.error,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppTheme.error),
                    const SizedBox(width: 6),
                    const Text(
                      'سبب الإلغاء',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.error,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textHeading(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 15, color: AppTheme.textSecondary(context)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'تم إرجاع ${_activeOrder.totalAmount.toStringAsFixed(0)} ر.ي إلى وسيلة الدفع خلال 24 ساعة.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary(context),
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 240,
            child: CustomButton(
              text: 'اطلب قهوتك مجدداً',
              icon: Icons.local_cafe_outlined,
              onPressed: widget.onNavigateToOrder ??
                  () {
                    setState(() {
                      _currentViewState = TrackingViewState.inPrep;
                      _activeOrder.status = OrderStatus.inPrep;
                      _activeOrder.cancelReason = null;
                    });
                  },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painters for Animated Coffee Cup, QR Code & Barcode
// ---------------------------------------------------------------------------

class CoffeeCupPainter extends CustomPainter {
  final double progress;
  final double steamPhase;
  final bool isReady;

  CoffeeCupPainter({
    required this.progress,
    required this.steamPhase,
    required this.isReady,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);

    // Cup Shadow
    final shadowPaint = Paint()..color = const Color(0x152C160D);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 46), width: 90, height: 14),
      shadowPaint,
    );

    // Handle
    final handlePaint = Paint()
      ..color = const Color(0xFFB68A65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final handlePath = Path();
    handlePath.moveTo(center.dx + 36, center.dy - 16);
    handlePath.cubicTo(
      center.dx + 65, center.dy - 16,
      center.dx + 65, center.dy + 26,
      center.dx + 34, center.dy + 26,
    );
    canvas.drawPath(handlePath, handlePaint);

    // Ceramic Cup Body
    final cupPath = Path();
    cupPath.moveTo(center.dx - 40, center.dy - 25);
    cupPath.lineTo(center.dx - 30, center.dy + 38);
    cupPath.quadraticBezierTo(center.dx - 28, center.dy + 45, center.dx, center.dy + 45);
    cupPath.quadraticBezierTo(center.dx + 28, center.dy + 45, center.dx + 30, center.dy + 38);
    cupPath.lineTo(center.dx + 40, center.dy - 25);
    cupPath.close();

    final cupPaint = Paint()..color = Colors.white;
    canvas.drawPath(cupPath, cupPaint);

    // Ceramic outline/gradient
    final outlinePaint = Paint()
      ..color = const Color(0xFFD4C3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(cupPath, outlinePaint);

    // Coffee Liquid Inside (Clipped to cup inner)
    canvas.save();
    canvas.clipPath(cupPath);

    final liquidHeight = 65 * progress;
    final liquidTop = (center.dy + 45) - liquidHeight;

    final liquidPaint = Paint()..color = const Color(0xFF7C5635);
    canvas.drawRect(
      Rect.fromLTRB(center.dx - 45, liquidTop, center.dx + 45, center.dy + 50),
      liquidPaint,
    );

    // Liquid surface ellipse (Foam / Crema)
    final cremaPaint = Paint()..color = const Color(0xFFB68A65);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, liquidTop), width: 62 * progress, height: 10),
      cremaPaint,
    );

    // Crema swirls
    final swirlPaint = Paint()
      ..color = const Color(0xFFFFDCC1).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 8, liquidTop + 1), 3, swirlPaint);
    canvas.drawCircle(Offset(center.dx + 10, liquidTop - 1), 2.5, swirlPaint);

    canvas.restore();

    // Cup Rim
    final rimPaint = Paint()
      ..color = const Color(0xFFFAF5F0)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 25), width: 80, height: 14),
      rimPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 25), width: 80, height: 14),
      outlinePaint,
    );

    // Steam micro-animation
    final steamPaint = Paint()
      ..color = const Color(0xFFB68A65).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final double offsetX = (i - 1) * 14.0;
      final double offsetY = (steamPhase * 10) + (i * 4);
      final steamPath = Path();
      steamPath.moveTo(center.dx + offsetX, center.dy - 35 - offsetY);
      steamPath.quadraticBezierTo(
        center.dx + offsetX + (i.isEven ? 5 : -5),
        center.dy - 50 - offsetY,
        center.dx + offsetX,
        center.dy - 65 - offsetY,
      );
      canvas.drawPath(steamPath, steamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CoffeeCupPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.steamPhase != steamPhase ||
        oldDelegate.isReady != isReady;
  }
}

class QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()..color = const Color(0xFF2C160D);
    final accentPaint = Paint()..color = const Color(0xFF7C5635);

    // Corner Finder Patterns
    _drawFinderPattern(canvas, const Offset(10, 10), darkPaint, accentPaint);
    _drawFinderPattern(canvas, Offset(size.width - 44, 10), darkPaint, accentPaint);
    _drawFinderPattern(canvas, Offset(10, size.height - 44), darkPaint, accentPaint);

    // Simulated QR Data Modules
    final List<Rect> darkBlocks = [
      Rect.fromLTWH(size.width * 0.45, 12, 10, 10),
      Rect.fromLTWH(size.width * 0.58, 20, 8, 14),
      Rect.fromLTWH(size.width * 0.45, 34, 14, 8),
      Rect.fromLTWH(14, size.height * 0.45, 12, 12),
      Rect.fromLTWH(34, size.height * 0.48, 16, 8),
      Rect.fromLTWH(size.width * 0.70, size.height * 0.44, 12, 14),
      Rect.fromLTWH(size.width * 0.82, size.height * 0.48, 14, 8),
      Rect.fromLTWH(size.width * 0.45, size.height * 0.72, 10, 14),
      Rect.fromLTWH(size.width * 0.60, size.height * 0.76, 16, 10),
      Rect.fromLTWH(size.width * 0.76, size.height * 0.70, 12, 12),
    ];

    for (var block in darkBlocks) {
      canvas.drawRRect(RRect.fromRectAndRadius(block, const Radius.circular(2)), darkPaint);
    }

    final List<Rect> accentBlocks = [
      Rect.fromLTWH(size.width * 0.55, 12, 12, 8),
      Rect.fromLTWH(30, size.height * 0.42, 12, 12),
      Rect.fromLTWH(size.width * 0.50, size.height * 0.58, 14, 8),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.72, 8, 16),
    ];

    for (var block in accentBlocks) {
      canvas.drawRRect(RRect.fromRectAndRadius(block, const Radius.circular(2)), accentPaint);
    }

    // Center Coffee Bean Logo in QR
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 14, Paint()..color = const Color(0xFFFFF8F6));
    canvas.drawCircle(center, 12, Paint()..color = const Color(0xFF7C5635));

    final beanPath = Path();
    beanPath.moveTo(center.dx - 2, center.dy - 6);
    beanPath.cubicTo(
      center.dx + 4, center.dy - 2,
      center.dx - 4, center.dy + 2,
      center.dx + 2, center.dy + 6,
    );
    canvas.drawPath(
      beanPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawFinderPattern(Canvas canvas, Offset offset, Paint darkPaint, Paint accentPaint) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(offset.dx, offset.dy, 34, 34), const Radius.circular(6)),
      darkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(offset.dx + 5, offset.dy + 5, 24, 24), const Radius.circular(4)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(offset.dx + 9, offset.dy + 9, 16, 16), const Radius.circular(3)),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarcodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2C160D);
    final widths = [3.0, 1.0, 2.0, 1.0, 4.0, 2.0, 1.0, 3.0, 1.0, 2.0, 4.0, 1.0, 2.0, 1.0, 3.0, 2.0];
    double x = 4;
    for (var w in widths) {
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      x += w + 4;
      if (x > size.width - 8) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
