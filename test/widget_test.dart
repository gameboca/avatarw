import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mods_for_avatar_world/providers/mods_provider.dart';
import 'package:mods_for_avatar_world/providers/houses_provider.dart';
import 'package:mods_for_avatar_world/providers/creator_provider.dart';
import 'package:mods_for_avatar_world/providers/workbench_provider.dart';
import 'package:mods_for_avatar_world/services/revenue_cat_service.dart';
import 'package:mods_for_avatar_world/ui/screens/main_shell_screen.dart';

void main() {
  testWidgets('MainShellScreen renders tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ModsProvider()),
          ChangeNotifierProvider(create: (_) => HousesProvider()),
          ChangeNotifierProvider(create: (_) => CreatorProvider()),
          ChangeNotifierProvider(create: (_) => WorkbenchProvider()),
          ChangeNotifierProvider.value(value: RevenueCatService.instance),
        ],
        child: const MaterialApp(
          home: MainShellScreen(),
        ),
      ),
    );

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.text('MODS'), findsWidgets);
    expect(find.text('INTERIOR'), findsWidgets);
    expect(find.text('WORKBENCH'), findsWidgets);
    expect(find.text('CREATOR'), findsWidgets);
  });
}
