import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../providers/months.dart';
import '../providers/route_args.dart';

import '../widgets/date_tile.dart';
import '../widgets/drawer.dart';

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
  late List<Date> _datesToDisplay;
  late int initialDateIndex;
  late int scrollToIndex;
  late String appBarTitle;
  String? currentMonthAppBarTitle;
  late DateTime initialDateTime;
  Object? routeArgumentsObject;
  late DateScreenArgs args;

  @override
  void didChangeDependencies() {
    //We need context several places here so using this method rather than initState

    //Incoming args from the Navigator.of command from wherever we've arrived from
    routeArgumentsObject = ModalRoute.of(context)?.settings.arguments;
    // When first opening, there are no arguments, so go to current date using the argument format
    if (routeArgumentsObject == null) {
      DateTime now = new DateTime.now();
      String currentDate = DateFormat('d', 'fr_FR').format(now);
      String currentMonth = DateFormat('M', 'fr_FR').format(now);
      String currentYear = DateFormat('yyyy', 'fr_FR').format(now);

      //The data - display 'infinite' list; here infinite being all dates in the data
      _datesToDisplay = Provider.of<Months>(context, listen: false).dates;

      //Before we open to today's date, check if today's date is in the data
      if (_datesToDisplay.any((element) =>
          currentYear == element.year &&
          currentMonth == element.month &&
          currentDate == element.westernDate)) {
        //Now that we know current date, today, is in the data, open to today's date
        args = DateScreenArgs(
            date: currentDate, month: currentMonth, year: currentYear);
      } else {
        print('today not in the data, going to last entry');
        //Get the last entry in the list
        Date lastDateInData = _datesToDisplay.last;
        //and set our routargs to that date.
        //It gives a little bounce and you can't scroll any further down.
        args = DateScreenArgs(
            date: lastDateInData.westernDate,
            month: lastDateInData.month,
            year: lastDateInData.year);
      }
    }

    //This is the index of the initial date to show in that infinite list
    initialDateIndex = (_datesToDisplay.indexWhere((element) =>
        args.year == element.year &&
        args.month == element.month &&
        args.date == element.westernDate)).toInt();

    //Get the initialDate as a DateTime
    initialDateTime = DateFormat('yyyy M d', 'fr_FR')
        .parse('${args.year} ${args.month} ${args.date}');
    //Then make it nice for the initial appBarTitle
    //To change format of title bar change both in didChangeDependencies & in main build
    appBarTitle = DateFormat('yMMM', 'fr_FR').format(initialDateTime);
    //This sets up the first date you see as that initialDateIndex but will be changed as we scroll
    scrollToIndex = initialDateIndex;

    //get a ref to the currentMonth displayed in the app bar for comparison later on
    currentMonthAppBarTitle =
        DateFormat('M', "fr_FR").parse(args.month!).toString();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _screenwidth = MediaQuery.of(context).size.width;

    late var navigateToDateIndex; //this is for later on when the user navigates
    var lastIndex = _datesToDisplay.length - 1;

    void updateAppBarTitle(index) {
      var scrolledMonth = (_datesToDisplay[index].month);
      var scrolledYear = (_datesToDisplay[index].year);
      var scrolledDateTime =
          DateFormat('M/yyyy', "fr_FR").parse('$scrolledMonth/$scrolledYear');
      //To change format of title bar change both in didChangeDependencies & in main build
      var scrolledDateTimeString =
          DateFormat('yMMM', 'fr_FR').format(scrolledDateTime);

      setState(() {
        appBarTitle = scrolledDateTimeString;
      });
      // }
    }

    int getDateIndex(goToYear, goToMonth, goToDate) {
      //This magically finds the index we want
      return navigateToDateIndex = (_datesToDisplay.indexWhere((element) =>
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
      var currentYearDisplayed = (_datesToDisplay[_topIndexShown].year);
      var currentMonthDisplayed = (_datesToDisplay[_topIndexShown].month);
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
          navigateToDateIndex = _datesToDisplay.length + 1;
        } else if (direction == 'backward') {
          navigateToDateIndex = 0;
        }
      }
      //This uses the scrollcontroller to whisk us to the desired date
      if (navigateToDateIndex > lastIndex) {
        navigateToDateIndex = lastIndex;
      }
      itemScrollController.jumpTo(index: navigateToDateIndex);
      updateAppBarTitle(navigateToDateIndex);
    }

    Future pickDateToShow() async {
      print('picking a date');
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
      itemScrollController.jumpTo(
          index: getDateIndex(goToYear, goToMonth, goToDate));
      updateAppBarTitle(navigateToDateIndex);
    }

// Theme.of(context).appBarTheme.backgroundColor

    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: _screenwidth < 330
              ? Text(
                  appBarTitle,
                )
              : Text(
                  appBarTitle,
                ),
          actions: [
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
            width: (kIsWeb && _screenwidth > 1000) ? 800 : double.infinity,
            child: NotificationListener(
              onNotification: (dynamic notification) {
                if (notification is ScrollEndNotification) {
                  updateAppBarTitle(
                      itemPositionsListener.itemPositions.value.first.index);
                }
                return true;
              },
              child: ScrollablePositionedList.builder(
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                physics: BouncingScrollPhysics(),
                initialScrollIndex: scrollToIndex,
                itemBuilder: (ctx, i) => DateTile(_datesToDisplay[i]),
                itemCount: _datesToDisplay.length,
              ),
            ),
          ),
        ));
  }
}
