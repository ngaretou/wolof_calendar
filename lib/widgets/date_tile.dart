import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/months.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class DateTile extends StatefulWidget {
  final Date currentDate;
  // final String year;
  DateTile(this.currentDate);

  @override
  _DateTileState createState() => _DateTileState();
}

class _DateTileState extends State<DateTile> {
  @override
  Widget build(BuildContext context) {
    final monthData = Provider.of<Months>(context, listen: false)
        .months
        .where((month) => month.monthID == widget.currentDate.month)
        .toList();

    String _wolofWeekday;
    String _wolofalWeekday;
    var currentDateTime = DateFormat("yyyy/M/dd", 'fr_FR').parse(
        '${widget.currentDate.year}/${widget.currentDate.month}/${widget.currentDate.westernDate}');

    String currentDayOfWeek =
        DateFormat('EEEE', 'fr_FR').format(currentDateTime);
    // String currentWesternMonth =
    //     DateFormat('MMMM', 'fr_FR').format(currentDateTime);

    switch (currentDateTime.weekday) {
      //1 = Monday
      case 1:
        {
          _wolofWeekday = "altine";
          _wolofalWeekday = "اَلْتِنࣹ";
        }
        break;
      case 2:
        {
          _wolofWeekday = "talaata";
          _wolofalWeekday = "تَلَاتَ";
        }
        break;
      case 3:
        {
          _wolofWeekday = "àllarba";
          _wolofalWeekday = "اࣵلَّرْبَ";
        }
        break;
      case 4:
        {
          _wolofWeekday = "alxames";
          _wolofalWeekday = "اَلْخَمࣹسْ";
        }
        break;
      case 5:
        {
          _wolofWeekday = "àjjuma";
          _wolofalWeekday = "اࣵجُّمَ";
        }
        break;
      case 6:
        {
          _wolofWeekday = "gaawu";
          _wolofalWeekday = "گَاوُ";
        }
        break;
      case 7:
        {
          _wolofWeekday = "dibéer";
          _wolofalWeekday = "دِبࣺيرْ";
        }
        break;
    }

    bool showMonth;

    if (widget.currentDate.westernDate == "1" ||
        widget.currentDate.wolofDate == "1") {
      showMonth = true;
    } else {
      showMonth = false;
    }
    TextStyle headerStyle = TextStyle(
        fontFamily: "Harmattan",
        fontSize: 25,
        color: Theme.of(context).textTheme.headline6.color);

    return Column(
      children: [
        showMonth
            ? Container(
                color: Colors.white24,
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(monthData[0].monthRS, style: headerStyle),
                      Text(widget.currentDate.wolofMonthRS, style: headerStyle),
                    ]),
              )
            : SizedBox(
                height: 0,
              ),
        showMonth
            ? Container(
                color: Colors.white24,
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        monthData[0].monthAS,
                        style: headerStyle,
                        textDirection: ui.TextDirection.rtl,
                      ),

                      Text(
                        widget.currentDate.wolofMonthAS,
                        style: headerStyle,
                        // locale: Locale('ar_AR'),
                        textDirection: ui.TextDirection.rtl,
                      ),
                      // Directionality(
                      //     textDirection: TextDirection.RTL,
                      //     child: Text(currentDate.wolofMonthAS,
                      //         style: headerStyle)),
                    ]),
              )
            : SizedBox(
                height: 0,
              ),
        Card(
          elevation: 5,
          color: widget.currentDate.holidays.length >= 1
              ? Theme.of(context).accentColor
              : Theme.of(context).cardColor,
          child: Padding(
              padding: EdgeInsets.only(top: 10.0, left: 20, right: 20),
              child: Column(children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.currentDate.westernDate,
                          style: Theme.of(context).textTheme.headline6),
                      Column(children: [
                        Text(currentDayOfWeek,
                            style: Theme.of(context).textTheme.headline6),
                        Text(_wolofWeekday,
                            style: Theme.of(context).textTheme.headline6),
                        Text(
                          _wolofalWeekday,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontFamily: "Harmattan", fontSize: 30),
                          textDirection: ui.TextDirection.rtl,
                        ),
                      ]),
                      Text(widget.currentDate.wolofDate,
                          style: Theme.of(context).textTheme.headline6),
                    ],
                  ),
                ),
                widget.currentDate.holidays.length >= 1
                    ? Divider(
                        thickness: 3,
                      )
                    : SizedBox(
                        height: 0,
                      ),
                widget.currentDate.holidays.length >= 1
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: widget.currentDate.holidays.length,
                        itemBuilder: (BuildContext context, int i) => Container(
                            child: Column(
                          children: [
                            Text(widget.currentDate.holidays[i].holidayFR,
                                style: Theme.of(context).textTheme.headline6),
                            Text(widget.currentDate.holidays[i].holidayRS,
                                style: Theme.of(context).textTheme.headline6),
                            Text(widget.currentDate.holidays[i].holidayAS,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        fontFamily: "Harmattan", fontSize: 30)),
                            widget.currentDate.holidays.length - (i + 1) != 0
                                ? Divider(
                                    thickness: 3,
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                          ],
                        )),
                      )
                    : SizedBox(height: 0),
              ])),
        ),
      ],
    );
  }
}
