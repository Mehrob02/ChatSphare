// ignore_for_file: prefer_const_constructors, unused_import, deprecated_member_use
//https://pub.dev/packages/flutter_list_view

import 'package:chatsphere/theme_provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/internet_provider/internet_provider.dart';
import 'services/auth/auth_service.dart';
import 'services/settings/settings_service.dart';
import 'services/auth/auth_gate.dart';
import 'package:chatsphere/api/flutter_api.dart';
import 'package:floating_menu_panel/floating_menu_panel.dart';
import 'services/firebase_options/firebase_options.dart';

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
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  await FlutterApi().initNotifications();
  final settingsService = SettingsService();
  await settingsService.init();
  debugPrint(settingsService.wallpaperPath);
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
        create:(context)=> themeProvider),
        ChangeNotifierProvider<ConnectivityService>(
          create: (context) => ConnectivityService(),
        ),
      ],
      child: MyApp(),
    ),
  );
  // runApp(
  //   MyHome()
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final themeProvider = Provider.of<UiProvider>(context);
    final connectivityService = Provider.of<ConnectivityService>(context);
    ThemeData darkTheme= ThemeData(
      useMaterial3: false,
        primaryColor: settingsService.appColor,
        primarySwatch: settingsService.appColor,
        secondaryHeaderColor: settingsService.appColor,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
                  buttonColor: settingsService.appColor,
                  textTheme: ButtonTextTheme.accent
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: settingsService.appColor).copyWith(
          brightness: Brightness.dark,
          secondary: settingsService.appColor,
          onBackground: Colors.grey[800],
          onSecondary: Colors.black
        ),
        brightness: Brightness.dark,
      );
      ThemeData lightTheme= ThemeData(
        useMaterial3: false,
        primaryColor: settingsService.appColor,
        primarySwatch: settingsService.appColor,
        secondaryHeaderColor: settingsService.appColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: settingsService.appColor).copyWith(
          brightness: Brightness.light,
          secondary: settingsService.appColor,
          onBackground: Colors.grey[400],
          onSecondary: Color.fromARGB(255, 197, 197, 197)
        ),
        brightness: Brightness.light,
      );
    return InAppNotification(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PieCanvas(
          child: Stack(
              children: [
                MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Stack(
                    children: [
                      MaterialApp(
                        debugShowCheckedModeBanner: false,
                        theme: themeProvider.isDark? darkTheme:lightTheme,
                       home: AuthGate()),
                        Visibility(
                  visible: !connectivityService.hasConnection,
                  maintainAnimation: true,
                 maintainState: true,
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            opacity: !connectivityService.hasConnection?1:0,
                    child:
                    MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: themeProvider.isDark? darkTheme:lightTheme,
                  home: Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(kIsWeb? "no-connection.png":"assets/no-connection.png"),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Oops....",
                                  style: TextStyle(fontSize: 30),
                                ),
                                Text("Looks like you've lost internet connection"),
                                Text("Please, fix your connection to continue"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),)
                    ],
                  ),
                ),
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
                  //  buttonColors: appColors,
                    buttons: icons,
                    backgroundColor: settingsService.appColor,
                  ),
               
            ],
          ),
        )),
    );
  }
}