import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../providers/months.dart';
import '../providers/route_args.dart';

import '../widgets/date_tile.dart';

class DateScreen extends StatefulWidget {
  static const routeName = '/date-screen';

  @override
  _DateScreenState createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  //For the ScrollablePositionedList
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();

  //Things we declare here to get values in didChangeDependencies that we can then use in the first build
  List<Date> _datesToDisplay;
  int initialDateIndex;
  int scrollToIndex;
  String appBarTitle;
  String currentMonthAppBarTitle;
  DateTime initialDateTime;

  @override
  void didChangeDependencies() {
    //Incoming args from the Navigator.of command from wherever we've arrived from
    final DateScreenArgs args = ModalRoute.of(context).settings.arguments;

    //The data - display 'infinite' list, all dates in the data
    _datesToDisplay = Provider.of<Months>(context, listen: false).dates;

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
        DateFormat('M', "fr_FR").parse(args.month).toString();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _screenwidth = MediaQuery.of(context).size.width;
    final bool _isPhone =
        (_screenwidth + MediaQuery.of(context).size.height) <= 1350;

    var navigateToDateIndex; //this is for later on when the user navigates
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
      //We use this to move one month forward or backward to the first of the month.
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

    return Scaffold(
      appBar: AppBar(
        title: _screenwidth < 330
            ? Text(appBarTitle,
                style: Theme.of(context)
                    .appBarTheme
                    .textTheme
                    .headline6
                    .copyWith(fontSize: 18))
            : Text(appBarTitle),
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
      body: Padding(
        padding: _isPhone
            ? EdgeInsets.symmetric(horizontal: 10, vertical: 0)
            : EdgeInsets.symmetric(horizontal: _screenwidth / 20, vertical: 0),
        child: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              updateAppBarTitle(
                  itemPositionsListener.itemPositions.value.first.index);
            }
            return;
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
    );
  }
}
