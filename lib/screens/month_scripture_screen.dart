import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wolof_calendar/screens/date_screen.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../providers/months.dart';
import '../providers/route_args.dart';
import '../providers/user_prefs.dart';
import 'package:url_launcher/url_launcher.dart';
import '../locale/app_localization.dart';

import 'dart:ui' as ui;

import '../widgets/play_button.dart';

class MonthScriptureScreen extends StatelessWidget {
  static const routeName = '/month-scripture-screen';

  @override
  Widget build(BuildContext context) {
    // final bool _isDark =
    //     Provider.of<ThemeModel>(context, listen: false).userThemeName ==
    //         'darkTheme';
    // Color _fontColor = _isDark ? Colors.white : Colors.black;
    final MonthScriptureScreenArgs args =
        ModalRoute.of(context).settings.arguments;

    TextStyle asStyle = Theme.of(context).textTheme.headline6.copyWith(
          fontFamily: "Harmattan",
          fontSize: 40,
        );
    TextStyle rsStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(fontFamily: "Charis", fontSize: 30);

    TextStyle asRefStyle = asStyle.copyWith(fontSize: 24);
    TextStyle rsRefStyle = rsStyle.copyWith(fontSize: 18);

    TextStyle asHeaderStyle = asStyle.copyWith(fontSize: 46, height: 1.5);
    TextStyle rsHeaderStyle = rsStyle.copyWith(fontSize: 36, height: 1.7);

    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;

// Column width for the name row
    var nameColWidth = (MediaQuery.of(context).size.width / 2) - 40;

    var userPrefs = Provider.of<UserPrefs>(context, listen: false).userPrefs;

    return Scaffold(
      floatingActionButton: Builder(builder: (context) {
        return Player(args.data.monthID);
      }),
      // appBar: AppBar(floating),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            stretch: true,
            floating: false,
            pinned: true,
            actions: [
              //share the verse
              IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            AppLocalization.of(context).sharingTitle,
                          ),
                          content: Text(AppLocalization.of(context).sharingMsg),
                          actions: [
                            FlatButton(
                                child: Text("Wolof"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  String versesToShare = '';
                                  args.data.verses.forEach((element) {
                                    versesToShare = versesToShare +
                                        " " +
                                        element.verseRS +
                                        " -- " +
                                        element.verseRefRS +
                                        '\n';
                                  });
                                  Share.share('Yàlla mooy ' +
                                      args.data.wolofName +
                                      ":  " +
                                      versesToShare);
                                }),
                            FlatButton(
                                child: Text("وࣷلࣷفَلْ",
                                    style: TextStyle(
                                        fontFamily: "Harmattan", fontSize: 22)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  String versesToShare = '';
                                  args.data.verses.forEach((element) {
                                    versesToShare = versesToShare +
                                        " " +
                                        element.verseAS +
                                        " -- " +
                                        element.verseRefAS +
                                        '\n';
                                  });

                                  Share.share('  يࣵلَّ مࣷويْ' +
                                      args.data.wolofalName +
                                      ":  " +
                                      versesToShare);
                                }),
                            FlatButton(
                                child: Text(
                                  AppLocalization.of(context).cancel,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ],
                        );
                      },
                    );
                  }),
              //show calendar in this month
              IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    Navigator.of(context).popAndPushNamed(DateScreen.routeName,
                        arguments: DateScreenArgs(
                            year: Provider.of<Months>(context, listen: false)
                                .currentCalendarYear,
                            month: args.data.monthID,
                            date: '1'));
                  })
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [StretchMode.zoomBackground],
              title: args.data.monthID == "cover"
                  ? Text(args.data.monthRS)
                  : MainTitle(args.data.arabicName),
              centerTitle: true,
              background: Hero(
                tag: args.data.monthID,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          AssetImage("assets/images/${args.data.monthID}.jpg"),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        colors: [
                          Colors.black.withOpacity(.9),
                          Colors.black.withOpacity(.0)
                        ],
                      ),
                    ),
                    //Card text
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  //Main Wolof names heading
                  if (args.data.monthID != "cover")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: nameColWidth,
                            child: Text(args.data.wolofName,
                                style: rsHeaderStyle)),
                        Container(
                          width: nameColWidth,
                          child: Text(
                            args.data.wolofalName,
                            style: asHeaderStyle,
                            textDirection: ui.TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  if (args.data.monthID != "cover")
                    Divider(
                      thickness: 2,
                      height: 40,
                      color: Theme.of(context).accentColor,
                    ),

                  //Verses start here
                  //AS verses
                  if (userPrefs.wolofalVerseEnabled)
                    ListView.builder(
                      itemCount: args.data.verses.length,
                      itemBuilder: (ctx, i) => VerseBuilder(
                          args.data.verses[i].verseAS,
                          args.data.verses[i].verseRefAS,
                          asStyle,
                          asRefStyle,
                          rtlText,
                          args.data.verses.length,
                          i),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),

                  if (userPrefs.wolofalVerseEnabled &&
                      userPrefs.wolofVerseEnabled)
                    Divider(
                      height: 60,
                      thickness: 2,
                      color: Theme.of(context).accentColor,
                    ),

                  //RS verses
                  if (userPrefs.wolofVerseEnabled)
                    ListView.builder(
                      itemCount: args.data.verses.length,
                      itemBuilder: (ctx, i) => VerseBuilder(
                          args.data.verses[i].verseRS,
                          args.data.verses[i].verseRefRS,
                          rsStyle,
                          rsRefStyle,
                          ltrText,
                          args.data.verses.length,
                          i),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  SizedBox(height: 60),
                  RaisedButton(
                    color: Theme.of(context).appBarTheme.color,
                    elevation: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalization.of(context).clickHereToReadMore,
                            style: Theme.of(context)
                                .appBarTheme
                                .textTheme
                                .headline6
                                .copyWith(fontSize: 18)),
                        Icon(Icons.arrow_forward,
                            color:
                                Theme.of(context).appBarTheme.iconTheme.color),
                      ],
                    ),
                    onPressed: () async {
                      const url = 'https://sng.al/chrono';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  //Holiday list
                  HolidayBuilder(args.data.monthID),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//--------------------------------------
class HolidayBuilder extends StatelessWidget {
  final String monthID;
  HolidayBuilder(this.monthID);

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
//Set up some styling for use down below
    TextStyle asStyle = Theme.of(context).textTheme.headline6.copyWith(
          fontFamily: "Harmattan",
          fontSize: 30,
        );
    TextStyle rsStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(fontFamily: "Charis", fontSize: 22);

    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;

    final currentCalendarYear =
        Provider.of<Months>(context, listen: false).currentCalendarYear;

    final monthData = Provider.of<Months>(context, listen: false)
        .months
        .where((month) => month.monthID == monthID)
        .toList();

    final datesData = Provider.of<Months>(context, listen: false)
        .dates
        .where((element) =>
            element.month == monthID && element.year == currentCalendarYear)
        .toList();

    var previousWolofDate;
    // Before we do anything, check if there are holidays in this month. If there are none, just put in a zero sized box below.
    bool hasHolidays = datesData.any((date) => date.holidays.length != 0);

    List<Holiday> holidaysList = [];

//only build the holidaysList if you know for sure there are holidays
    if (hasHolidays) {
      datesData.forEach((day) {
        if (day.holidays.length != 0) {
          day.holidays.forEach((holiday) {
            holidaysList.add(Holiday(
              year: day.year,
              monthID: day.month,
              westernMonthDate: day.westernDate,
              wolofMonthDate: day.wolofDate,
              holidayFR: holiday.holidayFR,
              holidayAS: holiday.holidayAS,
              holidayRS: holiday.holidayRS,
            ));
          });
        }
      });
      previousWolofDate = holidaysList[0].wolofMonthDate;
    }

    Widget monthHeaderRow(wolofMonth) {
      return Column(children: [
        // Divider(thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(monthData[0].monthRS, style: rsStyle),
            Text(datesData[wolofMonth].wolofMonthRS, style: rsStyle),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(monthData[0].monthAS,
                style: asStyle, textDirection: ui.TextDirection.rtl),
            Text(datesData[wolofMonth].wolofMonthAS,
                style: asStyle, textDirection: ui.TextDirection.rtl),
          ],
        ),
        Divider(thickness: 2),
      ]);
    }

    return !hasHolidays
        ? SizedBox(height: 0)
        : Column(
            children: [
              SizedBox(height: 30),
              //This is the part that never changes, a header row with the four months.
              monthHeaderRow(0),

              //Here are the holidays
              ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: holidaysList.length,
                itemBuilder: (ctx, i) {
                  if (i != 0) {
                    previousWolofDate = holidaysList[i - 1].wolofMonthDate;
                  }
                  return Column(
                    children: [
                      //repeat the header row only if we've moved to a new month
                      if (int.parse(holidaysList[i].wolofMonthDate) <
                          int.parse(previousWolofDate))
                        //The indexWhere finds the index of the new month and then grabs the wolof month name there -
                        //you can only turn over the month one time in a month, so grabbing the 1 suffices here
                        monthHeaderRow(datesData
                            .indexWhere((element) => element.wolofDate == "1")),

                      //but in any case put in the holiday row
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(DateScreen.routeName,
                              arguments: DateScreenArgs(
                                  year: currentCalendarYear,
                                  month: monthID,
                                  date: holidaysList[i].westernMonthDate));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Western date
                            Text(holidaysList[i].westernMonthDate,
                                style: rsStyle),
                            //Three versions of holiday name
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(holidaysList[i].holidayRS, style: rsStyle),
                                Text(holidaysList[i].holidayAS,
                                    style: asStyle,
                                    textDirection: ui.TextDirection.rtl),
                                Text(holidaysList[i].holidayFR, style: rsStyle),
                              ],
                            ),
                            //Wolof date
                            Text(holidaysList[i].wolofMonthDate,
                                style: rsStyle),
                          ],
                        ),
                      ),
                      Divider(thickness: 1),
                    ],
                  );
                },
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
              ),
            ],
          );
  }
}

class VerseBuilder extends StatelessWidget {
  final String verse;
  final String ref;
  final TextStyle verseStyle;
  final TextStyle refStyle;
  final ui.TextDirection direction;
  final int numItems;
  final int i;

  VerseBuilder(this.verse, this.ref, this.verseStyle, this.refStyle,
      this.direction, this.numItems, this.i);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          verse,
          style: verseStyle,
          textDirection: direction,
          textAlign: TextAlign.center,
        ),
        Divider(
          height: 30,
          thickness: 1,
          indent: 50,
          endIndent: 50,
        ),
        Text(
          ref,
          style: refStyle,
          textDirection: direction,
          textAlign: TextAlign.center,
        ),
        if (numItems - i != 1)
          Divider(
              thickness: 1, height: 60, color: Theme.of(context).accentColor)
      ],
    );
  }
}

//--------------------------------------
class MainTitle extends StatefulWidget {
  final String text;
  MainTitle(this.text);

  @override
  _MainTitleState createState() => _MainTitleState();
}

class _MainTitleState extends State<MainTitle> {
  Timer _timer;
  //Lazy animation: set opacity at 0
  double _opacity = 0;

  @override
  void initState() {
    //Lazy animation: when the build happens, wait a sec then start the fade-in
    _timer = Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle asStyle = Theme.of(context).textTheme.headline6.copyWith(
        fontFamily: "Harmattan", fontSize: 40, color: Colors.white, height: 1);

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(seconds: 1),
      child: Text(
        widget.text,
        style: asStyle.copyWith(height: 1),
        textDirection: ui.TextDirection.rtl,
      ),
    );
  }
}
