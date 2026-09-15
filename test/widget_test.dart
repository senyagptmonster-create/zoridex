import 'package:flutter_test/flutter_test.dart';
import 'package:zoridex/zoridex_app.dart';

void main() {
  testWidgets('ZoridexApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZoridexApp());
    expect(find.byType(ZoridexApp), findsOneWidget);
  });
}
