// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Locale? userLocale;

  Future<void> setLocale(String incomingLocale) async {
    print('setLocale in theme.dart');
    switch (incomingLocale) {
      case 'en':
        userLocale = const Locale('en', '');
        notifyListeners();
        break;
      case 'fr':
        userLocale = const Locale('fr', '');
        notifyListeners();
        break;
      case 'fr_CH':
        userLocale = const Locale('fr', 'CH');
        notifyListeners();
        break;
      default:
    }

    //get prefs from disk
    final prefs = await SharedPreferences.getInstance();
    //save userLang to disk
    String userLang = json.encode(incomingLocale);
    prefs.setString('userLang', userLang);
  }
}
