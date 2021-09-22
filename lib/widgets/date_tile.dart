import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/months.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'month_header.dart';

class DateTile extends StatefulWidget {
  final Date currentDate;

  DateTile(this.currentDate);

  @override
  _DateTileState createState() => _DateTileState();
}

class _DateTileState extends State<DateTile> {
  @override
  Widget build(BuildContext context) {
    final _screenwidth = MediaQuery.of(context).size.width;
    final bool _isPhone =
        (_screenwidth + MediaQuery.of(context).size.height) <= 1400;

    final monthData = Provider.of<Months>(context, listen: false)
        .months
        .where((month) => month.monthID == widget.currentDate.month)
        .toList();

    late String _wolofWeekday;
    late String _wolofalWeekday;
    DateTime currentDateTime = DateFormat("yyyy/M/dd", 'fr_FR').parse(
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

//Set up whether or not to show the month header or not
    bool showMonth;

    if (widget.currentDate.westernDate == "1" ||
        widget.currentDate.wolofDate == "1") {
      showMonth = true;
    } else {
      showMonth = false;
    }

    //TextStyles

    TextStyle head6 = Theme.of(context).textTheme.headline6!;
    //end TextStyles

    return Column(
      children: [
        //Month headers
        showMonth
            ? MonthHeader(
                currentDate: widget.currentDate,
                monthData: monthData,
              )
            : SizedBox(
                height: 0,
              ),
        //End month header

        //Regular date card
        Padding(
          padding: _isPhone
              ? EdgeInsets.symmetric(horizontal: 10, vertical: 0)
              : EdgeInsets.symmetric(
                  horizontal: _screenwidth / 20, vertical: 0),
          child: Card(
            elevation: 1,
            color: widget.currentDate.holidays!.length >= 1
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).cardColor,

            //Western date, column of weekdays, Wolof date
            child: Padding(
                padding:
                    EdgeInsets.only(top: 10.0, bottom: 10, left: 20, right: 20),
                child: Column(children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.currentDate.westernDate, style: head6),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(_wolofWeekday, style: head6),
                              Text(
                                _wolofalWeekday,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        fontFamily: "Harmattan", fontSize: 30),
                                textDirection: ui.TextDirection.rtl,
                              ),
                              Text(currentDayOfWeek, style: head6),
                              SizedBox(
                                height: 16,
                              ),
                            ]),
                        Text(widget.currentDate.wolofDate, style: head6),
                      ],
                    ),
                  ),
                  //Holiday extension to the card
                  widget.currentDate.holidays!.length >= 1
                      ? Divider(
                          thickness: 4,
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  if (widget.currentDate.holidays!.length >= 1)
                    Container(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: widget.currentDate.holidays!.length,
                        itemBuilder: (BuildContext context, int i) => Container(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.currentDate.holidays![i].holidayRS,
                                style: head6),
                            Text(widget.currentDate.holidays![i].holidayAS,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        fontFamily: "Harmattan", fontSize: 30)),
                            Text(
                              widget.currentDate.holidays![i].holidayFR,
                              style: head6,
                            ),
                            widget.currentDate.holidays!.length - (i + 1) != 0
                                ? Divider(thickness: 3, height: 40)
                                : SizedBox(
                                    height: 0,
                                  ),
                          ],
                        )),
                      ),
                    ),
                ])),
          ),
        ),
      ],
    );
  }
}
