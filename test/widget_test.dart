import 'package:flutter_test/flutter_test.dart';

import 'package:sirati/main.dart';

void main() {
  testWidgets('Sirati app starts on welcome screen', (tester) async {
    await tester.pumpWidget(const SiratiApp());

    expect(find.text('سيرتي'), findsWidgets);
    expect(find.text('اصنع سيرتك الذاتية باحترافية'), findsOneWidget);
  });
}
