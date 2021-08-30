import '../providers/months.dart';

class DateScreenArgs {
  final String year;
  final String month;
  final String date;

  DateScreenArgs({required this.year, required this.month, required this.date});
}

class MonthScriptureScreenArgs {
  final Month data;

  MonthScriptureScreenArgs({required this.data});
}
