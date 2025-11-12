// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/foundation.dart';
import 'dart:core';
// import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs with ChangeNotifier {
  bool? textDirection;
  bool? imageEnabled;
  bool? wolofVerseEnabled;
  bool? wolofalVerseEnabled;
  bool? showFavs;
  bool? showOnboarding;
  bool? glassEffects;
  bool? backgroundImage;
  bool? changeThemeColorWithBackground;
  bool? shouldTestDevicePerformance;

  UserPrefs(
      {this.textDirection,
      this.imageEnabled,
      this.wolofVerseEnabled,
      this.wolofalVerseEnabled,
      this.showFavs,
      this.showOnboarding,
      this.glassEffects,
      this.backgroundImage,
      this.changeThemeColorWithBackground,
      this.shouldTestDevicePerformance});

  late UserPrefs _userPrefs;

  UserPrefs get userPrefs {
    return _userPrefs;
  }

  Future<void> setupUserPrefs() async {
    //get the prefs
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme
    //We're also grabbing other setup info here: language:

    UserPrefs defaultUserPrefs = UserPrefs(
        //Starting off LTR as in English - the relevant setting is PageView(reverse: false) = LTR
        textDirection: false,
        imageEnabled: true,
        wolofVerseEnabled: true,
        wolofalVerseEnabled: true,
        showFavs: false,
        showOnboarding: true,
        glassEffects: true,
        backgroundImage: true,
        changeThemeColorWithBackground: true,
        shouldTestDevicePerformance: true);

    if (!prefs.containsKey('userPrefs')) {
      //Set in-memory copy of prefs
      _userPrefs = defaultUserPrefs;
      //Save prefs to disk
      final _defaultUserPrefs = json.encode({
        'textDirection': false,
        'imageEnabled': true,
        'wolofVerseEnabled': true,
        'wolofalVerseEnabled': true,
        'showFavs': false,
        'showOnboarding': true,
        'glassEffects': true,
        'backgroundImage': true,
        'changeThemeColorWithBackground': true,
        'shouldTestDevicePerformance': true
      });
      prefs.setString('userPrefs', _defaultUserPrefs);
    } else {
      try {
        Map<String?, dynamic> jsonResponse =
            json.decode(prefs.getString('userPrefs')!);

        _userPrefs = UserPrefs(
          textDirection: jsonResponse['textDirection'] as bool,
          imageEnabled: jsonResponse['imageEnabled'] as bool,
          wolofVerseEnabled: jsonResponse['wolofVerseEnabled'] as bool,
          wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'] as bool,
          showFavs: jsonResponse['showFavs'] as bool,
          showOnboarding: jsonResponse['showOnboarding'] as bool,
          glassEffects: jsonResponse['glassEffects'] == null
              ? true
              : jsonResponse['glassEffects'] as bool,
          backgroundImage: jsonResponse['backgroundImage'] == null
              ? true
              : jsonResponse['backgroundImage'] as bool,
          changeThemeColorWithBackground:
              jsonResponse['changeThemeColorWithBackground'] == null
                  ? true
                  : jsonResponse['changeThemeColorWithBackground'] as bool,
          shouldTestDevicePerformance:
              jsonResponse['shouldTestDevicePerformance'] == null
                  ? true
                  : jsonResponse['shouldTestDevicePerformance'] as bool,
        );
      } catch (e) {
        debugPrint(e.toString());
        //Set in-memory copy of prefs
        _userPrefs = defaultUserPrefs;
      }
    }
    if (kDebugMode) {
      debugPrint('setting up user prefs done');
    }

    return;
  }

  Future<void> savePref(String setting, userPref) async {
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    final jsonResponse = json.decode(prefs.getString('userPrefs')!);
    var _tempUserPrefs = UserPrefs(
      textDirection: jsonResponse['textDirection'] as bool,
      imageEnabled: jsonResponse['imageEnabled'] as bool,
      wolofVerseEnabled: jsonResponse['wolofVerseEnabled'] as bool,
      wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'] as bool,
      showFavs: jsonResponse['showFavs'] as bool,
      showOnboarding: jsonResponse['showOnboarding'] as bool,
      glassEffects: jsonResponse['glassEffects'] == null
          ? true
          : jsonResponse['glassEffects'] as bool,
      backgroundImage: jsonResponse['backgroundImage'] == null
          ? true
          : jsonResponse['backgroundImage'] as bool,
      changeThemeColorWithBackground:
          jsonResponse['changeThemeColorWithBackground'] == null
              ? true
              : jsonResponse['changeThemeColorWithBackground'] as bool,
      shouldTestDevicePerformance:
          jsonResponse['shouldTestDevicePerformance'] == null
              ? true
              : jsonResponse['shouldTestDevicePerformance'] as bool,
    );

    //set the incoming setting
    if (setting == 'textDirection') {
      _tempUserPrefs.textDirection = userPref;
    } else if (setting == 'imageEnabled') {
      _tempUserPrefs.imageEnabled = userPref;
    } else if (setting == 'wolofVerseEnabled') {
      _tempUserPrefs.wolofVerseEnabled = userPref;
    } else if (setting == 'wolofalVerseEnabled') {
      _tempUserPrefs.wolofalVerseEnabled = userPref;
    } else if (setting == 'showFavs') {
      _tempUserPrefs.showFavs = userPref;
    } else if (setting == 'showOnboarding') {
      _tempUserPrefs.showOnboarding = userPref;
    } else if (setting == 'glassEffects') {
      _tempUserPrefs.glassEffects = userPref;
    } else if (setting == 'backgroundImage') {
      _tempUserPrefs.backgroundImage = userPref;
    } else if (setting == 'changeThemeColorWithBackground') {
      _tempUserPrefs.changeThemeColorWithBackground = userPref;
    } else if (setting == 'shouldTestDevicePerformance') {
      _tempUserPrefs.shouldTestDevicePerformance = userPref;
    }

    // set it in memory
    _userPrefs = _tempUserPrefs;

    // save it to disk
    final _userPrefsData = json.encode({
      'textDirection': _tempUserPrefs.textDirection,
      'imageEnabled': _tempUserPrefs.imageEnabled,
      'wolofVerseEnabled': _tempUserPrefs.wolofVerseEnabled,
      'wolofalVerseEnabled': _tempUserPrefs.wolofalVerseEnabled,
      'showFavs': _tempUserPrefs.showFavs,
      'showOnboarding': _tempUserPrefs.showOnboarding,
      'glassEffects': _tempUserPrefs.glassEffects,
      'backgroundImage': _tempUserPrefs.backgroundImage,
      'changeThemeColorWithBackground':
          _tempUserPrefs.changeThemeColorWithBackground,
      'shouldTestDevicePerformance': _tempUserPrefs.shouldTestDevicePerformance,
    });
    prefs.setString('userPrefs', _userPrefsData);
    notifyListeners();
  }
}
