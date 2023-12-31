// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import './months.dart';
import './user_prefs.dart';

ThemeData darkTheme = ThemeData(
  fontFamily: 'Lato',
  colorSchemeSeed: Colors.teal,
  brightness: Brightness.dark,
);

ThemeData lightTheme = ThemeData(
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
    //if there's no userTheme, it's the first time they've run the app, so give them darkTheme

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int currentBuildNumber = int.parse(packageInfo.buildNumber);

    try {
      // if no previous run set dark theme
      if (!prefs.containsKey('lastBuildNumber')) {
        setDarkTheme();
      } else {
        //we've run it before - check last run build number
        String lastBuildNumber =
            json.decode(prefs.getString('lastBuildNumber')!) as String;

        int lastSeenBuildNumber = int.parse(lastBuildNumber);

        //this clears the cache on each build number increment, so each year it will clear the previous year's audio.
        //Otherwise you have a caching problem where it doesn't get the new assets but uses cached mp3s.
        if (currentBuildNumber > lastSeenBuildNumber) {
          await AudioPlayer.clearAssetCache();
        }

        // get user stored theme if it exists.
        if (!prefs.containsKey('userThemeName')) {
          setDarkTheme();
        } else {
          userThemeName =
              json.decode(prefs.getString('userThemeName')!) as String?;

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
      }
    } catch (e) {
      debugPrint(e.toString());
      setDarkTheme();
    }

    //save the current build number for next time.
    final _currentBuildNumber = json.encode(currentBuildNumber);
    prefs.setString('lastBuildNumber', _currentBuildNumber);
    notifyListeners();
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
    // print('setting new color in provider theme.dart');
    currentTheme = ThemeData(
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
