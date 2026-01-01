import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:snekid/app.dart';

void main() {
  testWidgets('SnekID app launches', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SnekIDApp(),
      ),
    );

    // Verify app launches without errors
    await tester.pumpAndSettle();
  });
}
