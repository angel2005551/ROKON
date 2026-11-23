enum OrderStatus {
  received,
  inPrep,
  ready,
  completed,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get labelArabic {
    switch (this) {
      case OrderStatus.received:
        return 'تم الاستلام';
      case OrderStatus.inPrep:
        return 'قيد التحضير';
      case OrderStatus.ready:
        return 'جاهز للاستلام';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  int get stageNumber {
    switch (this) {
      case OrderStatus.received:
        return 1;
      case OrderStatus.inPrep:
        return 2;
      case OrderStatus.ready:
      case OrderStatus.completed:
        return 3;
      case OrderStatus.cancelled:
        return 0;
    }
  }
}

class CoffeeItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> availableSizes;
  final List<String> milkOptions;

  const CoffeeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.availableSizes = const ['صغير (S)', 'وسط (M)', 'كبير (L)'],
    this.milkOptions = const ['حليب شوفان', 'حليب لوز', 'حليب كامل الدسم', 'بدون حليب'],
  });
}

class OrderItem {
  final CoffeeItem coffee;
  final String size;
  final String milk;
  final String sugar;
  final List<String> extras;
  final double extraPrice;
  final int quantity;

  const OrderItem({
    required this.coffee,
    this.size = 'وسط (M)',
    this.milk = 'حليب شوفان',
    this.sugar = 'بدون سكر',
    this.extras = const [],
    this.extraPrice = 0.0,
    this.quantity = 1,
  });

  OrderItem copyWith({
    CoffeeItem? coffee,
    String? size,
    String? milk,
    String? sugar,
    List<String>? extras,
    double? extraPrice,
    int? quantity,
  }) {
    return OrderItem(
      coffee: coffee ?? this.coffee,
      size: size ?? this.size,
      milk: milk ?? this.milk,
      sugar: sugar ?? this.sugar,
      extras: extras ?? this.extras,
      extraPrice: extraPrice ?? this.extraPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  double get unitPrice => coffee.price + extraPrice;
  double get totalPrice => unitPrice * quantity;
}

class OrderModel {
  final String id;
  final String orderCode;
  final String customerName;
  final String branch;
  final String paymentMethod;
  final String pickupType;
  final String cupName;
  final double discount;
  final List<OrderItem> items;
  OrderStatus status;
  String? cancelReason;
  final DateTime createdAt;
  final String estimatedReadyTime;
  final String baristaName;
  final String baristaRole;
  final String baristaAvatarUrl;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.branch,
    required this.paymentMethod,
    this.pickupType = 'استلام فوري من الفرع',
    this.cupName = 'أحمد بن علي',
    this.discount = 0.0,
    required this.items,
    this.status = OrderStatus.inPrep,
    this.cancelReason,
    required this.createdAt,
    required this.estimatedReadyTime,
    required this.baristaName,
    required this.baristaRole,
    required this.baristaAvatarUrl,
  });

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalAmount =>
      (subtotal - discount).clamp(0.0, double.infinity);

  String get statusTitle {
    switch (status) {
      case OrderStatus.received:
        return 'تم استلام طلبك وتأكيده';
      case OrderStatus.inPrep:
        return 'قهوتك تُحضر الآن بعناية';
      case OrderStatus.ready:
        return 'قهوتك جاهزة وتنتظرك!';
      case OrderStatus.completed:
        return 'تم استلام طلبك بنجاح';
      case OrderStatus.cancelled:
        return 'تم إلغاء الطلب واسترداد المبلغ';
    }
  }

  String get statusSubtitle {
    switch (status) {
      case OrderStatus.received:
        return 'تم تأكيد الدفع وإرسال الإشعار للمحمصة للبدء فوراً.';
      case OrderStatus.inPrep:
        return 'يقوم الباريستا حالياً باستخلاص الفلتر بنسبة حرارة متوازنة لملاحظات فاكهية غنية.';
      case OrderStatus.ready:
        return 'تفضل باستلام كوبك الدافئ من شباك الاستلام السريع بكود $orderCode';
      case OrderStatus.completed:
        return 'صحة وعافية! نتمنى لك تجربة قهوة لا تُنسى.';
      case OrderStatus.cancelled:
        return cancelReason != null
            ? 'سبب الإلغاء: $cancelReason\nتم إرجاع المبلغ إلى وسيلة الدفع الخاصة بك بنجاح.'
            : 'تم إرجاع المبلغ إلى وسيلة الدفع الخاصة بك بنجاح.';
    }
  }
}
