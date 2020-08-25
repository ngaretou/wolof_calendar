import '../providers/months.dart';

class DateScreenArgs {
  final String year;
  final String month;
  final String date;

  DateScreenArgs({this.year, this.month, this.date});
}

class MonthScriptureScreenArgs {
  final Month data;

  MonthScriptureScreenArgs({this.data});
}
