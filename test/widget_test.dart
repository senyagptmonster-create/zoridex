import 'package:flutter_test/flutter_test.dart';
import 'package:zoridex/zoridex_app.dart';

void main() {
  testWidgets('ZoridexApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZoridexApp());
    await tester.pump();
    expect(find.text('Entropy Generator'), findsWidgets);
  });
}
