// ignore_for_file: prefer_const_constructors



import 'package:chatsphere/theme_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth/auth_service.dart';
import 'services/settings/settings_service.dart';
import 'services/auth/auth_gate.dart';
import 'package:chatsphere/api/flutter_api.dart';
import 'package:floating_menu_panel/floating_menu_panel.dart';
import 'firebase_options.dart';

List<IconData> icons = [
  Icons.circle,
  Icons.circle,
  Icons.circle,
  Icons.circle,
  Icons.close
];

List<MaterialColor> appColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.deepPurple,
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterApi().initNotifications();

  final settingsService = SettingsService();
  await settingsService.loadColor();
  final themeProvider = UiProvider();
  await themeProvider.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        ChangeNotifierProvider<SettingsService>(
          create: (context) => settingsService,
        ),
        ChangeNotifierProvider<UiProvider>(
        create:(context)=> themeProvider)
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final themeProvider = Provider.of<UiProvider>(context);
    ThemeData darkTheme= ThemeData(
        primaryColor: settingsService.appColor,
        primarySwatch: settingsService.appColor,
        secondaryHeaderColor: settingsService.appColor,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: settingsService.appColor).copyWith(
          brightness: Brightness.dark,
          secondary: settingsService.appColor,
          onBackground: Colors.grey[900]
        ),
        brightness: Brightness.dark,
      );
      ThemeData lightTheme= ThemeData(
        primaryColor: settingsService.appColor,
        primarySwatch: settingsService.appColor,
        secondaryHeaderColor: settingsService.appColor,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: settingsService.appColor).copyWith(
          brightness: Brightness.light,
          secondary: settingsService.appColor,
          onBackground: Colors.grey[400]
        ),
        brightness: Brightness.light,
      );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.isDark? darkTheme:lightTheme,
           home: AuthGate()),
          if (settingsService.colorChanger)
            FloatingMenuPanel(
              positionTop: 20,
              panelIcon: Icons.format_color_fill_rounded,
              onPressed: (a) {
                if (a == 4) {
                  settingsService.colorChange(false);
                } else {
                  settingsService.changeAppColor(appColors[a]);
                }
              },
              buttonColors: appColors,
              buttons: icons,
              backgroundColor: settingsService.appColor,
            ),
          if (1 == 2)
            Scaffold(
              body: Center(
                child: Text("oops"),
              ),
            ),
        ],
      ),
    );
  }
}
