import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math';
import 'dart:async';
import 'dart:convert';

class Holiday {
  final String monthID;
  final String year;
  final String westernMonthDate;
  final String wolofMonthDate; // no longer need this
  final String holidayFR;
  final String holidayAS;
  final String holidayRS;

  Holiday({
    required this.monthID,
    required this.year,
    required this.westernMonthDate,
    required this.wolofMonthDate,
    required this.holidayFR,
    required this.holidayAS,
    required this.holidayRS,
  });
}

class Verses {
  final String monthID;
  final String verseAS;
  final String verseRS;
  final String verseRefRS;
  final String verseRefAS;

  Verses({
    required this.monthID,
    required this.verseAS,
    required this.verseRS,
    required this.verseRefRS,
    required this.verseRefAS,
  });
}

class Date {
  final String year;
  final String month;
  final String? wolofMonthRS;
  final String? wolofMonthAS;
  final String westernDate;
  final String wolofDate;
  final List<Holiday>? holidays;

  Date({
    required this.year,
    required this.month,
    this.wolofMonthRS,
    this.wolofMonthAS,
    required this.westernDate,
    required this.wolofDate,
    this.holidays,
  });
}

class Month {
  final String monthID;
  final String monthFR;
  final String monthRS;
  final String monthAS;
  final String? arabicName;
  final String? wolofName;
  final String? wolofalName;
  final List<Verses> verses;

  Month({
    required this.monthID,
    required this.monthFR,
    required this.monthRS,
    required this.monthAS,
    this.arabicName,
    this.wolofName,
    this.wolofalName,
    required this.verses,
  });
}

class Months with ChangeNotifier {
  // You have two main data collections
  // Months view which has 1 month and 1 name but potentially many scriptures

  List<Month> _months = [];

  //Work with a copy of the map, not the map itself
  List<Month> get months {
    return [..._months];
  }

  // Dates, which have 1 date for each calendar but potentialy several or one or no holidays.
  List<Date> _dates = [];

  //Work with a copy of the map, not the map itself
  List<Date> get dates {
    return [..._dates];
  }

  String get isTestingVersion {
    return 'yes';
  }

  String get currentCalendarYear {
    return '2021';
  }

  //   List<Date> get datesToShow {
  //   return _dates.where((date) => date.monthId).toList();
  // }

  Future getData() async {
    //check if the current session still contains the names - if so no need to rebuild
    if (_months.length != 0) {
      return;
    }

    //temporary simple list for holding data
    final List<Month> loadedMonthData = [];
    final List<Date> loadedDateData = [];

    //Get the months from months.json file
    String monthsJSON = await rootBundle.loadString("assets/months.json");
    final monthsData = json.decode(monthsJSON) as List<dynamic>;

    String holidaysJSON = await rootBundle.loadString("assets/holidays.json");
    final holidaysData = json.decode(holidaysJSON) as List<dynamic>?;

    String versesJSON = await rootBundle.loadString("assets/verses.json");
    final versesData = json.decode(versesJSON) as List<dynamic>?;

    String datesJSON = await rootBundle.loadString("assets/dates.json");
    final datesData = json.decode(datesJSON) as List<dynamic>;

    //So we have the info but it's in the wrong format - here map it to our class
    monthsData.forEach((month) {
      loadedMonthData.add(Month(
        monthID: month['monthID'],
        monthFR: month['monthFR'],
        monthRS: month['monthRS'],
        monthAS: month['monthAS'],
        arabicName: month['arabicName'],
        wolofName: month['wolofName'],
        wolofalName: month['wolofalName'],
        verses: versesData!
            .map((entry) => Verses(
                  monthID: entry['monthID'],
                  verseAS: entry['verseAS'],
                  verseRS: entry['verseRS'],
                  verseRefRS: entry['verseRefRS'],
                  verseRefAS: entry['verseRefAS'],
                ))
            .where((element) => element.monthID == month['monthID'])
            .toList(),
      ));
    });

    _months = loadedMonthData;

    datesData.forEach((date) {
      loadedDateData.add(Date(
        year: date['year'],
        month: date['month'],
        wolofMonthAS: date['wolofMonthAS'],
        wolofMonthRS: date['wolofMonthRS'] ?? '',
        westernDate: date['westernDate'],
        wolofDate: date['wolofDate'],
        holidays: holidaysData!
            .map((holiday) => Holiday(
                year: holiday['year'],
                monthID: holiday['monthID'],
                westernMonthDate: holiday['westernMonthDate'],
                wolofMonthDate: holiday['wolofMonthDate'],
                holidayFR: holiday['holidayFR'],
                holidayAS: holiday['holidayAS'],
                holidayRS: holiday['holidayRS']))
            .where((element) =>
                element.monthID == date['month'] &&
                element.year == date['year'] &&
                element.westernMonthDate == date['westernDate'])
            .toList(),
      ));
    });

    _dates = loadedDateData;

    notifyListeners();
  }
}
