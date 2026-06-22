import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:online_food_ordering/core/constants/app_strings.dart';
import 'package:online_food_ordering/main.dart';

void main() {
  testWidgets('App shell renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LuxuryFoodOrderingApp()));
    await tester.pump();

    expect(find.text(AppStrings.appName), findsWidgets);
  });
}
