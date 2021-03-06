import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import './date_screen.dart';

import '../providers/months.dart';
import '../providers/route_args.dart';

import '../widgets/month_tile.dart';
import '../widgets/drawer.dart';

class MonthsScreen extends StatelessWidget {
  static const routeName = '/months-screen';

  @override
  Widget build(BuildContext context) {
    final monthsData = Provider.of<Months>(context, listen: false).months;
    // final coverData = Provider.of<Months>(context, listen: false).verses;
    var now = new DateTime.now();
    var currentDate = DateFormat('d', 'fr_FR').format(now);
    var currentMonth = DateFormat('M', 'fr_FR').format(now);
    var currentYear = DateFormat('yyyy', 'fr_FR').format(now);
    var formatter = new DateFormat.yMMMd('fr_FR');
    String formattedDate = formatter.format(now);
    final bool _isPhone = (MediaQuery.of(context).size.width +
            MediaQuery.of(context).size.height) <=
        1400;
    final screenwidth = MediaQuery.of(context).size.width;
    print(screenwidth);
    return Scaffold(
        appBar: AppBar(
          title: Text(formattedDate),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.of(context).pushNamed(DateScreen.routeName,
                    arguments: DateScreenArgs(
                        year: currentYear,
                        month: currentMonth,
                        date: currentDate));
              },
            ),
          ],
        ),
        drawer: MainDrawer(),
        body: Center(
          child: Container(
            width: (kIsWeb && screenwidth > 1000) ? 1000 : double.infinity,
            child: CustomScrollView(slivers: [
              SliverPadding(
                padding: _isPhone
                    ? EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                    : EdgeInsets.symmetric(
                        horizontal: screenwidth / 16,
                        vertical: screenwidth / 25),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // MonthTile("cover"),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) => MonthTile(monthsData[i]),
                      itemCount: monthsData.length,
                    ),
                  ]),
                ),

                // drawer: SettingsScreen(),
              )
            ]),
          ),
        ));
  }
}
