import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import './months.dart';
import './user_prefs.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Color(0xff1f655d),
    accentColor: Color(0xff40bf7a),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white, backgroundColor: Colors.teal),
    iconTheme: IconThemeData(color: Colors.white70),
    textTheme: TextTheme(
        headline5:
            TextStyle(color: Colors.white, fontFamily: 'Lato', fontSize: 20),
        headline6:
            TextStyle(color: Colors.white, fontFamily: 'Lato', fontSize: 20),
        subtitle2: TextStyle(color: Colors.white),
        subtitle1: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white)),
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
          headline6:
              TextStyle(color: Colors.white, fontFamily: 'Lato', fontSize: 20)),
      color: Color(0xff1f655d),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      minWidth: 80,
    ));

ThemeData lightTheme = ThemeData.light().copyWith(
    // primaryColor: Color(0xfff5f5f5),
    // accentColor: Color(0xff40bf7a),
    primaryColor: Colors.teal,
    accentColor: Colors.teal[200],
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        // foregroundColor: Colors.white, backgroundColor: Colors.black54),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal),
    iconTheme: IconThemeData(color: Colors.black54),
    textTheme: TextTheme(
      headline5:
          TextStyle(color: Colors.black54, fontFamily: 'Lato', fontSize: 20),
      headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
      subtitle2: TextStyle(color: Colors.black54),
      subtitle1: TextStyle(color: Colors.black54),
      bodyText2: TextStyle(color: Colors.black87),
    ),
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: TextTheme(
          headline6:
              TextStyle(color: Colors.white, fontFamily: 'Lato', fontSize: 20),
        ),
        //     subtitle2: TextStyle(color: Colors.white),
        //     subtitle1: TextStyle(color: Colors.white)),
        color: Colors.teal,
        actionsIconTheme: IconThemeData(color: Colors.white)),
    buttonTheme: ButtonThemeData(minWidth: 80));

ThemeData blueTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
    accentColor: Colors.lightBlue[200],
    cardColor: Colors.blue[200],
    backgroundColor: Colors.blue,
    scaffoldBackgroundColor: Colors.blue[100],
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white, backgroundColor: Colors.blue[700]),
    iconTheme: IconThemeData(color: Colors.white70),
    textTheme: TextTheme(
        headline5:
            TextStyle(color: Colors.white, fontFamily: 'Lato', fontSize: 20),
        headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
        subtitle2: TextStyle(color: Colors.black54),
        subtitle1: TextStyle(color: Colors.black54),
        bodyText2: TextStyle(color: Colors.black87)),
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: TextTheme(
            headline6: TextStyle(
                color: Colors.white, fontFamily: 'Lato', fontSize: 20)),
        color: Colors.blueAccent,
        actionsIconTheme: IconThemeData(color: Colors.white)),
    buttonTheme: ButtonThemeData(minWidth: 80),
    dialogTheme: DialogTheme(
        contentTextStyle: TextStyle(color: Colors.black54),
        titleTextStyle: TextStyle(
            color: Colors.black54, fontFamily: 'Lato', fontSize: 20)));

ThemeData tealTheme = ThemeData.light().copyWith(
    primaryColor: Colors.teal,
    accentColor: Colors.teal[300],
    cardColor: Colors.teal[100],
    backgroundColor: Colors.teal,
    scaffoldBackgroundColor: Colors.teal[200],
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.white70, backgroundColor: Colors.teal[800]),
    iconTheme: IconThemeData(color: Colors.white70),
    textTheme: TextTheme(
      headline5:
          TextStyle(color: Colors.white, fontFamily: 'Lato', fontSize: 20),
      headline6: TextStyle(color: Colors.black54, fontFamily: 'Lato'),
      subtitle2: TextStyle(color: Colors.black54),
      subtitle1: TextStyle(color: Colors.black54),
      bodyText2: TextStyle(color: Colors.black87),
    ),
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: TextTheme(
            headline6: TextStyle(
                color: Colors.white, fontFamily: 'Lato', fontSize: 20)),
        color: Color(0xff1f655d),
        actionsIconTheme: IconThemeData(color: Colors.white)),
    buttonTheme: ButtonThemeData(
      minWidth: 80,
    ));

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
    print('setupTheme');
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
