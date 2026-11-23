import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../data/mock_data.dart';

class SupabaseConfig {
  static const url = 'https://ldbmjaxuluuonofldipw.supabase.co';
  static const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxkYm1qYXh1bHV1b25vZmxkaXB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUzNTE2NTUsImV4cCI6MjExMDkyNzY1NX0.TcuWlqYtbUq9Fqp7cCj_LaAX7FAkJN-o2_cbFKL1KDw';
}

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase with the provided config
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.anonKey,
      );
      _isInitialized = true;
      debugPrint('✅ Supabase initialized successfully!');
    } catch (e) {
      _isInitialized = false;
      debugPrint('⚠️ Supabase init skipped or offline: $e');
    }
  }

  /// Fetch categories from Supabase with fallback
  Future<List<Map<String, dynamic>>> getCategories() async {
    if (client == null) return [];
    try {
      final response = await client!
          .from('categories')
          .select()
          .order('sort_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  /// Fetch active products from Supabase and map to CoffeeItem
  Future<List<CoffeeItem>> getProducts() async {
    if (client == null) return MockData.coffeeMenu;
    try {
      final response = await client!
          .from('products')
          .select('*, categories(name_ar)')
          .eq('is_available', true);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return MockData.coffeeMenu;
      }

      final Map<String, String> fallbackImages = {
        'سبانش لاتيه':
            'https://images.unsplash.com/photo-1577968897966-3d4325b36b61?w=500&auto=format&fit=crop&q=80',
        'كابتشينو':
            'https://images.unsplash.com/photo-1534778101976-62847782c213?w=500&auto=format&fit=crop&q=80',
        'فلات وايت':
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500&auto=format&fit=crop&q=80',
        'أمريكانو':
            'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500&auto=format&fit=crop&q=80',
      };

      return data.map((item) {
        final nameAr = item['name_ar']?.toString() ?? 'قهوة مختصة';
        final categoryMap = item['categories'] as Map<String, dynamic>?;
        final categoryName = categoryMap?['name_ar']?.toString() ?? 'قهوة';
        final price = (item['price'] as num?)?.toDouble() ?? 2500.0;
        final rawImg = item['image_url']?.toString();
        final imgUrl = (rawImg != null && rawImg.isNotEmpty)
            ? rawImg
            : (fallbackImages[nameAr] ??
                'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80');

        return CoffeeItem(
          id: item['id']?.toString() ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
          name: nameAr,
          description: item['description_ar']?.toString() ?? '',
          price: price,
          imageUrl: imgUrl,
          category: categoryName,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching products from Supabase: $e');
      return MockData.coffeeMenu;
    }
  }

  /// Map Supabase status string to OrderStatus
  static OrderStatus parseStatus(String? status) {
    switch (status) {
      case 'new':
      case 'received':
        return OrderStatus.received;
      case 'preparing':
      case 'inPrep':
        return OrderStatus.inPrep;
      case 'ready':
        return OrderStatus.ready;
      case 'delivered':
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.inPrep;
    }
  }

  /// Map OrderStatus to Supabase status string
  static String statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'new';
      case OrderStatus.inPrep:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.completed:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Fetch all orders from Supabase
  Future<List<OrderModel>> getOrders() async {
    if (client == null) return MockData.mockOrdersList;
    try {
      final response = await client!
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return MockData.mockOrdersList;
      }

      return data.map((json) => _orderFromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching orders from Supabase: $e');
      return MockData.mockOrdersList;
    }
  }

  /// Insert a new order into Supabase
  Future<OrderModel> placeOrder(OrderModel order) async {
    if (client == null) return order;
    try {
      final itemsPayload = order.items.map((item) {
        return {
          'product_id': item.coffee.id,
          'name': item.coffee.name,
          'qty': item.quantity,
          'unit_price': item.coffee.price,
          'size': item.size,
          'milk': item.milk,
          'sugar': item.sugar,
        };
      }).toList();

      final payload = {
        'order_code': order.orderCode,
        'customer_name': order.customerName,
        'pickup_mode': order.pickupType.contains('سيارة') ? 'car' : 'counter',
        'items': itemsPayload,
        'total': order.totalAmount,
        'status': statusToString(order.status),
        'estimated_ready_at': DateTime.now()
            .add(const Duration(minutes: 8))
            .toIso8601String(),
      };

      final response =
          await client!.from('orders').insert(payload).select().single();

      return _orderFromJson(response);
    } catch (e) {
      debugPrint('Error placing order to Supabase: $e');
      return order;
    }
  }

  /// Update order status (and cancellation reason if cancelled)
  Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? cancelReason,
  }) async {
    if (client == null) return false;
    try {
      final Map<String, dynamic> updatePayload = {
        'status': statusToString(newStatus),
      };

      if (newStatus == OrderStatus.cancelled && cancelReason != null) {
        updatePayload['cancel_reason'] = cancelReason;
        // Fetch current items to append cancelReason metadata safely
        try {
          final current = await client!
              .from('orders')
              .select('items')
              .eq('id', orderId)
              .maybeSingle();

          if (current != null && current['items'] != null) {
            final items = List<dynamic>.from(current['items']);
            items.add({'_meta_cancel_reason': cancelReason});
            updatePayload['items'] = items;
          }
        } catch (_) {}
      }

      await client!.from('orders').update(updatePayload).eq('id', orderId);
      return true;
    } catch (e) {
      debugPrint('Error updating order status in Supabase: $e');
      return false;
    }
  }

  /// Realtime stream subscription for live orders
  StreamSubscription<List<Map<String, dynamic>>>? subscribeToOrders({
    required void Function(List<OrderModel>) onOrdersUpdated,
  }) {
    if (client == null) return null;
    try {
      return client!
          .from('orders')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .listen((data) {
        final list = data.map((json) => _orderFromJson(json)).toList();
        if (list.isNotEmpty) {
          onOrdersUpdated(list);
        }
      }, onError: (err) {
        debugPrint('Realtime stream error: $err');
      });
    } catch (e) {
      debugPrint('Realtime subscription skipped: $e');
      return null;
    }
  }

  /// Helper to convert Supabase row to OrderModel
  OrderModel _orderFromJson(Map<String, dynamic> json) {
    final status = parseStatus(json['status']?.toString());
    final itemsRaw = json['items'];
    final List<OrderItem> items = [];
    String? cancelReason = json['cancel_reason']?.toString();

    if (itemsRaw is List) {
      for (final it in itemsRaw) {
        if (it is Map) {
          if (it.containsKey('_meta_cancel_reason')) {
            cancelReason = it['_meta_cancel_reason']?.toString();
            continue;
          }
          final name = it['name']?.toString() ?? 'قهوة';
          final qty = (it['qty'] as num?)?.toInt() ?? 1;
          final unitPrice =
              (it['unit_price'] as num?)?.toDouble() ?? 2500.0;
          final size = it['size']?.toString() ?? 'وسط (M)';
          final milk = it['milk']?.toString() ?? 'حليب شوفان';
          final sugar = it['sugar']?.toString() ?? 'بدون سكر';

          final coffee = CoffeeItem(
            id: it['product_id']?.toString() ?? 'p_db',
            name: name,
            description: '',
            price: unitPrice,
            imageUrl:
                'https://images.unsplash.com/photo-1577968897966-3d4325b36b61?w=500&auto=format&fit=crop&q=80',
            category: 'مشروبات القهوة',
          );

          items.add(
            OrderItem(
              coffee: coffee,
              quantity: qty,
              size: size,
              milk: milk,
              sugar: sugar,
            ),
          );
        }
      }
    }

    if (items.isEmpty) {
      items.add(
        OrderItem(
          coffee: MockData.coffeeMenu.first,
          quantity: 1,
        ),
      );
    }

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'].toString()).toLocal();
    } catch (_) {
      createdAt = DateTime.now();
    }

    final pickupMode = json['pickup_mode']?.toString();
    final isCar = pickupMode == 'car';

    return OrderModel(
      id: json['id']?.toString() ?? '${DateTime.now().millisecondsSinceEpoch}',
      orderCode: json['order_code']?.toString() ?? 'RUK-101',
      customerName: json['customer_name']?.toString() ?? 'عميل ركن',
      branch: 'فرع الأصبحي - صنعاء',
      paymentMethod: 'كريمي إكسبرس (دفع إلكتروني)',
      pickupType: isCar ? 'تحضير في السيارة' : 'استلام فوري من الفرع',
      cupName: json['customer_name']?.toString() ?? 'عميل ركن',
      discount: 0.0,
      items: items,
      status: status,
      cancelReason: cancelReason,
      createdAt: createdAt,
      estimatedReadyTime: 'جاهز خلال ٥-٨ دقائق',
      baristaName: 'ريان اليماني',
      baristaRole: 'مختص تحضير V60 وإسبريسو',
      baristaAvatarUrl:
          'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=150&auto=format&fit=crop&q=80',
    );
  }
}
