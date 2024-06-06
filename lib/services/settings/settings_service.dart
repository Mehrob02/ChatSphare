import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool _colorChanger = false;
  bool get colorChanger => _colorChanger;

  String _wallpaperPath="none";
  String get wallpaperPath=> _wallpaperPath;

  final String _email;
  String _userNickName = '';
  MaterialColor _appColor = Colors.deepPurple;

  SettingsService() : _email = FirebaseAuth.instance.currentUser?.email ?? '' {
    _loadUserNickName();
  }

  String get email => _email;
  String get userNickName => _userNickName;

  MaterialColor get appColor => _appColor;

  void colorChange(bool newValue) {
    _colorChanger = newValue;
    notifyListeners();
  }

  void changeWallpaper(int wallpaperIndex){
    _wallpaperPath = kIsWeb? "wallpapers/wallpaper-${wallpaperIndex+1}.jpeg":"assets/wallpapers/wallpaper-${wallpaperIndex+1}.jpeg";
    saveWallpaperPath();
    notifyListeners();
  }

  void deleteWallpaper(){
    _wallpaperPath = "none";
    notifyListeners();
    saveWallpaperPath();
  }

  set appColor(MaterialColor newAppColor) {
    _appColor = newAppColor;
    notifyListeners();
  }
  set wallpaperPath(String newPath) {
    _wallpaperPath = newPath;
    notifyListeners();
  }
  void changeAppColor(MaterialColor newAppColor) {
    appColor = newAppColor;
    saveAppColor();
  }
 Future<String> getProfileImageUrl() async {
    try {
      final ref = FirebaseStorage.instance.ref('user_profile_images/${firebaseAuth.currentUser!.uid}.jpg');
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      // Если изображение не найдено или произошла ошибка, возвращаем URL изображения по умолчанию
      return "https://static-00.iconduck.com/assets.00/profile-circle-icon-2048x2048-cqe5466q.png";
    }
  }
  void saveAppColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('appColor', appColor.value);
  }

  Future<void> loadColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue = prefs.getInt('appColor') ?? Colors.deepPurple.value;
    appColor = createMaterialColor(Color(colorValue));
    notifyListeners();
  }

  void saveWallpaperPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('wallpaperPath', wallpaperPath);
  }

  Future<void> loadWallpaperPath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String newPath = prefs.getString('wallpaperPath') ?? "none";
    wallpaperPath=newPath;
    notifyListeners();
  }
  
  Future<void> _loadUserNickName() async {
    if (firebaseAuth.currentUser != null) {
      DocumentSnapshot nickNameSnapshot = await FirebaseFirestore.instance
          .collection("nickNames")
          .doc(firebaseAuth.currentUser!.uid)
          .get();
      if (nickNameSnapshot.exists) {
        Map<String, dynamic> nickNamesData = nickNameSnapshot.data() as Map<String, dynamic>;
        _userNickName = nickNamesData['nickName'] ?? '';
        notifyListeners();
      }
    }
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
