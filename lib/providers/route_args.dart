import '../providers/months.dart';

class DateScreenArgs {
  String? year;
  String? month;
  String? date;

  DateScreenArgs({this.year, this.month, this.date});
}

class MonthScriptureScreenArgs {
  final Month data;

  MonthScriptureScreenArgs({required this.data});
}
