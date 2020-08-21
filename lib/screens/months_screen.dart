import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:wolof_calendar/screens/date_screen.dart';
import 'package:wolof_calendar/widgets/drawer.dart';

import '../providers/months.dart';

import '../widgets/month_tile.dart';

class MonthsScreen extends StatelessWidget {
  static const routeName = '/months-screen';

  @override
  Widget build(BuildContext context) {
    final monthsData = Provider.of<Months>(context, listen: false).months;

    var now = new DateTime.now();
    // var currentDate = DateFormat('d', 'fr_FR').format(now);
    var currentMonth = DateFormat('M', 'fr_FR').format(now);
    var currentYear = DateFormat('yyyy', 'fr_FR').format(now);
    var formatter = new DateFormat.yMMMMEEEEd('fr_FR');
    String formattedDate = formatter.format(now);

    print('MonthsScreen build');
    return Scaffold(
      appBar: AppBar(
        title:
            Text(formattedDate, style: Theme.of(context).textTheme.headline6),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.of(context).pushNamed(DateScreen.routeName,
                  arguments: DateScreenArgs(
                    // for production:
                    year: currentYear,
                    month: currentMonth,

                    // or for testing:
                    // year: '2021',
                    // month: '1',
                  ));
            },
          ),
        ],
      ),
      drawer: MainDrawer(),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: ListView.builder(
          itemBuilder: (ctx, i) => MonthTile(monthsData[i]),
          itemCount: monthsData.length,
        ),
      ),

      // drawer: SettingsScreen(),
    );
  }
}
