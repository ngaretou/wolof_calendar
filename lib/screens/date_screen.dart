import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../providers/months.dart';
import '../providers/route_args.dart';

import '../widgets/drawer.dart';
import '../widgets/play_button.dart';
import '../widgets/date_tile.dart';

class DateScreen extends StatefulWidget {
  static const routeName = '/date-screen';

  @override
  _DateScreenState createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  //For the ScrollablePositionedList
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  ItemScrollController itemScrollController = ItemScrollController();

  // Things we declare here to get values in didChangeDependencies
  // that we can then use in the first build
  late List<Date> datesToDisplay;
  //This is used just for the initial navigation on open
  late int initialScrollIndex;
  //Holder for the app bar title that gets refreshed as the user navigates
  late Text formattedAppBarTitle;
  //used both for that initial navigation on open AND for the starting date for the date picker
  late DateTime initialDateTime;
  //this gets initialized so it can never be null but is really set below
  bool showMonthHeaderButtons = false;
  // the fade-in speed for the button animations in milliseconds
  final int fadeInSpeed = 300;
  //store the month that we'll grab the verses to play and share
  late String monthToPlayAndShare;

  //Normally we'd just set this inline but we have to use this a couple of times so putting it in code for uniformity
  Text appBarTitleFormat(DateTime incomingDateTime, BuildContext context) {
    final _screenwidth = MediaQuery.of(context).size.width;
    print(_screenwidth);

    //Screen range
    double smallScreenMax = 344;
    double mediumScreenMax = 399;

    if (_screenwidth >= mediumScreenMax) {
      print('large');
      return Text(DateFormat('yMMMM', 'fr_FR').format(incomingDateTime));
    } else if (_screenwidth >= smallScreenMax &&
        _screenwidth < mediumScreenMax) {
      print('medium');
      return Text(DateFormat('yMMM', 'fr_FR').format(incomingDateTime),
          style: TextStyle(fontSize: 18));
    } else if (_screenwidth < smallScreenMax) {
      print('small');
      return Text(DateFormat('yMMM', 'fr_FR').format(incomingDateTime),
          style: TextStyle(fontSize: 14));
    }
    throw (error) {
      print('error in appBarTitle formatting');
    };
  }

  @override
  void didChangeDependencies() {
    print('didChangeDependencies');

    //We need context several places here so using this method rather than initState,
    //where there is no context - didChangeDependencies is initState with context

    /*
    In the initial version of the app we arrived here with route arguments. 
    In the 2021 version we're going to this screen being the intial screen, 
    but leaving the logic in case in the future we want to navigate back to this screen
    using route args. A bit confusing reading through for the 2021 version.  
    So the below is the incoming args from the Navigator.of command 
    from wherever we've arrived from, or possibly null. 
    */

    late DateScreenArgs _args;

    // When first opening, there are no arguments, so go to current date using the argument format
    if (ModalRoute.of(context)?.settings.arguments == null) {
      DateTime _now = new DateTime.now();
      String currentDate = DateFormat('d', 'fr_FR').format(_now);
      String currentMonth = DateFormat('M', 'fr_FR').format(_now);
      String currentYear = DateFormat('yyyy', 'fr_FR').format(_now);

      //The data - display 'infinite' list; here infinite being all dates in the data
      datesToDisplay = Provider.of<Months>(context, listen: false).dates;

      //Before we open to today's date, check if today's date is in the data
      if (datesToDisplay.any((element) =>
          currentYear == element.year &&
          currentMonth == element.month &&
          currentDate == element.westernDate)) {
        //Now that we know current date, today, is in the data, open to today's date
        _args = DateScreenArgs(
            date: currentDate, month: currentMonth, year: currentYear);
      } else {
        print('today not in the data, going to last entry');
        //Get the last entry in the list
        Date _lastDateInData = datesToDisplay.last;
        //and set our routargs to that date.
        //It gives a little bounce and you can't scroll any further down.
        _args = DateScreenArgs(
            date: _lastDateInData.westernDate,
            month: _lastDateInData.month,
            year: _lastDateInData.year);
      }
    }

    //This is the index of the initial date to show in that infinite list
    //This sets up the first date you see as that initialDateIndex but will be changed as we scroll
    initialScrollIndex = (datesToDisplay.indexWhere((element) =>
        _args.year == element.year &&
        _args.month == element.month &&
        _args.date == element.westernDate)).toInt();

    //Get the initialDate as a DateTime
    initialDateTime = DateFormat('yyyy M d', 'fr_FR')
        .parse('${_args.year} ${_args.month} ${_args.date}');
    //Then make it nice for the initial appBarTitle
    //To change format of title bar change both in didChangeDependencies & in main build
    formattedAppBarTitle = appBarTitleFormat(initialDateTime, context);
    //This initializes with a value the month we initially open to.
    //If it's a 1, it will display the buttons, but if not, it will not show anyway
    monthToPlayAndShare = _args.month!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    late var navigateToDateIndex; //this is for later on when the user navigates
    var lastIndex = datesToDisplay.length - 1;

    // Updates the appbar title with the month and shows or hides the play and share buttons
    Future<void> updateAfterNavigation({int? navigatedIndex}) async {
      late int _topIndex;
      int? _bottomIndex;

      /*
      There are three ways you can get here.
      1. By scrolling. 
      2. By navigating with the arrow buttons in the appbar that go +1 month and -1 month.
      3. By the date picker in the appbar.
      If user scrolls, case #1, then the itemPositionsListener will tell you both the first displayed and last displayed date's index.
      In the latter two cases, the itemPositionsListener doesn't see what's happening, so those functions pass in the index we need.
      The jank here is that if scrolling, we can see if the month header is displayed at top or bottom - if navigating directly to an index, 
      then we might actually see the header but not have the correct month header buttons :( Hopefully ListView will do a better job 
      of supporting this in the future. 
      */
      if (navigatedIndex == null) {
        //navigated index is optional so 2 and 3 pass it in but 1 does not.
        //So this case is if the user scrolled and we can get the first and last Index displayed directly.
        //firstIndex i.e. the top position in the visible portion of the list.
        _topIndex = itemPositionsListener.itemPositions.value.first.index;
        _bottomIndex = itemPositionsListener.itemPositions.value.last.index;
      } else {
        _topIndex = navigatedIndex;
      }

      //we'll definitely have the topIndex so get the topDate info.
      Date _topDate = datesToDisplay[_topIndex];

      //Getting the top DateTime and saving it for the appBarTitle in the SetState below
      DateTime _scrolledDateTime = DateFormat('M/yyyy', "fr_FR")
          .parse('${_topDate.month}/${_topDate.year}');

      //Because we will definitely have a firstIndex but may not have a lastIndex,
      //handle the null case before we get to the if below

      //There are four cases where we want the month buttons to change:
      //if the first of the month visible on the screen, top of either Western or Wolof
      //or bottom of either Western or Wolof.

      late bool _showHeaders;
      late String _monthToPlayAndShare;
      //Handle the first two cases in one expression:
      if (_topDate.westernDate == '1') {
        _showHeaders = true;
        _monthToPlayAndShare = _topDate.month;
      }

      //Here unfortunately we have a complicated if, but we are checking if there is a bottom index in play
      else if (_bottomIndex != null &&
          //and then now we know it's not null we test if either is a 1
          (datesToDisplay[_bottomIndex].westernDate == '1')) {
        _showHeaders = true;
        _monthToPlayAndShare = datesToDisplay[_bottomIndex]
            .month; //_topDate.month is the western month
      } else {
        //in this case it's not a 1st of any months, so make sure the headers are hidden
        _showHeaders = false;
        _monthToPlayAndShare = monthToPlayAndShare;
      }
      //If we got here by direct navigation and we are going to show the headers,
      //we have to reset the FAB.

      //Then do the real set up for our view
      /*This is a bit of a hack that I don't like but it's the easiest way to get around the problem. 
        When on a header screen with the play button playing, you can be playing when teh user presses
        next month. If that happens without the setState showMonthHeaderButtons = false; then the 
        button keeps playing and does not reset with the current month. This kills the button by setting
        showMonthHeaderButtons = false for .3 seconds, and doesn't slow down the UI too much. 
      */
      if (_showHeaders == true && navigatedIndex != null) {
        setState(() {
          showMonthHeaderButtons = false;
        });
      }

      Timer(Duration(milliseconds: fadeInSpeed), () {
        setState(() {
          formattedAppBarTitle = appBarTitleFormat(_scrolledDateTime, context);
          showMonthHeaderButtons = _showHeaders;
          monthToPlayAndShare = _monthToPlayAndShare;
        });
      });
    }

    int getDateIndex(String goToYear, String goToMonth, String goToDate) {
      //This magically finds the index we want
      return navigateToDateIndex = (datesToDisplay.indexWhere((element) =>
          element.year == goToYear &&
          element.month == goToMonth &&
          element.westernDate == goToDate)).toInt();
    }

    void moveMonths(String direction) {
      //We use this to move one month forward or backward to the first of the month
      //wiht the arrow buttons in the app title bar.
      //Just feed in the direction forward or backward as a string.

      //This gets the current index of the topmost date visible.
      var _topIndexShown =
          itemPositionsListener.itemPositions.value.first.index;
      //Grab these elements and initialize the vars
      var currentYearDisplayed = (datesToDisplay[_topIndexShown].year);
      var currentMonthDisplayed = (datesToDisplay[_topIndexShown].month);
      var goToMonth;
      var goToYear;

      if (direction == 'forward') {
        //If it's not December, we just add a month
        if (currentMonthDisplayed != '12') {
          goToMonth = ((int.parse(currentMonthDisplayed)) + 1).toString();
          goToYear = currentYearDisplayed;
          //If it's december, go to january but up the year by 1
        } else if (currentMonthDisplayed == '12') {
          goToMonth = '1';
          // var intermediate = (int.parse(currentYearDisplayed)) + 1;
          // goToYear = intermediate.toString();

          goToYear = ((int.parse(currentYearDisplayed)) + 1).toString();
        }
      }

      if (direction == 'backward') {
        //If not January, it's easy, just go back one month
        if (currentMonthDisplayed != '1') {
          goToMonth = ((int.parse(currentMonthDisplayed)) - 1).toString();
          goToYear = currentYearDisplayed;
          //But if january you go back to december and subtract a year
        } else if (currentMonthDisplayed == '1') {
          goToMonth = '12';
          goToYear = ((int.parse(currentYearDisplayed)) - 1).toString();
        }
      }
      getDateIndex(goToYear, goToMonth, '1');
      if (navigateToDateIndex < 0) {
        if (direction == 'forward') {
          navigateToDateIndex = datesToDisplay.length + 1;
        } else if (direction == 'backward') {
          navigateToDateIndex = 0;
        }
      }
      //This uses the scrollcontroller to whisk us to the desired date
      if (navigateToDateIndex > lastIndex) {
        navigateToDateIndex = lastIndex;
      }
      itemScrollController.jumpTo(index: navigateToDateIndex);
      updateAfterNavigation(navigatedIndex: navigateToDateIndex);
    }

    Future pickDateToShow() async {
      final chosenDate = await showDatePicker(
        context: context,
        initialDate: initialDateTime,
        firstDate: DateTime(2020, 8),
        lastDate: DateTime(2022, 1, 31),
        locale: const Locale("fr", "FR"),
      );
      if (chosenDate == null) {
        return;
      }

      var goToYear = DateFormat('yyyy', 'fr_FR').format(chosenDate).toString();
      var goToMonth = DateFormat('M', 'fr_FR').format(chosenDate).toString();
      var goToDate = DateFormat('d', 'fr_FR').format(chosenDate).toString();

      //This uses the scrollcontroller to whisk us to the desired date
      //Here this returns the index of the date we're headed to,
      int _navigateToIndex = getDateIndex(goToYear, goToMonth, goToDate);
      //then passes it to the scroll controlloer to get us there
      itemScrollController.jumpTo(index: _navigateToIndex);
      //and then updates the interface to match the new date
      updateAfterNavigation(navigatedIndex: _navigateToIndex);
    }

    void _adaptiveShare(String script) async {
      //Grab the months data, which contains the verse data
      Month monthData = (Provider.of<Months>(context, listen: false)
          .months
          .where((element) => element.monthID == monthToPlayAndShare)
          .toList()[0]);
      //the [0] grabs the first in the list, which will be the only one

      String versesToShare = '';
      late String lineBreak, vs, ref, name;

      kIsWeb ? lineBreak = '%0d%0a' : lineBreak = '\n';

      //Put together the verses to share. Do with forEach to take into account the multiple verse months.
      monthData.verses.forEach((element) {
        if (script == 'roman') {
          // yallaMooy = 'Yàlla mooy ';
          vs = element.verseRS;
          ref = element.verseRefRS;
          monthData.wolofName != null
              ? name = monthData.wolofName.toString()
              // ignore: unnecessary_statements
              : null;
        } else if (script == 'arabic') {
          // yallaMooy = 'يࣵلَّ مࣷويْ ';
          vs = element.verseAS;
          ref = element.verseRefAS;
          monthData.wolofalName != null
              ? name = monthData.wolofalName.toString()
              // ignore: unnecessary_statements
              : null;
        }

        versesToShare =
            versesToShare + vs + lineBreak + ref + lineBreak + lineBreak;
      });

      //Put together the whole sharing string
      final String textToShare = name +
          ": " +
          lineBreak +
          lineBreak +
          versesToShare +
          'https://sng.al/cal';

      //if it's not the web app, share using the device share function
      if (!kIsWeb) {
        Share.share(textToShare);
      } else {
        //If it's the web app version best way to share is probably email, so put the text to share in an email
        final String url = "mailto:?subject=Arminaatu Wolof&body=$textToShare";

        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    }

    String _nameCode = Provider.of<Months>(context, listen: false)
        .months
        .where((element) => element.monthID == monthToPlayAndShare)
        .toList()[0]
        .arabicNameCode;

    return Scaffold(
        drawer: MainDrawer(),
        floatingActionButton: showMonthHeaderButtons
            ? PlayButton(file: monthToPlayAndShare, name: _nameCode)
            : null,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: formattedAppBarTitle,
          actions: [
            AnimatedOpacity(
              child: IconButton(
                  icon: Icon(Icons.share),
                  onPressed: showMonthHeaderButtons
                      ? () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  AppLocalizations.of(context)!.sharingTitle,
                                ),
                                content: Text(
                                    AppLocalizations.of(context)!.sharingMsg),
                                actions: [
                                  TextButton(
                                      child: Text("Wolof"),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        _adaptiveShare('roman');
                                      }),
                                  TextButton(
                                      child: Text("وࣷلࣷفَلْ",
                                          style: TextStyle(
                                              fontFamily: "Harmattan",
                                              fontSize: 22)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _adaptiveShare('arabic');
                                      }),
                                  TextButton(
                                      child: Text(
                                        AppLocalizations.of(context)!.cancel,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                ],
                              );
                            },
                          );
                        }
                      : () {}),
              opacity: showMonthHeaderButtons ? 1.0 : 0.0,
              duration: Duration(milliseconds: fadeInSpeed),
            ),
            IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => moveMonths('backward')),
            IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () => pickDateToShow(),
            ),
            IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () => moveMonths('forward')),
          ],
        ),
        body: Center(
          child: Container(
            child: NotificationListener(
              onNotification: (dynamic notification) {
                if (notification is ScrollEndNotification) {
                  updateAfterNavigation();
                }
                return true;
              },
              child: ScrollablePositionedList.builder(
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                physics: BouncingScrollPhysics(),
                initialScrollIndex: initialScrollIndex,
                itemBuilder: (ctx, i) =>
                    DateTile(currentDate: datesToDisplay[i]),
                itemCount: datesToDisplay.length,
              ),
            ),
          ),
        ));
  }
}
