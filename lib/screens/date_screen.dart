import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/months.dart';

import '../widgets/date_tile.dart';

class DateScreen extends StatelessWidget {
  static const routeName = '/date-screen';

  @override
  Widget build(BuildContext context) {
    final DateScreenArgs args = ModalRoute.of(context).settings.arguments;

    List<Date> _datesToDisplay = Provider.of<Months>(context, listen: false)
        .dates
        .where((element) =>
            element.month == args.month && element.year == args.year)
        .toList();

    var currentMonth =
        DateFormat("yyyy/M", 'fr_FR').parse('${args.year}/${args.month}');

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy', 'fr_FR').format(currentMonth),
            style: Theme.of(context).textTheme.headline6),
        actions: [
          IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                String monthToGoTo;
                String yearToGoTo;
                if (args.month == '1') {
                  monthToGoTo = '12';
                  yearToGoTo = (int.parse(args.year) - 1).toString();
                } else {
                  monthToGoTo = (int.parse(args.month) - 1).toString();
                  yearToGoTo = args.year;
                }
                Navigator.of(context).popAndPushNamed(DateScreen.routeName,
                    arguments: DateScreenArgs(
                      year: yearToGoTo,
                      month: monthToGoTo,
                    ));
              }),
          IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                String monthToGoTo;
                String yearToGoTo;
                if (args.month == '12') {
                  monthToGoTo = '1';
                  yearToGoTo = (int.parse(args.year) + 1).toString();
                } else {
                  monthToGoTo = (int.parse(args.month) + 1).toString();
                  yearToGoTo = args.year;
                }
                Navigator.of(context).popAndPushNamed(DateScreen.routeName,
                    arguments: DateScreenArgs(
                      year: yearToGoTo,
                      month: monthToGoTo,
                    ));
              }),
        ],
      ),
      body: _datesToDisplay.length == 0
          ? Center(
              child: Text('Fii la arminaat bi yem TT',
                  style: Theme.of(context).textTheme.headline6))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: ListView.builder(
                itemBuilder: (ctx, i) =>
                    DateTile(_datesToDisplay[i], args.year),
                itemCount: _datesToDisplay.length,
              ),
            ),
    );
  }
}
