import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_parent_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderNotifications = true;
  bool _soundChime = true;
  bool _hapticFeedback = true;

  String _selectedBranch = 'صنعاء • حي الأصبحي';
  String _selectedPickup = 'استلام فوري من الفرع';
  String _selectedPayment = 'محفظة جوال (كريمي / فلوسي)';
  String _defaultMilk = 'حليب شوفان';
  String _defaultTemp = 'ساخن ♨️';
  String _defaultSugar = 'بدون سكر';

  static const _kBranch   = 'pref_branch';
  static const _kPickup   = 'pref_pickup';
  static const _kPayment  = 'pref_payment';
  static const _kMilk     = 'pref_milk';
  static const _kTemp     = 'pref_temp';
  static const _kSugar    = 'pref_sugar';
  static const _kNotif    = 'pref_notif';
  static const _kSound    = 'pref_sound';
  static const _kHaptic   = 'pref_haptic';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedBranch   = p.getString(_kBranch)   ?? _selectedBranch;
      _selectedPickup   = p.getString(_kPickup)   ?? _selectedPickup;
      _selectedPayment  = p.getString(_kPayment)  ?? _selectedPayment;
      _defaultMilk      = p.getString(_kMilk)     ?? _defaultMilk;
      _defaultTemp      = p.getString(_kTemp)      ?? _defaultTemp;
      _defaultSugar     = p.getString(_kSugar)     ?? _defaultSugar;
      _orderNotifications = p.getBool(_kNotif)    ?? _orderNotifications;
      _soundChime       = p.getBool(_kSound)       ?? _soundChime;
      _hapticFeedback   = p.getBool(_kHaptic)     ?? _hapticFeedback;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBranch,  _selectedBranch);
    await p.setString(_kPickup,  _selectedPickup);
    await p.setString(_kPayment, _selectedPayment);
    await p.setString(_kMilk,    _defaultMilk);
    await p.setString(_kTemp,    _defaultTemp);
    await p.setString(_kSugar,   _defaultSugar);
    await p.setBool(_kNotif,     _orderNotifications);
    await p.setBool(_kSound,     _soundChime);
    await p.setBool(_kHaptic,    _hapticFeedback);
  }
  void _showToast(String message) {
    if (_hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    final isDark = AppTheme.isDark(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? const Color(0xFF1E0F0A) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.accent(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showBranchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          backgroundColor: AppTheme.cardBg(context),
          title: Text(
            'اختر فرع المحمصة المفضل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textHeading(context),
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          children: [
            _buildBranchOption('صنعاء • حي الأصبحي', 'الفرع الرئيسي والمحمصة الحِرفية', ctx),
            _buildBranchOption('صنعاء • شارع حدة', 'محطة استلام سريع وطلبات سيارة', ctx),
            _buildBranchOption('عدن • خور مكسر', 'مقهى ومختبر استخلاص V60', ctx),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchOption(String branch, String desc, BuildContext ctx) {
    final isSelected = _selectedBranch == branch;
    return SimpleDialogOption(
      onPressed: () {
        setState(() => _selectedBranch = branch);
        Navigator.pop(ctx);
        _savePrefs();
        _showToast('تم تعيين الفرع المفضل: $branch');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppTheme.accent(context) : AppTheme.textHeading(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ],
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 20, color: AppTheme.accent(context)),
          ],
        ),
      ),
    );
  }

  void _showPickupDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          backgroundColor: AppTheme.cardBg(context),
          title: Text(
            'طريقة الاستلام المفضلة تلقائياً',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textHeading(context),
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                setState(() => _selectedPickup = 'استلام فوري من الفرع');
                Navigator.pop(ctx);
                _savePrefs();
                _showToast('تم ضبط الاستلام الافتراضي: من الفرع');
              },
              child: Row(
                children: [
                  Icon(Icons.storefront, color: AppTheme.accent(context), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'استلام فوري من شباك الفرع',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary(context),
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() => _selectedPickup = 'تحضير وتسليم بالسيارة');
                Navigator.pop(ctx);
                _savePrefs();
                _showToast('تم ضبط الاستلام الافتراضي: في السيارة');
              },
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: AppTheme.accent(context), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'تسليم عند باب السيارة (Drive-thru)',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary(context),
                      fontFamily: 'IBM Plex Sans Arabic',
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

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          backgroundColor: AppTheme.cardBg(context),
          title: Text(
            'وسيلة الدفع الافتراضية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textHeading(context),
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                setState(() => _selectedPayment = 'محفظة جوال (كريمي إكسبرس / فلوسي)');
                Navigator.pop(ctx);
                _savePrefs();
                _showToast('تم تعيين: محفظة جوال (كريمي / فلوسي)');
              },
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: AppTheme.accent(context), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'محفظة جوال (كريمي إكسبرس • فلوسي • جوال باي)',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary(context),
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() => _selectedPayment = 'بطاقة بنكية / فيزا');
                Navigator.pop(ctx);
                _savePrefs();
                _showToast('تم تعيين: بطاقة بنكية / فيزا');
              },
              child: Row(
                children: [
                  Icon(Icons.credit_card, color: AppTheme.accent(context), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'بطاقة بنكية (Visa • Mastercard)',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary(context),
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() => _selectedPayment = 'نقداً عند الاستلام');
                Navigator.pop(ctx);
                _savePrefs();
                _showToast('تم تعيين: الدفع نقداً عند الاستلام');
              },
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: Color(0xFF226B42), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'نقداً عند شباك الاستلام (كاش)',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary(context),
                      fontFamily: 'IBM Plex Sans Arabic',
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

  void _showCoffeeTasteDialog() {
    String temp = _defaultTemp;
    String milk = _defaultMilk;
    String sugar = _defaultSugar;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'تفضيلات مذاق قهوتك الافتراضية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'الحرارة المفضلة:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['ساخن ♨️', 'مثلج 🧊'].map((t) {
                    final isSel = temp == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSel,
                      onSelected: (val) => setModalState(() => temp = t),
                      selectedColor: AppTheme.chipSelectedBg(context),
                      backgroundColor: AppTheme.chipBg(context),
                      labelStyle: TextStyle(
                        color: isSel ? AppTheme.chipSelectedText(context) : AppTheme.textPrimary(context),
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'نوع الحليب:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['حليب شوفان', 'حليب لوز', 'حليب كامل الدسم', 'بدون حليب'].map((m) {
                    final isSel = milk == m;
                    return ChoiceChip(
                      label: Text(m),
                      selected: isSel,
                      onSelected: (val) => setModalState(() => milk = m),
                      selectedColor: AppTheme.chipSelectedBg(context),
                      backgroundColor: AppTheme.chipBg(context),
                      labelStyle: TextStyle(
                        color: isSel ? AppTheme.chipSelectedText(context) : AppTheme.textPrimary(context),
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'درجة السكر:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textHeading(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['بدون سكر', 'سكر خفيف', 'سكر وسط', 'سكر زيادة'].map((s) {
                    final isSel = sugar == s;
                    return ChoiceChip(
                      label: Text(s),
                      selected: isSel,
                      onSelected: (val) => setModalState(() => sugar = s),
                      selectedColor: AppTheme.chipSelectedBg(context),
                      backgroundColor: AppTheme.chipBg(context),
                      labelStyle: TextStyle(
                        color: isSel ? AppTheme.chipSelectedText(context) : AppTheme.textPrimary(context),
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent(context),
                      foregroundColor: AppTheme.isDark(context) ? const Color(0xFF1E0F0A) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      setState(() {
                        _defaultTemp = temp;
                        _defaultMilk = milk;
                        _defaultSugar = sugar;
                      });
                      Navigator.pop(ctx);
                      _savePrefs();
                      _showToast('تم حفظ تفضيلات المذاق الافتراضية بنجاح ☕');
                    },
                    child: const Text('حفظ التفضيلات الافتراضية', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  void _showRoasteryStoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: AppTheme.cardBg(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.isDark(context) ? const Color(0xFF1E1E1E) : const Color(0xFF5D4037),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.coffee, color: AppTheme.accent(context)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'محمصة رُكـن • ROKON',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHeading(context),
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                        Text(
                          'ثقافة القهوة المختصة الحِرفية',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.accent(context),
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(height: 24, color: AppTheme.divider(context)),
                Text(
                  'انطلقت محمصة «رُكـن» بشغف لا ينتهي باكتشاف أندر محاصيل البن العربي والإفريقي واللاتيني. نقوم بانتقاء حبوب كرز البن المحصودة يدوياً على ارتفاعات تفوق 2,150 متراً فوق سطح البحر، ونحمصها أسبوعياً بدرجات تحميص حِرفية تبرز النوتات العطرية والفاكهية دون مرارة زائدة.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppTheme.textSecondary(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium, color: AppTheme.accent(context), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'محصول اليوم: إثيوبيا يرقاتشيف & ركن قيدب V60 مجفف لاهوائي',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHeading(context),
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent(context),
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHoursDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SimpleDialog(
          backgroundColor: AppTheme.cardBg(context),
          title: Text(
            'أوقات العمل واستقبال الطلبات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textHeading(context),
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• السبت إلى الخميس: ٦:٠٠ صباحاً - ١٢:٠٠ منتصف الليل',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary(context),
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• يوم الجمعة: ١:٠٠ ظهراً - ١:٠٠ بعد منتصف الليل',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.textPrimary(context),
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الفرع مفتوح الآن ويستقبل الطلبات الفورية بنشاط ☕✨',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF226B42),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
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

  void _showRatingDialog() {
    int rating = 5;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setRatingState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppTheme.cardBg(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'تقييم تجربتك في رُكـن',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textHeading(context),
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'رأيك يسهم في تطوير كل رشفة قهوة نحضرها لك:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFFFB800),
                        size: 36,
                      ),
                      onPressed: () => setRatingState(() => rating = index + 1),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'لاحقاً',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent(context),
                  foregroundColor: AppTheme.isDark(context) ? const Color(0xFF1E0F0A) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showToast('شكراً لتقييمك الراقي! سعداء بخدمتك دائماً 🌟');
                },
                child: const Text(
                  'إرسال التقييم',
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return CustomParentWidget(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppTheme.textHeading(context),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'تفضيلات التطبيق والمحمصة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textHeading(context),
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEBE6DC),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Roastery Brand Banner (No profile / No login)
            _buildRoasteryBrandCard(),
            const SizedBox(height: 16),

            // Branch & Service Preferences
            _buildSectionHeader('تفضيلات الاستلام والفرع'),
            const SizedBox(height: 8),
            _buildSettingsContainer([
              _buildSettingTile(
                icon: Icons.storefront_outlined,
                title: 'فرع المحمصة المفضل',
                subtitle: _selectedBranch,
                onTap: _showBranchDialog,
                trailing: Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.textSecondary(context)),
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSettingTile(
                icon: Icons.directions_car_outlined,
                title: 'طريقة الاستلام المفضلة',
                subtitle: _selectedPickup,
                onTap: _showPickupDialog,
                trailing: Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.textSecondary(context)),
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSettingTile(
                icon: Icons.credit_card_outlined,
                title: 'طريقة الدفع الافتراضية',
                subtitle: _selectedPayment,
                onTap: _showPaymentDialog,
                trailing: Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.textSecondary(context)),
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSettingTile(
                icon: Icons.coffee_outlined,
                title: 'مذاق القهوة الافتراضي',
                subtitle: '$_defaultTemp • $_defaultMilk • $_defaultSugar',
                onTap: _showCoffeeTasteDialog,
                trailing: Icon(Icons.tune, size: 16, color: AppTheme.accent(context)),
              ),
            ]),
            const SizedBox(height: 16),

            // App Behavior & Feedback
            _buildSectionHeader('إعدادات التطبيق والمظهر'),
            const SizedBox(height: 8),
            _buildSettingsContainer([
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'الوضع الداكن (Dark Mode)',
                subtitle: 'مظهر ليلي مريح للعين',
                value: isDark,
                onChanged: (val) {
                  ThemeController.themeMode.value = val ? ThemeMode.dark : ThemeMode.light;
                  _showToast(val ? 'تم تفعيل الوضع الداكن 🌙' : 'تم تفعيل الوضع الفاتح ☀️');
                },
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: 'جرس جاهزية القهوة الصوتي',
                subtitle: 'نغمة هادئة فور اكتمال صب الكوب',
                value: _soundChime,
                onChanged: (val) {
                  setState(() => _soundChime = val);
                  _savePrefs();
                },
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'التفاعل الحركي (Haptic Feedback)',
                subtitle: 'اهتزاز لطيف عند النقر على الأزرار',
                value: _hapticFeedback,
                onChanged: (val) {
                  setState(() => _hapticFeedback = val);
                  _savePrefs();
                },
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSwitchTile(
                icon: Icons.coffee_maker_outlined,
                title: 'إشعارات التحضير الحية',
                subtitle: 'متابعة مراحل الاستخلاص والطحن مباشرة',
                value: _orderNotifications,
                onChanged: (val) {
                  setState(() => _orderNotifications = val);
                  _savePrefs();
                },
              ),
            ]),
            const SizedBox(height: 16),

            // Roastery & Specialty Coffee Story
            _buildSectionHeader('عن محمصة رُكـن للقهوة المختصة'),
            const SizedBox(height: 8),
            _buildSettingsContainer([
              _buildSettingTile(
                icon: Icons.menu_book_outlined,
                title: 'قصة رُكـن ومحاصيلنا المختصة',
                subtitle: 'رحلة البن من مزارع الارتفاعات العالية حتى الكوب',
                onTap: _showRoasteryStoryDialog,
                trailing: Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.textSecondary(context)),
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSettingTile(
                icon: Icons.access_time_outlined,
                title: 'ساعات العمل وأوقات الذروة',
                subtitle: 'يومياً من ٦:٠٠ ص حتى ١٢:٠٠ م',
                onTap: _showHoursDialog,
                trailing: Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.textSecondary(context)),
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSettingTile(
                icon: Icons.star_rate_outlined,
                title: 'تقييم تجربة القهوة',
                subtitle: 'شاركنا انطباعك عن مذاق وسرعة التحضير',
                onTap: _showRatingDialog,
                trailing: Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.textSecondary(context)),
              ),
              Divider(height: 1, indent: 48, color: AppTheme.divider(context)),
              _buildSettingTile(
                icon: Icons.chat_bubble_outline,
                title: 'خدمة العملاء ومحادثة الباريستا',
                subtitle: 'واتساب مباشر: +967 770 000 000',
                onTap: () => _showToast('جاري فتح محادثة الدعم على واتساب...'),
                trailing: Icon(Icons.arrow_back_ios_new, size: 14, color: AppTheme.textSecondary(context)),
              ),
            ]),
            const SizedBox(height: 16),

            // Footer Version Info
            Center(
              child: Column(
                children: [
                  Text(
                    'رُكـن للقهوة المختصة • ROKON Coffee v1.0.0+1',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'تطبيق سريع وطلب فوري بدون الحاجة لحساب أو تسجيل',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.accent(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRoasteryBrandCard() {
    final isDark = AppTheme.isDark(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorder(context)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF35231D).withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF5D4037),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFFD4A373).withValues(alpha: 0.15)
                          : const Color(0xFF5D4037).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.coffee, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رُكـن للقهوة المختصة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textHeading(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ROKON SPECIALTY ROASTERS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: AppTheme.accent(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'تحميص حِرفي مباشر، واختيار دقيق لأجود المحاصيل من إثيوبيا والسلفادور واليمن مع استخلاص يدوي متقن لكل كوب.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.chipBg(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, size: 15, color: AppTheme.accent(context)),
                const SizedBox(width: 6),
                Text(
                  'طلب فوري سريع متاح للجميع • بدون تسجيل أو حساب',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.accent(context),
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: AppTheme.cardBg(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.cardBorder(context)),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppTheme.accent(context)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppTheme.textHeading(context),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                color: AppTheme.textSecondary(context),
              ),
            )
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLow(context),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppTheme.accent(context)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppTheme.textHeading(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.5,
          color: AppTheme.textSecondary(context),
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: AppTheme.accent(context),
        onChanged: onChanged,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }
}
