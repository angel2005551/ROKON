import '../models/order_model.dart';

class MockData {
  static final List<CoffeeItem> coffeeMenu = [
    const CoffeeItem(
      id: 'p0',
      name: 'قهوة اليوم: ركن قيدب V60',
      description: 'تحميص اليوم الخاص • كمية محدودة • معالجة مجففة لاهوائية مع نوتات التوت البري والياسمين.',
      price: 3600.0,
      imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&auto=format&fit=crop&q=80',
      category: 'قهوة مقطرة',
    ),
    const CoffeeItem(
      id: 'p1',
      name: 'سبانش لاتيه',
      description: 'توازن مخملي غني مع حليب مكثف محلى وحبوب سلفادور محمصة بدرجة متوسطة.',
      price: 3200.0,
      imageUrl: 'https://images.unsplash.com/photo-1577968897966-3d4325b36b61?w=500&auto=format&fit=crop&q=80',
      category: 'مشروبات بالحليب',
    ),
    const CoffeeItem(
      id: 'p2',
      name: 'كابتشينو',
      description: 'رغوة حريرية كثيفة مع إيحاءات الكاكاو والبندق البلجيكي وحليب عضوي طازج.',
      price: 2600.0,
      imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213?w=500&auto=format&fit=crop&q=80',
      category: 'مشروبات بالحليب',
    ),
    const CoffeeItem(
      id: 'p3',
      name: 'فلات وايت',
      description: 'دبل ريستريتو حاد يعانق حليباً مبخراً بدقة فائقة لقوام مخملي لا يقاوم.',
      price: 2800.0,
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500&auto=format&fit=crop&q=80',
      category: 'إسبريسو',
    ),
    const CoffeeItem(
      id: 'p4',
      name: 'أمريكانو',
      description: 'نقاء استخلاص عميق يكشف نوتات الشوكولاتة الداكنة وقواماً متوازناً منعشاً.',
      price: 2200.0,
      imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500&auto=format&fit=crop&q=80',
      category: 'إسبريسو',
    ),
    const CoffeeItem(
      id: 'p5',
      name: 'آيسد لاتيه إسبانيول',
      description: 'مزيج بارد منعش مع طبقات الإسبريسو والحليب البارد والمكثف المحلى.',
      price: 2700.0,
      imageUrl: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=500&auto=format&fit=crop&q=80',
      category: 'بارد منعش',
    ),
    const CoffeeItem(
      id: 'p6',
      name: 'قهوة اليوم مقطرة V60',
      description: 'محصول سلفادور طازج مع نكهات حمضية متوازنة واستخلاص يدوي متقن.',
      price: 1500.0,
      imageUrl: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=500&auto=format&fit=crop&q=80',
      category: 'قهوة مقطرة',
    ),
  ];

  static OrderModel get defaultActiveOrder {
    return OrderModel(
      id: '102',
      orderCode: 'RUK-102',
      customerName: 'عبدالله',
      branch: 'فرع الأصبحي - صنعاء',
      paymentMethod: 'محفظة جوال (كريمي إكسبرس)',
      pickupType: 'استلام فوري من الفرع',
      cupName: 'عبدالله',
      discount: 0.0,
      status: OrderStatus.inPrep,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      estimatedReadyTime: '12:12 م',
      baristaName: 'ريان اليماني',
      baristaRole: 'مختص تحضير V60 وإسبريسو',
      baristaAvatarUrl:
          'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=150&auto=format&fit=crop&q=80',
      items: [
        OrderItem(
          coffee: coffeeMenu[5], // Iced Latte Español
          size: 'كبير (L)',
          milk: 'حليب عادي',
          sugar: 'شوت إضافي',
          quantity: 1,
        ),
      ],
    );
  }

  static List<OrderModel> mockOrdersList = [
    OrderModel(
      id: '101',
      orderCode: 'RUK-101',
      customerName: 'سارة',
      branch: 'فرع حدة - صنعاء',
      paymentMethod: 'محفظة جوال (جوال باي)',
      pickupType: 'استلام فوري من الفرع',
      cupName: 'سارة',
      discount: 0.0,
      status: OrderStatus.received, // New
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      estimatedReadyTime: '12:15 م',
      baristaName: 'ريان اليماني',
      baristaRole: 'مختص تحضير V60 وكيمكس',
      baristaAvatarUrl:
          'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=150&auto=format&fit=crop&q=80',
      items: [
        OrderItem(
          coffee: coffeeMenu[3], // Flat White
          size: 'وسط (M)',
          milk: 'حليب شوفان',
          sugar: 'بدون سكر',
          quantity: 1,
        ),
      ],
    ),
    defaultActiveOrder,
    OrderModel(
      id: '100',
      orderCode: 'RUK-100',
      customerName: 'نورة',
      branch: 'فرع الأصبحي - صنعاء',
      paymentMethod: 'نقداً عند الاستلام (كاش)',
      pickupType: 'تحضير في السيارة',
      cupName: 'نورة',
      discount: 0.0,
      status: OrderStatus.ready,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      estimatedReadyTime: '11:58 ص',
      baristaName: 'سعد المنصور',
      baristaRole: 'باريستا إسبريسو مختص',
      baristaAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      items: [
        OrderItem(
          coffee: coffeeMenu[6], // Filter V60
          size: 'صغير (S)',
          milk: 'بدون حليب',
          sugar: 'بدون سكر',
          quantity: 1,
        ),
      ],
    ),
    OrderModel(
      id: '99',
      orderCode: 'RUK-099',
      customerName: 'محمد',
      branch: 'فرع الأصبحي - صنعاء',
      paymentMethod: 'محفظة جوال (كريمي إكسبرس)',
      pickupType: 'استلام فوري من الفرع',
      cupName: 'محمد',
      discount: 0.0,
      status: OrderStatus.cancelled,
      cancelReason: 'تغيير الطلب إلى فرع آخر',
      createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      estimatedReadyTime: '11:45 ص',
      baristaName: 'ريان اليماني',
      baristaRole: 'مختص تحضير V60 وإسبريسو',
      baristaAvatarUrl:
          'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=150&auto=format&fit=crop&q=80',
      items: [
        OrderItem(
          coffee: coffeeMenu[1], // Spanish Latte
          size: 'وسط (M)',
          milk: 'حليب كامل الدسم',
          sugar: 'سكر وسط',
          quantity: 1,
        ),
      ],
    ),
  ];
}
