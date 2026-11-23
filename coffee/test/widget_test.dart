import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee/main.dart';
import 'package:coffee/models/order_model.dart';
import 'package:coffee/services/supabase_service.dart';
import 'package:coffee/screens/notifications_screen.dart';
import 'package:coffee/screens/settings_screen.dart';

final Uint8List _transparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('Rokon Coffee smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RokonCoffeeApp());
    expect(find.textContaining('رُكـن'), findsWidgets);

    // Fast forward splash timer
    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('ركن'), findsWidgets);
  });

  testWidgets('Tapping customize opens cup customization sheet',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RokonCoffeeApp());
    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pump(const Duration(milliseconds: 500));

    // Find customize button on hero or cards
    final customizeFinder = find.text('تخصيص الكوب');
    expect(customizeFinder, findsOneWidget);

    await tester.tap(customizeFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify modal options are shown
    expect(find.text('درجة الحرارة'), findsOneWidget);
    expect(find.text('الحجم'), findsOneWidget);
    expect(find.text('نوع الحليب'), findsOneWidget);
    expect(find.text('درجة السكر'), findsOneWidget);
    expect(find.textContaining('إضافة للطلب'), findsOneWidget);
  });

  testWidgets('Notifications and Settings screens render correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: NotificationsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('الإشعارات'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: SettingsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('تفضيلات التطبيق والمحمصة'), findsOneWidget);
  });

  testWidgets('OrderModel cancellation status and cancelReason work correctly',
      (WidgetTester tester) async {
    final order = OrderModel(
      id: 'test-1',
      orderCode: 'RUK-999',
      customerName: 'فهد',
      branch: 'فرع الأصبحي - صنعاء',
      paymentMethod: 'كريمي إكسبرس',
      items: [],
      status: OrderStatus.cancelled,
      cancelReason: 'تغيير الطلب',
      createdAt: DateTime.now(),
      estimatedReadyTime: '12:00 م',
      baristaName: 'علي',
      baristaRole: 'باريستا',
      baristaAvatarUrl: '',
    );

    expect(order.status, OrderStatus.cancelled);
    expect(order.cancelReason, 'تغيير الطلب');
    expect(order.statusTitle, 'تم إلغاء الطلب واسترداد المبلغ');
    expect(order.statusSubtitle, contains('سبب الإلغاء: تغيير الطلب'));
  });

  test('SupabaseConfig and status mapping test', () {
    expect(SupabaseConfig.url, 'https://ldbmjaxuluuonofldipw.supabase.co');
    expect(SupabaseConfig.anonKey, isNotEmpty);

    expect(SupabaseService.parseStatus('new'), OrderStatus.received);
    expect(SupabaseService.parseStatus('preparing'), OrderStatus.inPrep);
    expect(SupabaseService.parseStatus('ready'), OrderStatus.ready);
    expect(SupabaseService.parseStatus('delivered'), OrderStatus.completed);
    expect(SupabaseService.parseStatus('cancelled'), OrderStatus.cancelled);

    expect(SupabaseService.statusToString(OrderStatus.received), 'new');
    expect(SupabaseService.statusToString(OrderStatus.inPrep), 'preparing');
    expect(SupabaseService.statusToString(OrderStatus.ready), 'ready');
    expect(SupabaseService.statusToString(OrderStatus.completed), 'delivered');
    expect(SupabaseService.statusToString(OrderStatus.cancelled), 'cancelled');
  });

  test('OrderItem with extras and accurate pricing calculation', () {
    const coffee = CoffeeItem(
      id: 'test-c1',
      name: 'كابتشينو',
      description: 'وصف تجريبي',
      price: 2600.0,
      imageUrl: '',
      category: 'مشروبات بالحليب',
    );

    final itemWithExtras = OrderItem(
      coffee: coffee,
      quantity: 2,
      extraPrice: 400.0, // e.g. extra shot
      extras: const ['شوت إضافي'],
    );

    expect(itemWithExtras.unitPrice, 3000.0);
    expect(itemWithExtras.totalPrice, 6000.0);

    final order = OrderModel(
      id: 'test-order-1',
      orderCode: 'RUK-555',
      customerName: 'عبدالرحمن',
      branch: 'فرع الأصبحي - صنعاء',
      paymentMethod: 'كريمي إكسبرس',
      items: [itemWithExtras],
      createdAt: DateTime.now(),
      estimatedReadyTime: '12:10 م',
      baristaName: 'ريان',
      baristaRole: 'باريستا',
      baristaAvatarUrl: '',
    );

    expect(order.subtotal, 6000.0);
    expect(order.totalAmount, 6000.0); // Exact match, no phantom discount
    expect(order.customerName, 'عبدالرحمن');
  });
}
