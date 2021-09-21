import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import './months.dart';
import './user_prefs.dart';

// Primary is all of the raised text and buttons: Button color,
//text of OK/Cancel buttons, highlights in calendar picker.
//Secondary ends up being only the color of holidays
ThemeData darkTheme = ThemeData(
  fontFamily: 'Lato',
  colorScheme: ColorScheme.dark()
      .copyWith(primary: Colors.teal[300], secondary: Colors.teal[850]),
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal[800],
      iconTheme: IconThemeData(color: Colors.white)),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.teal),
);

ThemeData lightTheme = ThemeData(
  fontFamily: 'Lato',
  primarySwatch: Colors.teal,
  colorScheme: ColorScheme.light()
      .copyWith(primary: Colors.teal[300], secondary: Colors.teal[100]),
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal[800],
      iconTheme: IconThemeData(color: Colors.white)),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.teal),
);

ThemeData blueTheme = ThemeData(
  fontFamily: 'Lato',
  primarySwatch: Colors.blue,
  backgroundColor: Colors.teal,
  colorScheme: ColorScheme.light()
      .copyWith(primary: Colors.blue, secondary: Colors.blue[100]),
  scaffoldBackgroundColor: Colors.blue[50],
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      iconTheme: IconThemeData(color: Colors.white)),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.blue),
);

ThemeData tealTheme = ThemeData(
  fontFamily: 'Lato',
  primarySwatch: Colors.teal,
  colorScheme: ColorScheme.light()
      .copyWith(primary: Colors.teal, secondary: Colors.teal[100]),
  scaffoldBackgroundColor: Colors.teal[50],
  appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal[800],
      iconTheme: IconThemeData(color: Colors.white)),
  // buttonTheme: ButtonThemeData(buttonColor: Colors.teal),
);

//////////////////////
enum ThemeType { Light, Blue, Teal, Dark }

class ThemeModel extends ChangeNotifier {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  // ignore: unused_field
  ThemeType? _themeType;
  String? userThemeName;
  ThemeData? currentTheme;
  Locale? userLocale;

  Future<void> setLocale(String incomingLocale) async {
    switch (incomingLocale) {
      case 'en':
        userLocale = Locale('en', '');
        notifyListeners();
        break;
      case 'fr':
        userLocale = Locale('fr', '');
        notifyListeners();
        break;
      case 'fr_CH':
        userLocale = Locale('fr', 'CH');
        notifyListeners();
        break;
      default:
    }

    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();
    //save userLang to disk
    String _userLang = json.encode(incomingLocale);
    prefs.setString('userLang', _userLang);
  }

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

            _themeType = ThemeType.Dark;
            break;
          }

        case 'lightTheme':
          {
            currentTheme = lightTheme;
            _themeType = ThemeType.Light;
            break;
          }
        case 'blueTheme':
          {
            currentTheme = blueTheme;
            _themeType = ThemeType.Blue;
            break;
          }
        case 'tealTheme':
          {
            currentTheme = tealTheme;
            _themeType = ThemeType.Teal;
            break;
          }
      }
    }
    notifyListeners();
  }

  void setDarkTheme() {
    currentTheme = darkTheme;
    _themeType = ThemeType.Dark;
    //get the theme name as a string for storage
    userThemeName = 'darkTheme';
    //send it for storage
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  void setLightTheme() {
    currentTheme = lightTheme;
    _themeType = ThemeType.Light;
    userThemeName = 'lightTheme';
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  void setTealTheme() {
    currentTheme = tealTheme;
    _themeType = ThemeType.Teal;
    userThemeName = 'tealTheme';
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  void setBlueTheme() {
    currentTheme = blueTheme;
    _themeType = ThemeType.Blue;
    userThemeName = 'blueTheme';
    saveThemeToDisk(userThemeName);
    notifyListeners();
  }

  Future<void> saveThemeToDisk(userThemeName) async {
    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();
    //save _themeName to disk
    final _userThemeName = json.encode(userThemeName);
    prefs.setString('userThemeName', _userThemeName);
  }
}
