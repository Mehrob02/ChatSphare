import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  MaterialColor _appColor = Colors.deepPurple;
  Color _appTextColor = Colors.white;

  MaterialColor get appColor => _appColor;

  set appColor(MaterialColor newAppColor) {
    _appColor = newAppColor;
    notifyListeners();
  }
  Color get appTextColor => _appTextColor;

  set appTextColor(Color newAppTextColor) {
    _appTextColor = newAppTextColor;
    notifyListeners();
  }
  void changeAppColor(MaterialColor newAppColor) {
    appColor = newAppColor;
    notifyListeners();
  }
  void saveAppColor()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('appColor', appColor.value);
  }
  Future<Color> getAppColor() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int colorValue = prefs.getInt('appColor') ?? Colors.deepPurple.value;
  return Color(colorValue);
}
Future<void> loadColor()async{
appColor = createMaterialColor(await getAppColor());
notifyListeners();
}
  MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}
}