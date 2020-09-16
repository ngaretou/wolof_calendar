import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import '../providers/months.dart';
import '../providers/route_args.dart';

import '../screens/month_scripture_screen.dart';

class MonthTile extends StatelessWidget {
  final Month currentMonth;
  MonthTile(this.currentMonth);
  @override
  Widget build(BuildContext context) {
    TextStyle rsStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: Colors.white, fontSize: 30);

    TextStyle asStyle = Theme.of(context).textTheme.headline6.copyWith(
          color: Colors.white,
          fontSize: 40,
          fontFamily: "Harmattan",
        );

    return Padding(
      padding: EdgeInsets.only(bottom: 0, top: 10),
      child: GestureDetector(
        onTap: () {
          print('tile ontap');
          Navigator.of(context).pushNamed(MonthScriptureScreen.routeName,
              arguments: MonthScriptureScreenArgs(data: currentMonth));
        },
        child: Hero(
          tag: currentMonth.monthID,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/${currentMonth.monthID}.jpg"),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(.7),
                    Colors.black.withOpacity(.2)
                  ],
                ),
              ),
              //Card text

              child: Padding(
                padding: currentMonth.monthID == "cover"
                    ? EdgeInsets.only(
                        left: 40.0, right: 40, top: 40, bottom: 30)
                    : EdgeInsets.symmetric(vertical: 40.0, horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      currentMonth.monthRS,
                      style: rsStyle,
                    ),
                    Divider(color: Colors.white),
                    Text(
                      currentMonth.monthAS,
                      style: asStyle,
                      textDirection: ui.TextDirection.rtl,
                    ),
                    currentMonth.monthID == "cover"
                        ? SizedBox(
                            height: 0,
                          )
                        : Divider(color: Colors.white),
                    currentMonth.monthID == "cover"
                        ? SizedBox(
                            height: 0,
                          )
                        : Text(
                            currentMonth.monthFR,
                            style: rsStyle,
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
