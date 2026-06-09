import 'package:flutter_test/flutter_test.dart';
import 'package:xiaoyueliang/main.dart';

void main() {
  testWidgets('App loads and shows home page', (WidgetTester tester) async {
    await tester.pumpWidget(const XiaoYueLiangApp());
    await tester.pumpAndSettle();

    // Verify the app title is shown
    expect(find.text('小月亮'), findsOneWidget);
  });
}
