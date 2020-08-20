import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CardPrefs with ChangeNotifier {
  bool textDirection;
  bool imageEnabled;
  bool wolofVerseEnabled;
  bool wolofalVerseEnabled;
  bool showFavs;
  bool showOnboarding;

  CardPrefs({
    this.textDirection,
    this.imageEnabled,
    this.wolofVerseEnabled,
    this.wolofalVerseEnabled,
    this.showFavs,
    this.showOnboarding,
  });

  CardPrefs _cardPrefs;

  CardPrefs get cardPrefs {
    return _cardPrefs;
  }

  Future<void> setupCardPrefs() async {
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    //if there's no userTheme, it's the first time they've run the app, so give them lightTheme
    //We're also grabbing other setup info here: language:

    if (!prefs.containsKey('cardPrefs')) {
      CardPrefs defaultCardPrefs = CardPrefs(
        //Starting off LTR as in English - the relevant setting is PageView(reverse: false) = LTR
        textDirection: false,
        imageEnabled: true,
        wolofVerseEnabled: true,
        wolofalVerseEnabled: true,
        showFavs: false,
        showOnboarding: true,
      );
      //Set in-memory copy of prefs
      _cardPrefs = defaultCardPrefs;
      //Save prefs to disk
      final _defaultCardPrefs = json.encode({
        'textDirection': false,
        'imageEnabled': true,
        'wolofVerseEnabled': true,
        'wolofalVerseEnabled': true,
        'showFavs': false,
        'showOnboarding': true,
      });
      prefs.setString('cardPrefs', _defaultCardPrefs);
    } else {
      final jsonResponse =
          json.decode(prefs.getString('cardPrefs')) as Map<String, Object>;
      _cardPrefs = CardPrefs(
        textDirection: jsonResponse['textDirection'],
        imageEnabled: jsonResponse['imageEnabled'],
        wolofVerseEnabled: jsonResponse['wolofVerseEnabled'],
        wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'],
        showFavs: jsonResponse['showFavs'],
        showOnboarding: jsonResponse['showOnboarding'],
      );

      // notifyListeners();
    }
  }

  Future<void> savePref(String setting, userPref) async {
    //get the prefs
    final prefs = await SharedPreferences.getInstance();
    final jsonResponse =
        json.decode(prefs.getString('cardPrefs')) as Map<String, Object>;
    var _tempCardPrefs = CardPrefs(
      textDirection: jsonResponse['textDirection'],
      imageEnabled: jsonResponse['imageEnabled'],
      wolofVerseEnabled: jsonResponse['wolofVerseEnabled'],
      wolofalVerseEnabled: jsonResponse['wolofalVerseEnabled'],
      showFavs: jsonResponse['showFavs'],
      showOnboarding: jsonResponse['showOnboarding'],
    );

    //set the incoming setting
    if (setting == 'textDirection') {
      _tempCardPrefs.textDirection = userPref;
    } else if (setting == 'imageEnabled') {
      _tempCardPrefs.imageEnabled = userPref;
    } else if (setting == 'wolofVerseEnabled') {
      _tempCardPrefs.wolofVerseEnabled = userPref;
    } else if (setting == 'wolofalVerseEnabled') {
      _tempCardPrefs.wolofalVerseEnabled = userPref;
    } else if (setting == 'showFavs') {
      _tempCardPrefs.showFavs = userPref;
    } else if (setting == 'showOnboarding') {
      _tempCardPrefs.showOnboarding = userPref;
    }

    //now set it in memory
    _cardPrefs = _tempCardPrefs;
    // notifyListeners();
    //now save it to disk
    final _userPrefs = json.encode({
      'textDirection': _tempCardPrefs.textDirection,
      'imageEnabled': _tempCardPrefs.imageEnabled,
      'wolofVerseEnabled': _tempCardPrefs.wolofVerseEnabled,
      'wolofalVerseEnabled': _tempCardPrefs.wolofalVerseEnabled,
      'showFavs': _tempCardPrefs.showFavs,
      'showOnboarding': _tempCardPrefs.showOnboarding,
    });
    prefs.setString('cardPrefs', _userPrefs);
  }
}
