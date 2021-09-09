import 'dart:async';

import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbols.dart' as intl;
import 'package:intl/date_symbol_data_custom.dart' as date_symbol_data_custom;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Extended set of localized date/time patterns for locale fr.
/// from intl/date_time_patterns.dart
const woLocaleDatePatterns = {
  'd': 'd', // DAY
  'E': 'EEE', // ABBR_WEEKDAY
  'EEEE': 'EEEE', // WEEKDAY
  'LLL': 'LLL', // ABBR_STANDALONE_MONTH
  'LLLL': 'LLLL', // STANDALONE_MONTH
  'M': 'L', // NUM_MONTH
  'Md': 'dd/MM', // NUM_MONTH_DAY
  'MEd': 'EEE dd/MM', // NUM_MONTH_WEEKDAY_DAY
  'MMM': 'LLL', // ABBR_MONTH
  'MMMd': 'd MMM', // ABBR_MONTH_DAY
  'MMMEd': 'EEE d MMM', // ABBR_MONTH_WEEKDAY_DAY
  'MMMM': 'LLLL', // MONTH
  'MMMMd': 'd MMMM', // MONTH_DAY
  'MMMMEEEEd': 'EEEE d MMMM', // MONTH_WEEKDAY_DAY
  'QQQ': 'QQQ', // ABBR_QUARTER
  'QQQQ': 'QQQQ', // QUARTER
  'y': 'y', // YEAR
  'yM': 'MM/y', // YEAR_NUM_MONTH
  'yMd': 'dd/MM/y', // YEAR_NUM_MONTH_DAY
  'yMEd': 'EEE dd/MM/y', // YEAR_NUM_MONTH_WEEKDAY_DAY
  'yMMM': 'MMM y', // YEAR_ABBR_MONTH
  'yMMMd': 'd MMM y', // YEAR_ABBR_MONTH_DAY
  'yMMMEd': 'EEE d MMM y', // YEAR_ABBR_MONTH_WEEKDAY_DAY
  'yMMMM': 'MMMM y', // YEAR_MONTH
  'yMMMMd': 'd MMMM y', // YEAR_MONTH_DAY
  'yMMMMEEEEd': 'EEEE d MMMM y', // YEAR_MONTH_WEEKDAY_DAY
  'yQQQ': 'QQQ y', // YEAR_ABBR_QUARTER
  'yQQQQ': 'QQQQ y', // YEAR_QUARTER
  'H': 'HH \'h\'', // HOUR24
  'Hm': 'HH:mm', // HOUR24_MINUTE
  'Hms': 'HH:mm:ss', // HOUR24_MINUTE_SECOND
  'j': 'HH \'h\'', // HOUR
  'jm': 'HH:mm', // HOUR_MINUTE
  'jms': 'HH:mm:ss', // HOUR_MINUTE_SECOND
  'jmv': 'HH:mm v', // HOUR_MINUTE_GENERIC_TZ
  'jmz': 'HH:mm z', // HOUR_MINUTETZ
  'jz': 'HH \'h\' z', // HOURGENERIC_TZ
  'm': 'm', // MINUTE
  'ms': 'mm:ss', // MINUTE_SECOND
  's': 's', // SECOND
  'v': 'v', // ABBR_GENERIC_TZ
  'z': 'z', // ABBR_SPECIFIC_TZ
  'zzzz': 'zzzz', // SPECIFIC_TZ
  'ZZZZ': 'ZZZZ' // ABBR_UTC_TZ
};

// Date/time formatting symbols for locale fr.
// from intl/date_symbol_data_local.dart'
const woDateSymbols = {
  'NAME': "wo",
  'ERAS': const ['av. J.-C.', 'ap. J.-C.'],
  'ERANAMES': const ['avant Jésus-Christ', 'après Jésus-Christ'],
  'NARROWMONTHS': const [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D'
  ],
  'STANDALONENARROWMONTHS': const [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D'
  ],
  'MONTHS': const [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre'
  ],
  'STANDALONEMONTHS': const [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre'
  ],
  'SHORTMONTHS': const [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.'
  ],
  'STANDALONESHORTMONTHS': const [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.'
  ],
  'WEEKDAYS': const [
    'dimanche',
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi'
  ],
  'STANDALONEWEEKDAYS': const [
    'dimanche',
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi'
  ],
  'SHORTWEEKDAYS': const [
    'dim.',
    'lun.',
    'mar.',
    'mer.',
    'jeu.',
    'ven.',
    'sam.'
  ],
  'STANDALONESHORTWEEKDAYS': const [
    'dim.',
    'lun.',
    'mar.',
    'mer.',
    'jeu.',
    'ven.',
    'sam.'
  ],
  'NARROWWEEKDAYS': const ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
  'STANDALONENARROWWEEKDAYS': const ['D', 'L', 'M', 'M', 'J', 'V', 'S'],
  'SHORTQUARTERS': const ['T1', 'T2', 'T3', 'T4'],
  'QUARTERS': const [
    '1er trimestre',
    '2e trimestre',
    '3e trimestre',
    '4e trimestre'
  ],
  'AMPMS': const ['AM', 'PM'],
  'DATEFORMATS': const ['EEEE d MMMM y', 'd MMMM y', 'd MMM y', 'dd/MM/y'],
  'TIMEFORMATS': const ['HH:mm:ss zzzz', 'HH:mm:ss z', 'HH:mm:ss', 'HH:mm'],
  'DATETIMEFORMATS': const [
    '{1} \'à\' {0}',
    '{1} \'à\' {0}',
    '{1} \'à\' {0}',
    '{1} {0}'
  ],
  'FIRSTDAYOFWEEK': 0,
  'WEEKENDRANGE': const [5, 6],
  'FIRSTWEEKCUTOFFDAY': 3
};

// begin Delegate
class _WoMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _WoMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'wo';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    print(locale.toString() + " in wo_intl.dart");
    final String localeName = intl.Intl.canonicalizedLocale(locale.toString());
    print(localeName + ' localeName');
    date_symbol_data_custom.initializeDateFormattingCustom(
      locale: localeName,
      // patterns: nnLocaleDatePatterns,
      patterns: woLocaleDatePatterns,
      symbols: intl.DateSymbols.deserializeFromMap(woDateSymbols),
    );

    return SynchronousFuture<MaterialLocalizations>(
      WoMaterialLocalizations(
        localeName: localeName,
        // The `intl` library's NumberFormat class is generated from CLDR data
        // (see https://github.com/dart-lang/intl/blob/master/lib/number_symbols_data.dart).
        // Unfortunately, there is no way to use a locale that isn't defined in
        // this map and the only way to work around this is to use a listed
        // locale's NumberFormat symbols. So, here we use the number formats
        // for 'en_US' instead.
        decimalFormat: intl.NumberFormat('#,##0.###', 'en_US'),
        twoDigitZeroPaddedFormat: intl.NumberFormat('00', 'en_US'),
        // DateFormat here will use the symbols and patterns provided in the
        // `date_symbol_data_custom.initializeDateFormattingCustom` call above.
        // However, an alternative is to simply use a supported locale's
        // DateFormat symbols, similar to NumberFormat above.
        fullYearFormat: intl.DateFormat('y', localeName),
        compactDateFormat: intl.DateFormat('yMd', localeName),
        shortDateFormat: intl.DateFormat('yMMMd', localeName),
        mediumDateFormat: intl.DateFormat('EEE, MMM d', localeName),
        longDateFormat: intl.DateFormat('EEEE, MMMM d, y', localeName),
        yearMonthFormat: intl.DateFormat('MMMM y', localeName),
        shortMonthDayFormat: intl.DateFormat('MMM d'),
      ),
    );
  }

  @override
  bool shouldReload(_WoMaterialLocalizationsDelegate old) => false;
}
// end Delegate

// begin Localizations
class WoMaterialLocalizations extends MaterialLocalizationFr {
  const WoMaterialLocalizations({
    String localeName = 'wo',
    required intl.DateFormat fullYearFormat,
    required intl.DateFormat compactDateFormat,
    required intl.DateFormat shortDateFormat,
    required intl.DateFormat mediumDateFormat,
    required intl.DateFormat longDateFormat,
    required intl.DateFormat yearMonthFormat,
    required intl.DateFormat shortMonthDayFormat,
    required intl.NumberFormat decimalFormat,
    required intl.NumberFormat twoDigitZeroPaddedFormat,
  }) : super(
          localeName: localeName,
          fullYearFormat: fullYearFormat,
          compactDateFormat: compactDateFormat,
          shortDateFormat: shortDateFormat,
          mediumDateFormat: mediumDateFormat,
          longDateFormat: longDateFormat,
          yearMonthFormat: yearMonthFormat,
          shortMonthDayFormat: shortMonthDayFormat,
          decimalFormat: decimalFormat,
          twoDigitZeroPaddedFormat: twoDigitZeroPaddedFormat,
        );

  static const LocalizationsDelegate<MaterialLocalizations> delegate =
      _WoMaterialLocalizationsDelegate();
}
