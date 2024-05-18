// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:chatsphere/services/auth/auth_gate.dart';
import 'package:chatsphere/services/auth/auth_service.dart';
import 'package:chatsphere/services/settings/settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_menu_panel/floating_menu_panel.dart';
import 'package:chatsphere/api/flutter_api.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
List <IconData> icons=[
  Icons.circle,
  Icons.circle,
  Icons.circle,
  Icons.circle,
];
List<MaterialColor> appColors=[
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.deepPurple,
];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterApi().initNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        ChangeNotifierProvider<SettingsService>(
          create: (context) => SettingsService(),
        ),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          MaterialApp(
            theme: ThemeData(
        primarySwatch: settingsService.appColor,
        secondaryHeaderColor: settingsService.appColor,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: settingsService.appColor),
      ),
      debugShowCheckedModeBanner: false,
      home: AuthGate()),
           FloatingMenuPanel(
      panelIcon: Icons.format_color_fill_rounded,
      onPressed: (a) {
      settingsService.changeAppColor(appColors[a]);
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
            )
        ],
      ),
    );
  }
}
