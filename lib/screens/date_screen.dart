import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../providers/months.dart';

import '../widgets/date_tile.dart';

class DateScreen extends StatefulWidget {
  static const routeName = '/date-screen';

  @override
  _DateScreenState createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final ItemScrollController itemScrollController = ItemScrollController();

  //initial app bar title with today's date
  String appBarTitle = DateFormat('MMMM yyyy', "fr_FR").format(DateTime.now());
  //initial calendar destination to today's date
  final todayYear = DateFormat('yyyy', "fr_FR").format(DateTime.now());
  final todayMonth = DateFormat('M', "fr_FR").format(DateTime.now());
  final todayDate = DateFormat('d', "fr_FR").format(DateTime.now());
  //get a ref to the currentMonth displayed in the app bar for comparison later on
  var currentMonthAppBarTitle = DateFormat('M', "fr_FR").format(DateTime.now());

  // @override
  // void didChangeDependencies() {
  //   final DateScreenArgs args = ModalRoute.of(context).settings.arguments;
  //   List<Date> _datesToDisplay = Provider.of<Months>(context, listen: false)
  //       .dates
  //       .where((element) =>
  //           element.month == args.month && element.year == args.year)
  //       .toList();
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    var navigateToDateIndex;
    var scrollToIndex;

    List<Date> _datesToDisplay =
        Provider.of<Months>(context, listen: false).dates;

    final todaysDateIndex = (_datesToDisplay.indexWhere((element) =>
        todayYear == element.year &&
        todayMonth == element.month &&
        todayDate == element.westernDate)).toInt();

    scrollToIndex = todaysDateIndex;

    // var currentMonth =
    //     DateFormat("yyyy/M", 'fr_FR').parse('${args.year}/${args.month}');

    void updateAppBarTitle(index) {
      print(index);
      var topIndexShown2 =
          itemPositionsListener.itemPositions.value.first.index + 4;

      var scrolledMonth = (_datesToDisplay[index].month);

      if (currentMonthAppBarTitle != scrolledMonth) {
        var scrolledYear = (_datesToDisplay[topIndexShown2].year);
        var scrolledDateTime =
            DateFormat('M/yyyy', "fr_FR").parse('$scrolledMonth/$scrolledYear');
        var scrolledDateTimeString =
            DateFormat('MMMM yyyy', 'fr_FR').format(scrolledDateTime);
        // var currentMonth =
        //     DateFormat("yyyy/M", 'fr_FR').parse('${args.year}/${args.month}');
        setState(() {
          appBarTitle = scrolledDateTimeString;
        });
      }
    }

    void moveMonths(String direction) {
      //We use this to move one month forward or backward to the first of the month.
      //Just feed in the direction forward or backward as a string.

      //This gets the current index of the topmost date visible.
      var topIndexShown = itemPositionsListener.itemPositions.value.first.index;
      //Grab these elements and initialize the vars
      var currentYearDisplayed = (_datesToDisplay[topIndexShown].year);
      var currentMonthDisplayed = (_datesToDisplay[topIndexShown].month);
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
      //This magically finds the index we want
      navigateToDateIndex = (_datesToDisplay.indexWhere((element) =>
          element.year == goToYear &&
          element.month == goToMonth &&
          element.westernDate == '1')).toInt();

      //This uses the scrollcontroller to whisk us to the desired date
      itemScrollController.jumpTo(index: navigateToDateIndex);
      updateAppBarTitle(navigateToDateIndex);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle, style: Theme.of(context).textTheme.headline6),
        actions: [
          IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => moveMonths('backward')),
          IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () => moveMonths('forward')),
        ],
      ),
      body: _datesToDisplay.length == 0
          ? Center(
              child: Text('Fii la arminaat bi yem TT',
                  style: Theme.of(context).textTheme.headline6))
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: NotificationListener(
                onNotification: (_) {
                  if (_ is ScrollEndNotification) {
                    updateAppBarTitle(
                        itemPositionsListener.itemPositions.value.first.index);
                  }
                  return;
                },
                child: ScrollablePositionedList.builder(
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  physics: ClampingScrollPhysics(),
                  initialScrollIndex: scrollToIndex,
                  itemBuilder: (ctx, i) => DateTile(_datesToDisplay[i]),
                  itemCount: _datesToDisplay.length,
                ),
              ),
            ),
    );
  }
}
