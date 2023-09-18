import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

import '../providers/months.dart';
import 'month_header.dart';
// import 'glass_card.dart';

class DateTile extends StatelessWidget {
  final Date currentDate;
  final double contentColWidth;
  final double headerImageHeight;
  final EdgeInsets adaptiveMargin;
  final bool isPhone;
  const DateTile({
    Key? key,
    required this.currentDate,
    required this.contentColWidth,
    required this.headerImageHeight,
    required this.adaptiveMargin,
    required this.isPhone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('date tile build');
    //viewing setup

    ScrollController holidayScrollController = ScrollController();

    final monthData = Provider.of<Months>(context, listen: false)
        .months
        .where((month) => month.monthID == currentDate.month)
        .toList();

    late String wolofWeekday;
    late String wolofalWeekday;
    DateTime currentDateTime = DateFormat("yyyy/M/dd", 'fr_FR').parse(
        '${currentDate.year}/${currentDate.month}/${currentDate.westernDate}');

    String currentDayOfWeek =
        DateFormat('EEEE', 'fr_FR').format(currentDateTime);

    switch (currentDateTime.weekday) {
      //1 = Monday, etc
      case 1:
        {
          wolofWeekday = "altine";
          wolofalWeekday = "اَلْتِنࣹ";
        }
        break;
      case 2:
        {
          wolofWeekday = "talaata";
          wolofalWeekday = "تَلَاتَ";
        }
        break;
      case 3:
        {
          wolofWeekday = "àllarba";
          wolofalWeekday = "اࣵلَّرْبَ";
        }
        break;
      case 4:
        {
          wolofWeekday = "alxames";
          wolofalWeekday = "اَلْخَمࣹسْ";
        }
        break;
      case 5:
        {
          wolofWeekday = "àjjuma";
          wolofalWeekday = "اࣵجُّمَ";
        }
        break;
      case 6:
        {
          wolofWeekday = "gaawu";
          wolofalWeekday = "گَاوُ";
        }
        break;
      case 7:
        {
          wolofWeekday = "dibéer";
          wolofalWeekday = "دِبࣺيرْ";
        }
        break;
    }

    //Set up whether or not to show the month header or not
    bool showMonth;

    if (currentDate.westernDate == "1" || currentDate.wolofDate == "1") {
      showMonth = true;
    } else {
      showMonth = false;
    }

    //TextStyles
    TextStyle head6 = Theme.of(context).textTheme.titleLarge!;
    //end TextStyles

    /* Fall 2021 Flutter 2.5.1, the AS text boxes get squished by Flutter on on web. 
    Assuming this will get fixed in a future release. 
    This rtlTextFixer hacks any RTL text with a space on either side only if on web. 
     */
    String rtlTextFixer(String textToFix) {
      late String correctedText;
      if (kIsWeb || Platform.isIOS || Platform.isAndroid) {
        correctedText = '$textToFix ';
      } else {
        correctedText = textToFix;
      }
      return correctedText;
    }

    final Color tintColor =
        currentDate.holidays!.isNotEmpty || wolofWeekday == "dibéer"
            //there is a holiday or Sunday
            ? Theme.of(context).colorScheme.primaryContainer
            //there is not a holiday or Sunday
            : Theme.of(context).cardColor;

    return Column(
      children: [
        //Month headers
        showMonth
            ? MonthHeader(
                currentDate: currentDate,
                monthData: monthData,
                contentColWidth: contentColWidth,
                headerImageHeight: headerImageHeight,
                adaptiveMargin: adaptiveMargin,
                isPhone: isPhone,
                kIsWeb: kIsWeb,
                scriptureOnly: false,
                showCardBackground: true)
            : const SizedBox(
                height: 0,
              ),
        //End month header

        //Regular date card
        Padding(
          padding: adaptiveMargin,
          child: Card(
            color: tintColor,
            // tintColor: tintColor,
            child: Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 10, left: 20, right: 20),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(currentDate.westernDate, style: head6),
                        ],
                      ),
                      Expanded(
                        flex: 6,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(wolofWeekday, style: head6),
                              Text(
                                rtlTextFixer(wolofalWeekday),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontFamily: "Harmattan", fontSize: 30),
                                textDirection: ui.TextDirection.rtl,
                              ),
                              Text(currentDayOfWeek, style: head6),
                              // SizedBox(height: 16),
                            ]),
                      ),
                      Column(
                        children: [
                          Text(currentDate.wolofDate, style: head6),
                        ],
                      ),
                    ],
                  ),

                  //Holiday extension to the card
                  currentDate.holidays!.isNotEmpty
                      ? const Divider(
                          thickness: 2,
                        )
                      : const SizedBox(
                          height: 0,
                        ),
                  if (currentDate.holidays!.isNotEmpty)
                    ListView.builder(
                      controller: holidayScrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: currentDate.holidays!.length,
                      itemBuilder: (BuildContext context, int i) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(currentDate.holidays![i].holidayRS,
                              style: head6),
                          Text(
                            rtlTextFixer(currentDate.holidays![i].holidayAS),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    fontFamily: "Harmattan", fontSize: 30),
                            textDirection: ui.TextDirection.rtl,
                          ),
                          Text(
                            currentDate.holidays![i].holidayFR,
                            style: head6,
                          ),
                          currentDate.holidays!.length - (i + 1) != 0
                              ? const Divider(thickness: 3, height: 40)
                              : const SizedBox(
                                  height: 0,
                                ),
                        ],
                      ),
                    ),
                ])),
          ),
        ),
      ],
    );
  }
}
