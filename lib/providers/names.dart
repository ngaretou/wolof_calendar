import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

class DivineName with ChangeNotifier {
  final String id;
  final String arabicName;
  final String wolofName;
  final String wolofalName;
  final String wolofVerse;
  final String wolofVerseRef;
  final String wolofalVerse;
  final String wolofalVerseRef;
  String img;
  bool isFav;

  DivineName({
    @required this.id,
    @required this.arabicName,
    @required this.wolofName,
    @required this.wolofalName,
    @required this.wolofVerse,
    @required this.wolofVerseRef,
    @required this.wolofalVerse,
    @required this.wolofalVerseRef,
    this.img,
    this.isFav = false,
  });

//   Future<void> toggleFavoriteStatus() async {
//     List<dynamic> _favList;
//     //Get the favorites list from disk
//     final prefs = await SharedPreferences.getInstance();
//     //check if this is the first time a user has set prefs - if so empty list
//     if (!prefs.containsKey('favList')) {
//       _favList = [];
//     } else {
//       //or if not get that list in memory so we can use it
//       _favList = json.decode(prefs.getString('favList')) as List<dynamic>;
//     }

//     //set the model in memory to true or false and also add the id of the current name to the list or remove it
//     if (isFav) {
//       isFav = false;
//       _favList.remove(id);
//     } else if (!isFav) {
//       isFav = true;
//       _favList.add(id);
//     }
//     notifyListeners();
// //Now store the list back to disk
//     final favList = json.encode(_favList);
//     prefs.setString('favList', favList);
//   }
}

class DivineNames with ChangeNotifier {
  int _lastPageViewed;

  List<DivineName> _names = [];

  //Work with a copy of the map, not the map itself
  List<DivineName> get names {
    return [..._names];
  }

  List<DivineName> get favoriteNames {
    return _names.where((name) => name.isFav).toList();
  }

  int get lastPageViewed {
    return _lastPageViewed;
  }

  // get a random number for the image
  String get randomNumber {
    Random rnd = new Random();
    int min = 1;
    int max = 10;
    // rnd =
    var result = min + rnd.nextInt(max - min);
    var r = result.toString();
    return r;
  }

  Future getDivineNames() async {
    var temp = await getLastNameViewed();
    temp == null ? temp = 0 : _lastPageViewed = temp;
    //check if the current session still contains the names - if so no need to rebuild
    if (_names.length != 0) {
      return;
    }

    //Get the divine names from names.json file
    String jsonString = await rootBundle.loadString("assets/names.json");
    final jsonResponse = json.decode(jsonString) as List<dynamic>;

    //So we have the info but it's in the wrong format - here map it to our class
    _names = jsonResponse
        .map((name) => DivineName(
              id: name['id'].toString(),
              arabicName: name['arabicName'],
              wolofName: name['wolofName'],
              wolofalName: name['wolofalName'],
              wolofVerse: name['wolofVerse'],
              wolofVerseRef: name['wolofVerseRef'],
              wolofalVerse: name['wolofalVerse'],
              wolofalVerseRef: name['wolofalVerseRef'],
              img: randomNumber,
            ))
        .toList();

    //The names come from the names.json but the favs come from sharedprefs,
    //so we populate the copy of names that lives in session memory with the user's info here

    //Get the user's favorite list from sharedprefs
    List _favList;
    final prefs = await SharedPreferences.getInstance();
    !prefs.containsKey('favList')
        ? _favList = []
        : _favList = json.decode(prefs.getString('favList')) as List;

    //Loop over the names list and fill in the values
    _names.forEach((name) {
      _favList.contains(name.id) ? name.isFav = true : name.isFav = false;
    });
    notifyListeners();
  }

  Future<void> saveLastNameViewed(lastPageViewed) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = json.encode(lastPageViewed.toString());
    prefs.setString('lastNameViewed', jsonData);
  }

  Future<int> getLastNameViewed() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('lastNameViewed')) {
      return 0;
    } else {
      final storedValue = json.decode(prefs.getString('lastNameViewed'));
      int _lastNameViewed = int.parse(storedValue);
      return _lastNameViewed;
    }
  }

  Future<void> toggleFavoriteStatus(id) async {
    List<dynamic> _favList;
    //Get the favorites list from disk
    final prefs = await SharedPreferences.getInstance();
    //check if this is the first time a user has set prefs - if so empty list
    if (!prefs.containsKey('favList')) {
      _favList = [];
    } else {
      //or if not get that list in memory so we can use it
      _favList = json.decode(prefs.getString('favList')) as List<dynamic>;
    }
    var currentName = _names.firstWhere((name) => name.id == id);
    //set the model in memory to true or false and also add the id of the current name to the list or remove it
    if (currentName.isFav) {
      currentName.isFav = false;
      _favList.remove(id);
    } else if (!currentName.isFav) {
      currentName.isFav = true;
      _favList.add(id);
    }
    notifyListeners();
//Now store the list back to disk
    final favList = json.encode(_favList);
    prefs.setString('favList', favList);
  }
}
