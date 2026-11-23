import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/order_model.dart';
import '../data/mock_data.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_parent_widget.dart';

class CreateOrderScreen extends StatefulWidget {
  final Function(OrderModel) onOrderPlaced;

  const CreateOrderScreen({
    super.key,
    required this.onOrderPlaced,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  String _selectedCategory = 'all';
  String _pickupType = 'branch'; // 'branch' or 'car'
  final TextEditingController _cupNameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _nameHasError = false;

  // Customizations per coffee item ID
  final Map<String, OrderItem> _customizedItems = {};

  // Quantities for each coffee item ID - all default to 0 (cart is initially empty)
  final Map<String, int> _itemQuantities = {
    'p0': 0, // V60
    'p1': 0, // Spanish Latte
    'p2': 0, // Cappuccino
    'p3': 0, // Flat White
    'p4': 0, // Americano
    'p5': 0, // Iced Latte Español
    'p6': 0, // Daily V60
  };

  bool _isSubmitting = false;
  List<CoffeeItem> _coffeeList = MockData.coffeeMenu;

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'الكل (٨)'},
    {'id': 'espresso', 'label': 'إسبريسو'},
    {'id': 'milk', 'label': 'مشروبات بالحليب'},
    {'id': 'pour', 'label': 'قهوة مقطرة'},
    {'id': 'cold', 'label': 'بارد منعش'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    try {
      final prods = await SupabaseService().getProducts();
      final cats = await SupabaseService().getCategories();
      if (mounted) {
        setState(() {
          if (prods.isNotEmpty) {
            _coffeeList = prods;
          }
          if (cats.isNotEmpty) {
            _categories.clear();
            _categories.add({'id': 'all', 'label': 'الكل (${_menu.length})'});
            for (final c in cats) {
              final nameAr = c['name_ar']?.toString() ?? '';
              _categories.add({
                'id': nameAr,
                'label': nameAr,
              });
            }
          }
        });
      }
    } catch (_) {}
  }

  List<CoffeeItem> get _menu =>
      _coffeeList.isNotEmpty ? _coffeeList : MockData.coffeeMenu;

  @override
  void dispose() {
    _cupNameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  int _getQty(String id) => _itemQuantities[id] ?? 0;

  void _increment(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      final newQty = (_itemQuantities[id] ?? 0) + 1;
      _itemQuantities[id] = newQty;
      if (_customizedItems.containsKey(id)) {
        _customizedItems[id] = _customizedItems[id]!.copyWith(quantity: newQty);
      }
    });
  }

  void _decrement(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      final current = _itemQuantities[id] ?? 0;
      if (current > 0) {
        final newQty = current - 1;
        _itemQuantities[id] = newQty;
        if (newQty == 0) {
          _customizedItems.remove(id);
        } else if (_customizedItems.containsKey(id)) {
          _customizedItems[id] = _customizedItems[id]!.copyWith(quantity: newQty);
        }
      }
    });
  }

  String _getEnglishName(String id) {
    switch (id) {
      case 'p0':
        return 'V60 Drip';
      case 'p1':
        return 'Spanish Latte';
      case 'p2':
        return 'Cappuccino';
      case 'p3':
        return 'Flat White';
      case 'p4':
        return 'Americano';
      case 'p5':
        return 'Iced Latte Español';
      case 'p6':
        return 'Daily V60 Drip';
      default:
        final found = _menu.where((c) => c.id == id).firstOrNull;
        return found != null ? found.name : 'Specialty Coffee';
    }
  }

  void _openCustomizeModal(String coffeeId) {
    final coffee = _menu.firstWhere(
      (c) => c.id == coffeeId,
      orElse: () => _menu.first,
    );

    String selectedTemp = 'ساخن ♨️';
    String selectedSize = coffee.availableSizes.isNotEmpty
        ? coffee.availableSizes[1]
        : 'وسط (M)';
    String selectedMilk =
        coffee.milkOptions.isNotEmpty ? coffee.milkOptions[0] : 'حليب شوفان';
    String selectedSugar = 'بدون سكر';
    final Set<String> selectedExtras = {};
    int modalQuantity = (_itemQuantities[coffeeId] ?? 0) > 0
        ? _itemQuantities[coffeeId]!
        : 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = AppTheme.isDark(context);
            double extraPrice = 0;
            if (selectedExtras.contains('شوت إضافي')) extraPrice += 400;
            if (selectedExtras.contains('كراميل')) extraPrice += 300;
            if (selectedExtras.contains('فانيلا')) extraPrice += 300;

            final double itemPrice = coffee.price + extraPrice;
            final double totalPrice = itemPrice * modalQuantity;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sheet Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppTheme.cardBorder(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Header Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: coffee.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 72,
                                height: 72,
                                color: AppTheme.surfaceLow(context),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 72,
                                height: 72,
                                color: AppTheme.surfaceLow(context),
                                child: Icon(Icons.coffee,
                                    color: AppTheme.accent(context), size: 36),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        coffee.name,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textHeading(context),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.chipBg(context),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        coffee.category,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.accent(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${coffee.price.toStringAsFixed(0)} ر.ي',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accent(context),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  coffee.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 24, color: AppTheme.divider(context)),

                      // Scrollable options
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Temperature (Hot / Iced)
                              Text(
                                'درجة الحرارة',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHeading(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: ['ساخن ♨️', 'مثلج 🧊'].map((temp) {
                                  final isSelected = selectedTemp == temp;
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ChoiceChip(
                                      label: Text(temp),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setModalState(
                                              () => selectedTemp = temp);
                                        }
                                      },
                                      selectedColor: AppTheme.chipSelectedBg(context),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? AppTheme.chipSelectedText(context)
                                            : AppTheme.textSecondary(context),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 12.5,
                                      ),
                                      backgroundColor:
                                          AppTheme.chipBg(context),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? Colors.transparent
                                              : AppTheme.chipBorder(context),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // Size Selection
                              Text(
                                'الحجم',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHeading(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: coffee.availableSizes.map((size) {
                                  final isSelected = selectedSize == size;
                                  return ChoiceChip(
                                    label: Text(size),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setModalState(
                                            () => selectedSize = size);
                                      }
                                    },
                                    selectedColor: AppTheme.chipSelectedBg(context),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppTheme.chipSelectedText(context)
                                          : AppTheme.textSecondary(context),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12.5,
                                    ),
                                    backgroundColor:
                                        AppTheme.chipBg(context),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppTheme.chipBorder(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // Milk Selection
                              Text(
                                'نوع الحليب',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHeading(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: coffee.milkOptions.map((milk) {
                                  final isSelected = selectedMilk == milk;
                                  return ChoiceChip(
                                    label: Text(milk),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setModalState(
                                            () => selectedMilk = milk);
                                      }
                                    },
                                    selectedColor: AppTheme.chipSelectedBg(context),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppTheme.chipSelectedText(context)
                                          : AppTheme.textSecondary(context),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12.5,
                                    ),
                                    backgroundColor:
                                        AppTheme.chipBg(context),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppTheme.chipBorder(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // Sugar Selection
                              Text(
                                'درجة السكر',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHeading(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  'بدون سكر',
                                  'سكر خفيف',
                                  'سكر وسط',
                                  'سكر زيادة'
                                ].map((sugar) {
                                  final isSelected = selectedSugar == sugar;
                                  return ChoiceChip(
                                    label: Text(sugar),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setModalState(
                                            () => selectedSugar = sugar);
                                      }
                                    },
                                    selectedColor: AppTheme.chipSelectedBg(context),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppTheme.chipSelectedText(context)
                                          : AppTheme.textSecondary(context),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12.5,
                                    ),
                                    backgroundColor:
                                        AppTheme.chipBg(context),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppTheme.chipBorder(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),

                              // Extra Add-ons
                              Text(
                                'إضافات مميزة',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHeading(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  {'key': 'شوت إضافي', 'label': 'شوت إضافي (+400)'},
                                  {'key': 'كراميل', 'label': 'كراميل صوص (+300)'},
                                  {'key': 'فانيلا', 'label': 'سيروب فانيلا (+300)'},
                                ].map((extra) {
                                  final key = extra['key']!;
                                  final isSelected =
                                      selectedExtras.contains(key);
                                  return FilterChip(
                                    label: Text(extra['label']!),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setModalState(() {
                                        if (selected) {
                                          selectedExtras.add(key);
                                        } else {
                                          selectedExtras.remove(key);
                                        }
                                      });
                                    },
                                    selectedColor: isDark
                                        ? const Color(0xFF5A311B)
                                        : AppTheme.secondaryContainer,
                                    checkmarkColor: AppTheme.accent(context),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? (isDark ? Colors.white : AppTheme.primary)
                                          : AppTheme.textSecondary(context),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                    backgroundColor:
                                        AppTheme.chipBg(context),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppTheme.chipBorder(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quantity Stepper and Add to Order Button
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.stepperBg(context),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, size: 18, color: AppTheme.textHeading(context)),
                                  onPressed: modalQuantity > 1
                                      ? () => setModalState(
                                          () => modalQuantity--)
                                      : null,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Text(
                                    '$modalQuantity',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textHeading(context),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, size: 18, color: AppTheme.textHeading(context)),
                                  onPressed: () => setModalState(
                                      () => modalQuantity++),
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Add Button
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent(context),
                                  foregroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  HapticFeedback.mediumImpact();
                                  setState(() {
                                    _itemQuantities[coffeeId] = modalQuantity;
                                    _customizedItems[coffeeId] = OrderItem(
                                      coffee: coffee,
                                      size: '$selectedSize ($selectedTemp)',
                                      milk: selectedMilk,
                                      sugar: selectedSugar,
                                      extras: selectedExtras.toList(),
                                      extraPrice: extraPrice,
                                      quantity: modalQuantity,
                                    );
                                  });
                                  final extrasTxt = selectedExtras.isNotEmpty
                                      ? ' • ${selectedExtras.join(', ')}'
                                      : '';
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded,
                                              color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'تمت إضافة "$modalQuantity × ${coffee.name}" ($selectedTemp • $selectedSize • $selectedMilk • $selectedSugar$extrasTxt)',
                                              style: const TextStyle(
                                                  fontFamily:
                                                      'IBM Plex Sans Arabic'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor:
                                          isDark ? const Color(0xFFD7B899) : AppTheme.outlineVariant,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'إضافة للطلب (${totalPrice.toStringAsFixed(0)} ر.ي)',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  double get _subtotal {
    double sum = 0;
    _itemQuantities.forEach((id, qty) {
      if (qty > 0) {
        if (_customizedItems.containsKey(id)) {
          sum += _customizedItems[id]!.totalPrice;
        } else {
          final item = _menu.firstWhere(
            (c) => c.id == id,
            orElse: () => _menu.first,
          );
          sum += item.price * qty;
        }
      }
    });
    return sum;
  }

  double get _grandTotal => _subtotal;

  int get _totalSelectedItemsCount {
    int count = 0;
    _itemQuantities.forEach((_, qty) => count += qty);
    return count;
  }

  void _handleConfirmOrder() {
    if (_totalSelectedItemsCount == 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'يرجى اختيار صنف قهوة واحد على الأقل للمتابعة',
                  style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    final enteredName = _cupNameController.text.trim();
    if (enteredName.isEmpty) {
      HapticFeedback.mediumImpact();
      setState(() => _nameHasError = true);
      _showCustomerNameRequiredSheet();
      return;
    }

    setState(() => _nameHasError = false);
    _executeOrderSubmission(enteredName);
  }

  void _showCustomerNameRequiredSheet() {
    final tempController = TextEditingController();
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = AppTheme.isDark(context);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBorder(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.chipBg(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_note_rounded,
                              color: AppTheme.accent(context), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اكتب اسمك الكريم على الكوب ☕',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textHeading(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'مطلوب لتدوينه بخط يدوي أنيق ومناداتك عند جاهزية الطلب',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tempController,
                      autofocus: true,
                      style: TextStyle(
                        color: AppTheme.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'أدخل اسمك هنا (مثال: عبدالله، سارة، محمد...)',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(Icons.person_outline,
                            color: AppTheme.accent(context)),
                        filled: true,
                        fillColor: AppTheme.surfaceLow(context),
                        errorText: localError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppTheme.chipBorder(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppTheme.chipBorder(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: AppTheme.accent(context), width: 1.5),
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().length >= 2) {
                          _cupNameController.text = val.trim();
                          setState(() => _nameHasError = false);
                          Navigator.pop(sheetCtx);
                          _executeOrderSubmission(val.trim());
                        } else {
                          setSheetState(() => localError = 'يرجى كتابة اسمك الكريم (حرفين على الأقل)');
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'أو اختر سريعاً:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['عبدالله', 'أحمد', 'محمد', 'سارة', 'نورة', 'ريان']
                          .map((name) => ActionChip(
                                label: Text(name),
                                labelStyle: TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textHeading(context),
                                ),
                                backgroundColor: AppTheme.chipBg(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: AppTheme.chipBorder(context)),
                                ),
                                onPressed: () {
                                  tempController.text = name;
                                  setSheetState(() => localError = null);
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent(context),
                          foregroundColor: isDark ? const Color(0xFF121212) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          final val = tempController.text.trim();
                          if (val.length >= 2) {
                            _cupNameController.text = val;
                            setState(() => _nameHasError = false);
                            Navigator.pop(sheetCtx);
                            _executeOrderSubmission(val);
                          } else {
                            setSheetState(() => localError = 'يرجى كتابة اسمك الكريم (حرفين على الأقل)');
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'تأكيد الاسم ومتابعة الطلب',
                              style: TextStyle(
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
              ),
            );
          },
        );
      },
    );
  }

  void _executeOrderSubmission(String customerName) {
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      // Construct ordered items
      final List<OrderItem> orderedItems = [];
      _itemQuantities.forEach((id, qty) {
        if (qty > 0) {
          final coffee = _menu.firstWhere(
            (c) => c.id == id,
            orElse: () => _menu.first,
          );
          if (_customizedItems.containsKey(id)) {
            orderedItems.add(_customizedItems[id]!.copyWith(quantity: qty));
          } else {
            orderedItems.add(
              OrderItem(
                coffee: coffee,
                quantity: qty,
                size: 'وسط (M)',
                milk: 'حليب شوفان',
                sugar: 'بدون سكر',
              ),
            );
          }
        }
      });

      final newOrder = OrderModel(
        id: '${DateTime.now().millisecondsSinceEpoch % 10000}',
        orderCode: 'RUK-${100 + (DateTime.now().second % 900)}',
        customerName: customerName,
        cupName: customerName,
        branch: _pickupType == 'branch'
            ? 'فرع الأصبحي - شارع المقالح، صنعاء'
            : 'استلام في السيارة - فرع الأصبحي، صنعاء',
        pickupType: _pickupType == 'branch'
            ? 'استلام فوري من الفرع'
            : 'تحضير في السيارة',
        paymentMethod: 'كريمي إكسبرس (دفع إلكتروني)',
        discount: 0.0,
        items: orderedItems,
        status: OrderStatus.received,
        createdAt: DateTime.now(),
        estimatedReadyTime: 'جاهز خلال ٥-٨ دقائق',
        baristaName: 'ريان اليماني',
        baristaRole: 'مختص تحضير V60 وإسبريسو',
        baristaAvatarUrl:
            'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=150&auto=format&fit=crop&q=80',
      );

      setState(() {
        _isSubmitting = false;
        // Clean cart reset after successful order
        _itemQuantities.updateAll((key, value) => 0);
        _customizedItems.clear();
      });

      widget.onOrderPlaced(newOrder);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomParentWidget(
      enableBottomSafeArea: false,
      appBar: CustomParentWidget.buildRokonAppBar(
        context: context,
        title: 'ركن • ROKON',
        subtitle: 'Order Coffee',
      ),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Scrollable Menu Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Editorial Intro
                _buildTopGreeting(),
                const SizedBox(height: 14),

                // Luxury Exclusive Coffee Hero Card (V60)
                _buildHeroCoffeeCard(),
                const SizedBox(height: 16),

                // Categories Pill Bar
                _buildCategoriesBar(),
                const SizedBox(height: 16),

                // Featured Coffee Products Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.coffee_maker,
                            size: 20, color: AppTheme.accent(context)),
                        const SizedBox(width: 8),
                        Text(
                          'المشروبات المختارة',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textHeading(context),
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'محضرة طازجة حسب الطلب',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary(context),
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Products List with interactive steppers and tap to customize
                ..._menu.where((item) {
                  final featured = _menu.firstWhere(
                    (c) => c.name.contains('V60') || c.category.contains('مقطرة'),
                    orElse: () => _menu.first,
                  );
                  if (item.id == featured.id) return false; // Already shown as Hero Card
                  if (_selectedCategory == 'all') return true;
                  return item.category.contains(_selectedCategory) ||
                      (_selectedCategory == 'espresso' && item.category.contains('إسبريسو')) ||
                      (_selectedCategory == 'milk' && item.category.contains('حليب')) ||
                      (_selectedCategory == 'pour' && item.category.contains('مقطرة')) ||
                      (_selectedCategory == 'cold' && item.category.contains('بارد'));
                }).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildProductItem(
                      id: item.id,
                      nameArabic: item.name,
                      nameEnglish: _getEnglishName(item.id),
                      desc: item.description,
                      price: item.price.toInt(),
                      imageUrl: item.imageUrl,
                      badge: item.category.contains('حليب') ? 'الأكثر طلباً' : null,
                    ),
                  );
                }),
                const SizedBox(height: 18),

                // Order Customization & Service Options
                _buildCustomizationSection(),
                const SizedBox(height: 16),

                // Order Summary Card (Invoice)
                _buildOrderSummaryCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Pinned Sticky Bottom Order Bar (زر الطلب الثابت على الشاشة)
          Positioned(
            left: 16,
            right: 16,
            bottom: 150,
            child: _buildStickyOrderBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.chipBg(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.accent(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'التحميص الحِرفي المباشر',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent(context),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'صنعاء • فرع الأصبحي - شارع المقالح',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'قهوتك تبدأ من هنا',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textHeading(context),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'اختر مزاجك اليوم من محاصيلنا المختصة المحمصة بعناية فائقة.',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCoffeeCard() {
    final featuredCoffee = _menu.firstWhere(
      (c) => c.name.contains('V60') || c.category.contains('مقطرة'),
      orElse: () => _menu.first,
    );
    final featuredId = featuredCoffee.id;
    final heroQty = _getQty(featuredId);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryContainer.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openCustomizeModal(featuredId),
          child: Stack(
            children: [
              // Background Coffee Image
              CachedNetworkImage(
                imageUrl: featuredCoffee.imageUrl.isNotEmpty
                    ? featuredCoffee.imageUrl
                    : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=700&auto=format&fit=crop&q=80',
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 230,
                  color: AppTheme.primaryContainer,
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 230,
                  color: AppTheme.primaryContainer,
                  child: const Icon(Icons.coffee, size: 60, color: Colors.white24),
                ),
              ),
              // Gradient Scrim
              Container(
                height: 230,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppTheme.primaryContainer,
                      AppTheme.primaryContainer.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Top Badges
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'قهوة اليوم • كمية محدودة',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        featuredCoffee.category,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Content
              Positioned(
                bottom: 12,
                right: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                featuredCoffee.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                featuredCoffee.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primaryFixedDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              featuredCoffee.price.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryContainer,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'ر.ي',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tasting Notes Tags & Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildHeroTag('قهوة مختصة'),
                              _buildHeroTag('استخلاص يدوي'),
                              _buildHeroTag('محصول طازج'),
                            ],
                          ),
                        ),
                        // Dedicated Customize Cup Button
                        InkWell(
                          onTap: () => _openCustomizeModal(featuredId),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.tune, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'تخصيص الكوب',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Quick add / count button
                        InkWell(
                          onTap: () => _increment(featuredId),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add,
                                    size: 15, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  heroQty > 0 ? '$heroQty' : 'أضف',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildHeroTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCategoriesBar() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['id'];
          return ChoiceChip(
            label: Text(cat['label']!),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedCategory = cat['id']!);
              }
            },
            selectedColor: AppTheme.chipSelectedBg(context),
            labelStyle: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppTheme.chipSelectedText(context)
                  : AppTheme.textSecondary(context),
            ),
            backgroundColor: AppTheme.chipBg(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : AppTheme.chipBorder(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductItem({
    required String id,
    required String nameArabic,
    required String nameEnglish,
    required String desc,
    required int price,
    required String imageUrl,
    String? badge,
  }) {
    final qty = _getQty(id);
    final isDark = AppTheme.isDark(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCustomizeModal(id),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.cardBorder(context)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF35231D).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image with optional badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 82,
                        height: 82,
                        color: AppTheme.surfaceLow(context),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 82,
                        height: 82,
                        color: AppTheme.surfaceLow(context),
                        child: Icon(Icons.coffee,
                            color: AppTheme.accent(context), size: 36),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accent(context),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF121212) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            nameArabic,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textHeading(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          nameEnglish,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textSecondary(context),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Price, Customize Button and Stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$price',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent(context),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'ر.ي',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary(context),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            // Quick Customize button
                            InkWell(
                              onTap: () => _openCustomizeModal(id),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.chipBg(context),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.tune,
                                        size: 13, color: AppTheme.accent(context)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'تخصيص',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accent(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Quantity Stepper
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppTheme.stepperBg(context),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  _buildStepperBtn(
                                    icon: Icons.remove,
                                    onTap: () => _decrement(id),
                                    isPrimary: false,
                                  ),
                                  SizedBox(
                                    width: 26,
                                    child: Text(
                                      '$qty',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textHeading(context),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  _buildStepperBtn(
                                    icon: Icons.add,
                                    onTap: () => _increment(id),
                                    isPrimary: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final isDark = AppTheme.isDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDark ? const Color(0xFFD4A373) : AppTheme.primaryContainer)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 15,
          color: isPrimary
              ? (isDark ? const Color(0xFF121212) : Colors.white)
              : AppTheme.textHeading(context),
        ),
      ),
    );
  }

  Widget _buildCustomizationSection() {
    final isDark = AppTheme.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, size: 20, color: AppTheme.accent(context)),
            const SizedBox(width: 8),
            Text(
              'تخصيص الطلب والاستلام',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textHeading(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Name on cup card (مطلوب كتابة الاسم)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _nameHasError ? AppTheme.error : AppTheme.cardBorder(context),
              width: _nameHasError ? 1.6 : 1.0,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: _nameHasError
                          ? AppTheme.error.withValues(alpha: 0.12)
                          : const Color(0xFF35231D).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note,
                          size: 18,
                          color: _nameHasError
                              ? AppTheme.error
                              : AppTheme.accent(context)),
                      const SizedBox(width: 6),
                      Text(
                        'اسمك على الكوب',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _nameHasError
                              ? AppTheme.error
                              : AppTheme.textHeading(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _nameHasError
                              ? AppTheme.errorContainer
                              : AppTheme.chipBg(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'مطلوب',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _nameHasError
                                ? AppTheme.error
                                : AppTheme.accent(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'خط عربي يدوي',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cupNameController,
                focusNode: _nameFocusNode,
                style: TextStyle(
                  color: AppTheme.textPrimary(context),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (val) {
                  if (_nameHasError && val.trim().isNotEmpty) {
                    setState(() => _nameHasError = false);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'أدخل اسمك الكريم (مثال: عبدالله، سارة...)',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary(context).withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(Icons.sentiment_satisfied,
                      size: 20,
                      color: _nameHasError ? AppTheme.error : AppTheme.accent(context)),
                  filled: true,
                  fillColor: AppTheme.surfaceLow(context),
                  errorText: _nameHasError ? 'يرجى كتابة اسمك الكريم لمتابعة الطلب' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _nameHasError ? AppTheme.error : AppTheme.accent(context),
                      width: 1.5,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Pickup Options
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.cardBorder(context)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF35231D).withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طريقة استلام القهوة',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textHeading(context),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPickupChip(
                      type: 'branch',
                      icon: Icons.storefront,
                      title: 'استلام فوري من الفرع',
                      subtitle: 'جاهز خلال ٥-٨ دقائق',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPickupChip(
                      type: 'car',
                      icon: Icons.directions_car,
                      title: 'تحضير في السيارة',
                      subtitle: 'التسليم عند باب موقفك',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickupChip({
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _pickupType == type;
    final isDark = AppTheme.isDark(context);

    return InkWell(
      onTap: () => setState(() => _pickupType = type),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E1E1E) : AppTheme.primaryContainer)
              : AppTheme.surfaceLow(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent(context)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? (isDark ? const Color(0xFFD4A373) : Colors.white)
                      : AppTheme.textSecondary(context),
                ),
                if (isSelected)
                  Icon(Icons.check_circle,
                      size: 16,
                      color: isDark ? const Color(0xFFD4A373) : Colors.white),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? const Color(0xFFD4A373) : Colors.white)
                    : AppTheme.textHeading(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? (isDark ? const Color(0xFFDEC0B7) : Colors.white70)
                    : AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final hasItems = _totalSelectedItemsCount > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ملخص الفاتورة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textHeading(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: hasItems
                      ? AppTheme.chipBg(context)
                      : AppTheme.surfaceLow(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasItems
                      ? '$_totalSelectedItemsCount صنف مختار'
                      : 'السلة فارغة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hasItems
                        ? AppTheme.accent(context)
                        : AppTheme.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (!hasItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.coffee_outlined,
                        size: 32,
                        color: AppTheme.textSecondary(context).withValues(alpha: 0.4)),
                    const SizedBox(height: 8),
                    Text(
                      'لم تختر أي قهوة بعد',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'اختر مشروبك المفضل من القائمة وستظهر فاتورتك الدقيقة هنا',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary(context).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // Dynamic selected items list with accurate prices and customizations
            ..._itemQuantities.entries.where((e) => e.value > 0).map((e) {
              final item = _menu.firstWhere(
                (c) => c.id == e.key,
                orElse: () => _menu.first,
              );
              final customized = _customizedItems[e.key];
              final double unitPrice = customized != null
                  ? (item.price + customized.extraPrice)
                  : item.price;
              final double lineTotal = unitPrice * e.value;
              final extrasSummary = customized?.extras.isNotEmpty == true
                  ? ' • ${customized!.extras.join('، ')}'
                  : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.name} (×${e.value})',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textHeading(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customized != null
                                ? '${customized.size} • ${customized.milk} • ${customized.sugar}$extrasSummary'
                                : 'وسط (M) • حليب شوفان • بدون سكر',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${lineTotal.toStringAsFixed(0)} ر.ي',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textHeading(context),
                      ),
                    ),
                  ],
                ),
              );
            }),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ضريبة القيمة المضافة والمحصول الخاص',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context)),
                  ),
                  Text(
                    'مشمولة',
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

          Divider(height: 22, color: AppTheme.divider(context)),

          // Grand Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المجموع الإجمالي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHeading(context),
                    ),
                  ),
                  Text(
                    'مطابق لقائمة المشروبات بدقة',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _grandTotal.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ر.ي',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textHeading(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyOrderBar() {
    final isDark = AppTheme.isDark(context);
    final hasItems = _totalSelectedItemsCount > 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: hasItems
                ? (isDark
                    ? Colors.black.withValues(alpha: 0.65)
                    : const Color(0xFF5D4037).withValues(alpha: 0.22))
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            spreadRadius: hasItems ? 1 : 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1C1A).withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: hasItems
                    ? AppTheme.accent(context).withValues(alpha: 0.45)
                    : (isDark ? Colors.white12 : Colors.black12),
                width: hasItems ? 1.4 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Cart summary
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: hasItems
                              ? AppTheme.accent(context).withValues(alpha: 0.18)
                              : AppTheme.surfaceLow(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 20,
                          color: hasItems
                              ? AppTheme.accent(context)
                              : AppTheme.textSecondary(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasItems
                                  ? '$_totalSelectedItemsCount صنف مختار'
                                  : 'السلة فارغة',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary(context),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              hasItems
                                  ? '${_grandTotal.toStringAsFixed(0)} ر.ي'
                                  : 'اختر قهوتك المفضلة',
                              style: TextStyle(
                                fontSize: hasItems ? 16 : 12,
                                fontWeight: FontWeight.bold,
                                color: hasItems
                                    ? AppTheme.accent(context)
                                    : AppTheme.textSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Order Action Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleConfirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasItems
                        ? AppTheme.accent(context)
                        : (isDark ? Colors.white12 : const Color(0xFFE5DDD5)),
                    foregroundColor: hasItems
                        ? (isDark ? const Color(0xFF121212) : Colors.white)
                        : AppTheme.textSecondary(context),
                    elevation: hasItems ? 3 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? const Color(0xFF121212) : Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'اطلب الآن',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_back_rounded, size: 16),
                          ],
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
