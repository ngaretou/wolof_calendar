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

Future<ColorScheme> getMonthlyColorScheme(Brightness brightness) async {
  // as a compromise between changing color scheme with scroll (which brought the jank)
  // and having a fixed color scheme (boring), this changes color scheme with the month.
  // So you get 12 different colors through the months.
  int monthID = DateTime.now().month;

  // int monthID = 1; // for testing
  ImageProvider myBackground = AssetImage('assets/images/$monthID.jpg');
  ColorScheme newColorScheme = ColorScheme.dark();

  try {
    newColorScheme = await ColorScheme.fromImageProvider(
      provider: myBackground,
      brightness: brightness,
    );
  } catch (e) {
    debugPrint('problem setting palette generator color');
  }
  return newColorScheme;
}

class ThemeModel extends ChangeNotifier {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  String? userThemeName;

  // initial theme to keep it from doing a default theme
  ThemeData currentTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Lato',
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.dark,
    ),
  );

  ThemeData? darkTheme;
  ThemeData? lightTheme;

  Future<void> initialSetup(BuildContext context) async {
    await Provider.of<Months>(
      context,
      listen: false,
    ).fetchInitialDates(DateTime.now()); // real version
    // await Provider.of<Months>(context, listen: false).fetchInitialDates(DateTime(2028, 3)); // for testing
    if (!context.mounted) return;
    await Provider.of<UserPrefs>(context, listen: false).setupUserPrefs();
    await setupTheme();

    return;
  }

  Future<void> setupTheme() async {
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    //if there's no userTheme, it's the first time they've run the app, so give them darkTheme

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int currentBuildNumber = int.parse(packageInfo.buildNumber);

    try {
      // not just a new installation - if a build before about 2024 where
      // the build number was not saved then clear cache and set dark mode.

      if (!prefs.containsKey('lastBuildNumber')) {
        setDarkTheme();
        try {
          await AudioPlayer.clearAssetCache();
        } catch (e) {
          debugPrint(e.toString());
        }
      } else {
        //we've run it before - check last run build number
        String lastBuildNumber = json
            .decode(prefs.getString('lastBuildNumber') ?? '0')
            .toString();

        int lastSeenBuildNumber = int.parse(lastBuildNumber);

        //this clears the cache on each build number increment, so each year it will clear the previous year's audio.
        //Otherwise you have a caching problem where it doesn't get the new assets but uses cached mp3s.
        if (currentBuildNumber != lastSeenBuildNumber) {
          await AudioPlayer.clearAssetCache();
        }

        // get user stored theme if it exists.
        if (!prefs.containsKey('userThemeName')) {
          await setDarkTheme();
        } else {
          userThemeName =
              json.decode(prefs.getString('userThemeName')!) as String?;

          switch (userThemeName) {
            case 'darkTheme':
              {
                await setDarkTheme();
                break;
              }

            case 'lightTheme':
              {
                await setLightTheme();
                break;
              }
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      await AudioPlayer.clearAssetCache();
      await setDarkTheme();
    }
    //update ui
    notifyListeners();
    //and save the current build number for next time.
    final _currentBuildNumber = json.encode(currentBuildNumber);
    prefs.setString('lastBuildNumber', _currentBuildNumber);
  }

  Future<void> setDarkTheme() async {
    // only set up dark theme if requested
    if (darkTheme == null) {
      final darkColorScheme = await getMonthlyColorScheme(Brightness.dark);
      darkTheme = ThemeData(
        useMaterial3: true,
        fontFamily: 'Lato',
        colorScheme: darkColorScheme,
      );
    }

    currentTheme = darkTheme!;
    //get the theme name as a string for storage
    userThemeName = 'darkTheme';
    //send it for storage
    saveThemeToDisk(userThemeName!);
    notifyListeners();
  }

  Future<void> setLightTheme() async {
    // only set up dark theme if requested
    if (lightTheme == null) {
      final lightColorScheme = await getMonthlyColorScheme(Brightness.light);
      lightTheme = ThemeData(
        useMaterial3: true,
        fontFamily: 'Lato',
        colorScheme: lightColorScheme,
      );
    }

    currentTheme = lightTheme!;
    //get the theme name as a string for storage
    userThemeName = 'lightTheme';
    //send it for storage
    saveThemeToDisk(userThemeName!);
    notifyListeners();
  }

  // monthly changing colors
  // void setTheme(ColorScheme colorScheme) {
  //   // print('setting new color in provider theme.dart');
  //   currentTheme = ThemeData(fontFamily: 'Lato', colorScheme: colorScheme);

  //   notifyListeners();
  // }

  Future<void> saveThemeToDisk(String userThemeName) async {
    //get preferences from disk
    final prefs = await SharedPreferences.getInstance();
    //save _themeName to disk
    final _userThemeName = json.encode(userThemeName);
    prefs.setString('userThemeName', _userThemeName);
  }
}
