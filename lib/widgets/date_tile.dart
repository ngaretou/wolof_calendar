import 'package:flutter/material.dart';
import '../providers/months.dart';
import 'package:intl/intl.dart';

class DateTile extends StatelessWidget {
  final Date currentDate;
  final String year;
  DateTile(this.currentDate, this.year);

  @override
  Widget build(BuildContext context) {
    String _wolofWeekday;
    String _wolofalWeekday;
    var currentDateTime = DateFormat("yyyy/M/dd", 'fr_FR').parse(
        '${currentDate.year}/${currentDate.month}/${currentDate.westernDate}');

    String currentDayOfWeek =
        DateFormat('EEEE', 'fr_FR').format(currentDateTime);

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

    if (currentDate.westernDate == "1" || currentDate.wolofDate == "1") {
      showMonth = true;
    } else {
      showMonth = false;
    }

    return Column(
      children: [
        showMonth
            ? Container(
                child: Align(
                alignment: Alignment.center,
                child: Text(
                    currentDate.wolofMonthRS + " | " + currentDate.wolofMonthAS,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontFamily: "Harmattan", fontSize: 30)),
              ))
            : SizedBox(
                height: 0,
              ),
        Card(
          elevation: 5,
          color: currentDate.holidays.length >= 1
              ? Theme.of(context).accentColor
              : Theme.of(context).cardColor,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 15),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currentDate.westernDate,
                        style: Theme.of(context).textTheme.headline6),
                    Column(children: [
                      Text(currentDayOfWeek,
                          style: Theme.of(context).textTheme.headline6),
                      Text(_wolofWeekday,
                          style: Theme.of(context).textTheme.headline6),
                      Text(_wolofalWeekday,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontFamily: "Harmattan", fontSize: 30)),
                    ]),
                    Text(currentDate.wolofDate,
                        style: Theme.of(context).textTheme.headline6),
                  ],
                ),
                currentDate.holidays.length >= 1
                    ? Divider(
                        thickness: 3,
                      )
                    : SizedBox(
                        height: 0,
                      ),
                currentDate.holidays.length >= 1
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: currentDate.holidays.length,
                        itemBuilder: (BuildContext context, int i) => Container(
                            child: Column(
                          children: [
                            Text(currentDate.holidays[i].holidayFR,
                                style: Theme.of(context).textTheme.headline6),
                            Text(currentDate.holidays[i].holidayRS,
                                style: Theme.of(context).textTheme.headline6),
                            Text(currentDate.holidays[i].holidayAS,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                        fontFamily: "Harmattan", fontSize: 30)),
                            currentDate.holidays.length - (i + 1) != 0
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

          // child: Column(
          //   children: [
          //     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          //       Text(currentDate.westernDate,
          //           style: Theme.of(context).textTheme.headline6),
          //       Text(currentDayOfWeek,
          //           style: Theme.of(context).textTheme.headline6),
          //       Text(currentDate.wolofDate,
          //           style: Theme.of(context).textTheme.headline6),
          //     ]),
          //     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //       Text(_wolofWeekday, style: Theme.of(context).textTheme.headline6),
          //     ]),
          //     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //       Text(_wolofalWeekday,
          //           style: Theme.of(context)
          //               .textTheme
          //               .headline6
          //               .copyWith(fontFamily: "Harmattan")),
          //     ]),
          //     currentDate.holidays.length >= 1
          //         ? Divider(
          //             thickness: 3,
          //           )
          //         : SizedBox(
          //             height: 0,
          //           ),
          //     currentDate.holidays.length >= 1
          //         ? ListView.builder(
          //             physics: NeverScrollableScrollPhysics(),
          //             shrinkWrap: true,
          //             scrollDirection: Axis.vertical,
          //             itemCount: currentDate.holidays.length,
          //             itemBuilder: (BuildContext context, int i) => Container(
          //                 child: Padding(
          //               padding: EdgeInsets.only(top: 10),
          //               child: Align(
          //                   alignment: Alignment.center,
          //                   child: Text(currentDate.holidays[i].holidayFR,
          //                       style: Theme.of(context).textTheme.headline6)),
          //             )),
          //           )
          //         : SizedBox(height: 1),
          //     // : Text(''),
          //   ],
          // ),
        ),
      ],
    );
  }
}
