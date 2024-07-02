// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:chatsphere/services/auth/auth_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chatsphere/main.dart'; // Убедитесь, что путь к файлу main.dart правильный
import 'package:chatsphere/services/auth/auth_service.dart';
import 'package:chatsphere/services/settings/settings_service.dart';
import 'package:chatsphere/theme_provider/provider.dart';
import 'package:chatsphere/services/internet_provider/internet_provider.dart';

void main() {
  testWidgets('MyApp loads and displays AuthGate', (WidgetTester tester) async {
    // Создаем mock-объекты для всех ChangeNotifier
    final mockAuthService = AuthService();
    final mockSettingsService = SettingsService();
    final mockUiProvider = UiProvider();
    final mockConnectivityService = ConnectivityService();

    await mockSettingsService.init();
    await mockUiProvider.init();

    // Логируем начальное состояние
    print('SettingsService initialized with wallpaperPath: ${mockSettingsService.wallpaperPath}');
    print('UiProvider initialized with isDark: ${mockUiProvider.isDark}');

    // Запускаем приложение
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<SettingsService>.value(value: mockSettingsService),
          ChangeNotifierProvider<UiProvider>.value(value: mockUiProvider),
          ChangeNotifierProvider<ConnectivityService>.value(value: mockConnectivityService),
        ],
        child: MyApp(),
      ),
    );

    // Проверяем, что отображается виджет AuthGate
    expect(find.byType(AuthGate), findsOneWidget);
  });
}
