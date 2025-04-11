import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:letwork/main.dart';

void main() {
  testWidgets('Uygulama açılış testi', (WidgetTester tester) async {
    // LetWorkApp widget'ını test ediyoruz
    await tester.pumpWidget(const LetWorkApp());

    // TODO: Giriş yapıldıysa Home, yapılmadıysa Login gelir. Test için dummy widget gerekir.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
