// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import './months.dart';
import './user_prefs.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: true, //important!
  fontFamily: 'Lato',
  colorSchemeSeed: Colors.teal,
  brightness: Brightness.dark,
);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Lato',
  colorSchemeSeed: Colors.teal,
  brightness: Brightness.light,
);

//////////////////////
enum ThemeType { light, dark }

class ThemeModel extends ChangeNotifier {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  // ignore: unused_field
  ThemeType? _themeType;
  String? userThemeName;
  ThemeData? currentTheme;

  Future<void> initialSetupAsync(context) async {
    await Provider.of<Months>(context, listen: false).getData();
    await Provider.of<UserPrefs>(context, listen: false).setupUserPrefs();
    await setupTheme();

    return;
  }

  Future<void> setupTheme() async {
    if (currentTheme != null) {
      return;
    }
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme

    if (!prefs.containsKey('userThemeName')) {
      setLightTheme();
    } else {
      userThemeName = json.decode(prefs.getString('userThemeName')!) as String?;

      switch (userThemeName) {
        case 'darkTheme':
          {
            currentTheme = darkTheme;

            _themeType = ThemeType.dark;
            break;
          }

        case 'lightTheme':
          {
            currentTheme = lightTheme;
            _themeType = ThemeType.light;
            break;
          }
      }
    }
    notifyListeners();
    return;
  }

  void setDarkTheme() {
    currentTheme = darkTheme;
    _themeType = ThemeType.dark;
    //get the theme name as a string for storage
    userThemeName = 'darkTheme';
    //send it for storage
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  void setLightTheme() {
    currentTheme = lightTheme;
    _themeType = ThemeType.light;
    userThemeName = 'lightTheme';
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  void setThemeColor(Color color) {
    print('setting new color in provider theme.dart');
    currentTheme = ThemeData(
        useMaterial3: true,
        fontFamily: 'Lato',
        colorSchemeSeed: color,
        brightness:
            userThemeName == 'lightTheme' ? Brightness.light : Brightness.dark);

    notifyListeners();
  }

  Future<void> saveThemeToDisk(userThemeName) async {
    //get preferences from disk
    final prefs = await SharedPreferences.getInstance();
    //save _themeName to disk
    final _userThemeName = json.encode(userThemeName);
    prefs.setString('userThemeName', _userThemeName);
  }
}
