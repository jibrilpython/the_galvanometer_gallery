import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_galvanometer_gallery/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final pref = await SharedPreferences.getInstance();
    
    await tester.pumpWidget(ProviderScope(child: MyApp(preferences: pref)));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
