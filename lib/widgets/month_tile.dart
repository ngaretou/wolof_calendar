import 'package:flutter/material.dart';

import 'package:wolof_calendar/screens/date_screen.dart';

import '../providers/months.dart';

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
                  Colors.black.withOpacity(.9),
                  Colors.black.withOpacity(.3)
                ],
              ),
            ),
            //Card text
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(DateScreen.routeName);
              },
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30),
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
                      ),
                      Divider(color: Colors.white),
                      Text(
                        currentMonth.monthFR,
                        style: rsStyle,
                      ),
                    ],
                  )),
            )),
      ),
    );
  }
}
