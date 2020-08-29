import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wolof_calendar/screens/date_screen.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
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

    TextStyle asStyle = Theme.of(context).textTheme.headline5.copyWith(
          fontFamily: "Harmattan",
          fontSize: 40,
        );
    TextStyle rsStyle = Theme.of(context)
        .textTheme
        .headline5
        .copyWith(fontFamily: "Charis", fontSize: 30);

    TextStyle asRefStyle = asStyle.copyWith(fontSize: 24);
    TextStyle rsRefStyle = rsStyle.copyWith(fontSize: 18);

    TextStyle asHeaderStyle = asStyle.copyWith(fontSize: 46, height: 1.5);
    TextStyle rsHeaderStyle = rsStyle.copyWith(fontSize: 36, height: 1.7);

    ui.TextDirection rtlText = ui.TextDirection.rtl;
    ui.TextDirection ltrText = ui.TextDirection.ltr;

    var nameColWidth = (MediaQuery.of(context).size.width / 2) - 40;

    var userPrefs = Provider.of<UserPrefs>(context, listen: false).userPrefs;

    return Scaffold(
        floatingActionButton: Builder(builder: (context) {
          return Player(args.data.monthID);
        }),
        // appBar: AppBar(floating),
        body: CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 300,
            stretch: true,
            floating: false,
            pinned: true,
            actions: [
              //show calendar in this month
              IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    Navigator.of(context).pushNamed(DateScreen.routeName,
                        arguments: DateScreenArgs(
                            year: Provider.of<Months>(context, listen: false)
                                .currentCalendarYear,
                            month: args.data.monthID,
                            date: '1'));
                  })
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [StretchMode.zoomBackground],
              title: MainTitle(args.data.arabicName),
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
                          Colors.black.withOpacity(.3)
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: nameColWidth,
                          child:
                              Text(args.data.wolofName, style: rsHeaderStyle)),
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
                  Divider(
                    thickness: 2,
                    height: 40,
                    color: Theme.of(context).accentColor,
                  ),

                  //Verses start here
                  //AS verses
                  userPrefs.wolofalVerseEnabled
                      ? ListView.builder(
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
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  (userPrefs.wolofalVerseEnabled && userPrefs.wolofVerseEnabled)
                      ? Divider(
                          height: 60,
                          thickness: 2,
                          color: Theme.of(context).accentColor,
                        )
                      : SizedBox(height: 0),
                  //RS verses
                  userPrefs.wolofVerseEnabled
                      ? ListView.builder(
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
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  SizedBox(height: 60),
                  FlatButton(
                    color: Colors.white10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalization.of(context).clickHereToReadMore,
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(fontSize: 18)),
                        Icon(Icons.arrow_forward,
                            color: Theme.of(context).textTheme.headline5.color),
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
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ]));
  }
}

//--------------------------------------
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
        numItems - i != 1
            ? Divider(
                thickness: 1, height: 60, color: Theme.of(context).accentColor)
            : SizedBox(
                height: 0,
              )
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
        style: asStyle,
        textDirection: ui.TextDirection.rtl,
      ),
    );
  }
}
