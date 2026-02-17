import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
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
  final String wolofMonthRS;
  final String wolofMonthAS;
  final String westernDate;
  final String wolofDate;
  final List<Holiday>? holidays;

  Date({
    required this.year,
    required this.month,
    required this.wolofMonthRS,
    required this.wolofMonthAS,
    required this.westernDate,
    required this.wolofDate,
    this.holidays,
  });

  // Date copyWith({
  //   String? year,
  //   String? month,
  //   String? wolofMonthRS,
  //   String? wolofMonthAS,
  //   String? westernDate,
  //   String? wolofDate,
  //   List<Holiday>? holidays,
  // }) {
  //   return Date(
  //     year: year ?? this.year,
  //     month: month ?? this.month,
  //     wolofMonthRS: wolofMonthRS ?? this.wolofMonthRS,
  //     wolofMonthAS: wolofMonthAS ?? this.wolofMonthAS,
  //     westernDate: westernDate ?? this.westernDate,
  //     wolofDate: wolofDate ?? this.wolofDate,
  //     holidays: holidays ?? this.holidays,
  //   );
  // }
}

class Month {
  final String monthID;
  final String monthFR;
  final String monthRS;
  final String monthAS;
  final List<Verses> verses;

  Month({
    required this.monthID,
    required this.monthFR,
    required this.monthRS,
    required this.monthAS,
    required this.verses,
  });
}

final List<dynamic> monthNames = [
  {
    "monthID": "1",
    "monthFR": "Janvier",
    "monthRS": "Samwiye",
    "monthAS": "سَمْوِيࣹ",
  },
  {
    "monthID": "2",
    "monthFR": "Février",
    "monthRS": "Fewriye",
    "monthAS": "فࣹوْرِيࣹ",
  },
  {"monthID": "3", "monthFR": "Mars", "monthRS": "Màrs", "monthAS": "مࣵرسّ"},
  {
    "monthID": "4",
    "monthFR": "Avril",
    "monthRS": "Awril",
    "monthAS": "اَوْرِلْ",
  },
  {"monthID": "5", "monthFR": "Mai", "monthRS": "Me", "monthAS": "مࣹ"},
  {"monthID": "6", "monthFR": "Juin", "monthRS": "Suwen", "monthAS": "سُوࣹنْ"},
  {
    "monthID": "7",
    "monthFR": "Juillet",
    "monthRS": "Sulet",
    "monthAS": "سُلࣹتْ",
  },
  {"monthID": "8", "monthFR": "Août", "monthRS": "Ut", "monthAS": "اُتْ"},
  {
    "monthID": "9",
    "monthFR": "Septembre",
    "monthRS": "Sàttumbar",
    "monthAS": "سࣵتُّمْبَرْ",
  },
  {
    "monthID": "10",
    "monthFR": "Octobre",
    "monthRS": "Oktoobar",
    "monthAS": "اࣷڪْتࣷوبَرْ",
  },
  {
    "monthID": "11",
    "monthFR": "Novembre",
    "monthRS": "Nowàmbar",
    "monthAS": "نࣷوࣵمْبَرْ",
  },
  {
    "monthID": "12",
    "monthFR": "Décembre",
    "monthRS": "Desàmbar",
    "monthAS": "دࣹسࣵمْبَرْ",
  },
];

class Months with ChangeNotifier {
  List<Month> _months = [];
  List<Date> _dates = [];
  List<dynamic> _allDatesData = [];
  List<dynamic> _holidaysData = [];

  List<Month> get months => [..._months];
  List<Date> get dates => [..._dates];

  Date get firstDate {
    final date = _allDatesData.first;
    return Date(
      year: date['year'],
      month: date['month'],
      wolofMonthAS: date['wolofMonthAS'] ?? '',
      wolofMonthRS: date['wolofMonthRS'] ?? '',
      westernDate: date['westernDate'],
      wolofDate: date['wolofDate'],
    );
  }

  Date get lastDate {
    final date = _allDatesData.last;
    return Date(
      year: date['year'],
      month: date['month'],
      wolofMonthAS: date['wolofMonthAS'] ?? '',
      wolofMonthRS: date['wolofMonthRS'] ?? '',
      westernDate: date['westernDate'],
      wolofDate: date['wolofDate'],
    );
  }

  Future<void> _loadAllData() async {
    if (_allDatesData.isNotEmpty) return;

    String holidaysJSON = await rootBundle.loadString("assets/holidays.json");
    _holidaysData = json.decode(holidaysJSON) as List<dynamic>;

    String versesJSON = await rootBundle.loadString("assets/verses.json");
    final versesData = json.decode(versesJSON) as List<dynamic>;

    String datesJSON = await rootBundle.loadString("assets/dates.json");
    _allDatesData = json.decode(datesJSON) as List<dynamic>;

    final List<Month> loadedMonthData = [];
    for (var month in monthNames) {
      loadedMonthData.add(
        Month(
          monthID: month['monthID'],
          monthFR: month['monthFR'],
          monthRS: month['monthRS'],
          monthAS: month['monthAS'],
          verses: versesData
              .map(
                (entry) => Verses(
                  monthID: entry['monthID'],
                  verseAS: entry['verseAS'],
                  verseRS: entry['verseRS'],
                  verseRefRS: entry['verseRefRS'],
                  verseRefAS: entry['verseRefAS'],
                ),
              )
              .where((element) => element.monthID == month['monthID'])
              .toList(),
        ),
      );
    }
    _months = loadedMonthData;
  }

  Future<void> fetchInitialDates(DateTime initialDate) async {
    await _loadAllData();
    int initialIndex = _allDatesData.indexWhere(
      (d) =>
          d['year'] == initialDate.year.toString() &&
          d['month'] == initialDate.month.toString() &&
          d['westernDate'] == initialDate.day.toString(),
    );

    if (initialIndex == -1) {
      initialIndex = 0;
    }

    int startIndex = (initialIndex - 60).clamp(0, _allDatesData.length);
    int endIndex = (initialIndex + 60).clamp(0, _allDatesData.length);

    _dates = _getDateRange(startIndex, endIndex);
    notifyListeners();
  }

  Future<bool> loadNextMonth() async {
    if (_dates.isEmpty) return false;
    final lastDate = _dates.last;
    int lastIndex = _allDatesData.indexWhere(
      (d) =>
          d['year'] == lastDate.year &&
          d['month'] == lastDate.month &&
          d['westernDate'] == lastDate.westernDate,
    );

    if (lastIndex == -1 || lastIndex == _allDatesData.length - 1) return false;

    int startIndex = lastIndex + 1;
    int endIndex = (startIndex + 60).clamp(0, _allDatesData.length);

    final newDates = _getDateRange(startIndex, endIndex);
    if (newDates.isEmpty) return false;

    _dates.addAll(newDates);
    notifyListeners();
    return true;
  }

  Future<bool> loadPreviousTwoMonths() async {
    if (_dates.isEmpty) return false;
    final firstDate = _dates.first; // real composed Date objects
    int firstIndex = _allDatesData.indexWhere(
      (d) =>
          d['year'] == firstDate.year &&
          d['month'] == firstDate.month &&
          d['westernDate'] == firstDate.westernDate,
    );

    if (firstIndex == -1 || firstIndex == 0) return false;

    int endIndex = firstIndex;
    int startIndex = (endIndex - 60).clamp(0, _allDatesData.length);

    final newDates = _getDateRange(startIndex, endIndex);
    if (newDates.isEmpty) return false;

    _dates.insertAll(0, newDates);
    notifyListeners();
    return true;
  }

  List<Date> _getDateRange(int startIndex, int endIndex) {
    final List<Date> loadedDateData = [];
    for (int i = startIndex; i < endIndex; i++) {
      var date = _allDatesData[i];
      loadedDateData.add(
        Date(
          year: date['year'],
          month: date['month'],
          wolofMonthAS: date['wolofMonthAS'] ?? '',
          wolofMonthRS: date['wolofMonthRS'] ?? '',
          westernDate: date['westernDate'],
          wolofDate: date['wolofDate'],
          holidays: _holidaysData
              .map(
                (holiday) => Holiday(
                  year: holiday['year'],
                  monthID: holiday['monthID'],
                  westernMonthDate: holiday['westernMonthDate'],
                  wolofMonthDate: holiday['wolofMonthDate'],
                  holidayFR: holiday['holidayFR'],
                  holidayAS: holiday['holidayAS'],
                  holidayRS: holiday['holidayRS'],
                ),
              )
              .where(
                (element) =>
                    element.monthID == date['month'] &&
                    element.year == date['year'] &&
                    element.westernMonthDate == date['westernDate'],
              )
              .toList(),
        ),
      );
    }
    return loadedDateData;
  }
}
