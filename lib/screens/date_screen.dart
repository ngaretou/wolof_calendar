import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:animated_box_decoration/animated_box_decoration.dart';

import '../providers/user_prefs.dart';
import '../providers/months.dart';
import '../providers/route_args.dart';
import '../providers/theme.dart';
import '../providers/fps.dart';

import '../widgets/drawer.dart';
import '../widgets/date_tile.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/scripture_panel.dart';

//To adapt to new Flutter 2.8 behavior that does not allow mice to drag - which is our desired behavior here
class MyCustomScrollBehavior extends ScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

enum NavType {
  jumped,
  scrolled,
}

/////////

class DateScreen extends StatefulWidget {
  const DateScreen({super.key});

  static const routeName = '/date-screen';

  @override
  DateScreenState createState() => DateScreenState();
}

class DateScreenState extends State<DateScreen> {
  //Because using custom appbar have to use this to connect the drawer to it
  GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey();

  //For the ScrollablePositionedList
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  ItemScrollController itemScrollController = ItemScrollController();

  //default theme that can be changed
  Color themeColor = Colors.teal;

  //count of these two events - a danger zone event is less than the given fps rate - a fpsWorking event is when the callback reports a good frame rate.
  int fpsDangerZone = 0;
  int fpsWorking = 0;

  // Things we declare here to get values in didChangeDependencies
  // that we can then use in the first build
  late List<Date> datesToDisplay;
  late List<Month> allMonths;
  late UserPrefs userPrefs;

  //This is used just for the initial navigation on open
  int? initialScrollIndex;

  //Holders for the app bar title info that gets refreshed as the user navigates
  //Doing this with valuenotifiers saves lots of rebuilds
  ValueNotifier<String> formattedAppBarTitle = ValueNotifier("");
  ValueNotifier<String> appBarWesternMonthFR = ValueNotifier("");
  ValueNotifier<String> appBarWesternMonthRS = ValueNotifier("");
  ValueNotifier<String> appBarWesternMonthAS = ValueNotifier("");
  ValueNotifier<String> appBarWolofMonth = ValueNotifier("");
  ValueNotifier<String> appBarWolofalMonth = ValueNotifier("");

  //used both for that initial navigation on open AND for the starting date for the date picker
  late DateTime initialDateTime;

  // the fade-in speed for the button animations in milliseconds
  final int fadeInSpeed = 300;

  //store the first day of the month that we'll use for monthly headers
  late ValueNotifier<Date> currentMonthFirstDate;

  // when we navigate the backgroundimage changes slowly if scrolled but instantly if navigated to by a jumpTo.
  // this stores what the last navigated type is.
  late NavType lastNavigatedVia;

  @override
  void initState() {
    // print('date screen initState');
    UserPrefs prefsProvider = Provider.of<UserPrefs>(context, listen: false);
    userPrefs = prefsProvider.userPrefs;

    //The data - display 'infinite' list; here infinite being all dates in the data
    datesToDisplay = Provider.of<Months>(context, listen: false).dates;
    allMonths = Provider.of<Months>(context, listen: false).months;

    //If already on low power setting, don't bother checking;
    //Also if user has one time chosen a power setting and knows where it is, don't check anymore

    // enableFpsMonitoring(); //for testing, always turns on fps monitoring
    if (userPrefs.shouldTestDevicePerformance!) enableFpsMonitoring();

    /*
    //   In the initial version of the app we arrived here with route arguments.
    //   Following the 2020 version we're going to this screen being the intial screen,
    //   but leaving the logic in case in the future we want to navigate back to this screen
    //   using route args. A bit confusing reading through for the current version.
    //   */
    late DateScreenArgs args;

    // When first opening, there are no arguments, so go to current date using the argument format
    DateTime now = DateTime.now();
    String currentDate = DateFormat('d', 'fr_FR').format(now);
    String currentMonthString = DateFormat('M', 'fr_FR').format(now);
    String currentYear = DateFormat('yyyy', 'fr_FR').format(now);

    //Before we open to today's date, check if today's date is in the data
    if (datesToDisplay.any((element) =>
        currentYear == element.year &&
        currentMonthString == element.month &&
        currentDate == element.westernDate)) {
      //Now that we know current date, today, is in the data, open to today's date
      args = DateScreenArgs(
          date: currentDate, month: currentMonthString, year: currentYear);
    } else {
      // print('today not in the data, going to last entry');
      //Get the last entry in the list
      Date lastDateInData = datesToDisplay.last;
      //and set our routargs to that date.
      args = DateScreenArgs(
          date: lastDateInData.westernDate,
          month: lastDateInData.month,
          year: lastDateInData.year);
    }

    //This initializes with a value the month we initially open to.
    int firstOfCurrentMonthIndex = datesToDisplay.indexWhere((element) =>
        element.year == args.year &&
        element.month == args.month &&
        element.westernDate == '1');

    currentMonthFirstDate =
        ValueNotifier(datesToDisplay[firstOfCurrentMonthIndex]);

    //This is the index of the initial date to show in that infinite list
    //This sets up the first date you see as that initialDateIndex but will be changed as we scroll
    //important if it's a scroll body behind app bar situation with glass app bar that it be -1 to account for
    //the tile under the app bar
    initialScrollIndex = ((datesToDisplay.indexWhere((element) =>
                args.year == element.year &&
                args.month == element.month &&
                args.date == element.westernDate)) -
            1)
        .toInt();

    //Get the initialDate as a DateTime
    initialDateTime = DateFormat('yyyy M d', 'fr_FR')
        .parse('${args.year} ${args.month} ${args.date}');
    //Then make it nice for the initial appBarTitle
    //To change format of title bar change both in initState & in main build
    formattedAppBarTitle.value = args.year!;

    Month currentMonth = (Provider.of<Months>(context, listen: false)
            .months
            .where((element) => element.monthID == args.month!)
            .toList()[
        0]); //the [0] grabs the first in the list, which will be the only one

    // Look back from topDate and get the first record where Wolof month is not empty
    int? index = initialScrollIndex;
    while (datesToDisplay[index!].wolofMonthRS == "") {
      index--;
    }

    //set up the initial values for these month headers
    appBarWesternMonthFR.value = currentMonth.monthFR;
    appBarWesternMonthRS.value = currentMonth.monthRS;
    appBarWesternMonthAS.value = currentMonth.monthAS;
    appBarWolofMonth.value = datesToDisplay[index].wolofMonthRS;
    appBarWolofalMonth.value = datesToDisplay[index].wolofMonthAS;

    //Listen to this valuenotifier for changes
    currentMonthFirstDate.addListener(() {
      // print('currentMonthFirstDate listener fired');

      /* if the changeThemeColorWithBackground is off but backgroundImage on,
      the valuelistenablebuilder will trigger that change. 
      If the theme should change this triggers it: 
      */

      if (Provider.of<UserPrefs>(context, listen: false)
          .userPrefs
          .changeThemeColorWithBackground!) {
        // setColor will refresh back to main.dart, so will automatically update the bg image, not setState necessary
        setColor();
      }
    });

    lastNavigatedVia = NavType.jumped;

    super.initState();
  }

  Future<void> enableFpsMonitoring() async {
    // debugPrint('starting fps test');
    Fps.instance!.start();

    Fps.instance!.addFpsCallback((fpsInfo) {
      // print(fpsInfo);
      // Note below format of fpsInfo object
      // FpsInfo fpsInfo = FpsInfo(fps, totalCount, droppedCount, drawFramesCount);

      //If the reported fps is under 10 fps, not good. Add one observation to danger list, otherwise add one to good list
      (fpsInfo.fps < 10) ? fpsDangerZone++ : fpsWorking++;

      //If we've observed 10 bad fps readings:
      if (fpsDangerZone > 5) enableLightAnimation();
      //If we've observed 15 reports of good working order:
      if (fpsWorking > 15) disableFpsMonitoring();
    });
  }

  Future<void> disableFpsMonitoring() async {
    debugPrint('FPS consistently good: disable monitoring');
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    Fps.instance!.stop();
  }

  Future<void> enableLightAnimation() async {
    debugPrint('FPS consistently low: ask to enable Light Animation');
    Fps.instance!.stop();
    //Set the preference
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('changeThemeColorWithBackground', false);
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    //Give the user a message and a chance to cancel
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //   duration: Duration(seconds: 8),
    //   content: Icon(Icons.power),
    // Text(
    //   AppLocalizations.of(context).changeThemeColorWithBackgroundMessage,
    // style: const TextStyle(fontSize: 18),

    // action: SnackBarAction(
    //     //for some reason the action color is not contrasting enough by default
    //     textColor: Theme.of(context).colorScheme.background,
    //     label: AppLocalizations.of(context).cancel,
    //     onPressed: () {
    //       //undo the lowPower setting
    //       Provider.of<CardPrefs>(context, listen: false)
    //           .savePref('lowPower', false);
    //       setState(() {});
    //     }),
    // ));
  }

  Future<void> setColor() async {
    // print('setColor fired');

    String monthAsString = currentMonthFirstDate.value.month;
    ImageProvider myBackground = AssetImage('assets/images/$monthAsString.jpg');

    //the magic
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(myBackground);

    try {
      themeColor = paletteGenerator.dominantColor!.color;
    } catch (e) {
      debugPrint('problem setting palette generator color');
      themeColor = Colors.teal;
    }
    if (!mounted) return;
    // hit a delay in here so the wallpaper changes, then the theme changes
    Future.delayed(const Duration(milliseconds: 1000)).then((_) =>
        Provider.of<ThemeModel>(context, listen: false)
            .setThemeColor(themeColor));
  }

  @override
  void dispose() {
    currentMonthFirstDate.dispose();
    formattedAppBarTitle.dispose();
    appBarWesternMonthFR.dispose();
    appBarWesternMonthRS.dispose();
    appBarWesternMonthAS.dispose();
    appBarWolofMonth.dispose();
    appBarWolofalMonth.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('date_screen build');

    UserPrefs userPrefsListenTrue =
        Provider.of<UserPrefs>(context, listen: true).userPrefs;

    //this is for later on when the user navigates
    late int navigateToDateIndex;

    final Size size = MediaQuery.of(context).size;
    final screenwidth = size.width;
    final screenheight = size.height;
    // print(screenwidth);

    //set up the column proportions for widescreen view

    // final double datePanelWidth = max(screenwidth * .4, 1);
    // final double scripturePanelWidth = screenwidth - datePanelWidth;

    //set up the column proportions for widescreen view
    final double datePanelWidth = max(screenwidth * .4, 350);
    final double scripturePanelWidth = screenwidth - datePanelWidth;

    //overlay color for widgets that will have a gradient over them
    final Color overlayColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.grey;

    final bool isPhone =
        ((screenwidth + screenheight) <= 1400) || screenwidth < 750;

    // Column width
    late double contentColWidth;
    late double headerImageHeight;
    late EdgeInsets adaptiveMargin;

    //if big screen
    if (!isPhone) {
      contentColWidth = 600;
      // headerImageHeight = min(screenheight, screenwidth) / 3;
      headerImageHeight = 275;

      // adaptiveMargin = EdgeInsets.symmetric(
      //     horizontal: (screenwidth - contentColWidth) / 2, vertical: 0);
      adaptiveMargin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5);
      //small screen
    } else if (isPhone) {
      contentColWidth = screenwidth - 10;
      headerImageHeight = 275;
      adaptiveMargin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    }

    Color appBarItemColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : Colors.white;

    TextStyle appBarMonthsStyle = Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(fontFamily: "Harmattan", color: appBarItemColor);

    // Updates the appbar title with the month and shows or hides the play and share buttons
    Future<void> updateAfterNavigation(
        {required NavType navType, int? navigatedIndex}) async {
      lastNavigatedVia = navType;
      // print('updateAfterNavigation');
      late int topIndex;
      // int? bottomIndex;

      /*
      There are three ways you can get here.
      1. By scrolling. 
      2. By navigating with the arrow buttons in the appbar that go +1 month and -1 month.
      3. By the date picker in the appbar.
      If user scrolls, case #1, then the itemPositionsListener will tell you both the first displayed and last displayed date's index.
      In the latter two cases, the itemPositionsListener doesn't see what's happening, so those functions pass in the index we need.
      The problem here is that if scrolling, we can see if the month header is displayed at top or bottom - if navigating directly to an index, 
      then we might actually see the header but not have the correct month header buttons :( Hopefully ListView will do a better job 
      of supporting this in the future. 
      */

      if (navigatedIndex == null) {
        //navigated index is optional so 2 and 3 pass it in but 1 (scrolling) does not.
        //So this case is if the user scrolled and we can get the first and last Index displayed directly.
        //firstIndex i.e. the top position in the visible portion of the list.
        //itemPositionsListener's 'first' and 'last' are relative to scroll direction.
        //This is how to get the scroll direction

        topIndex = min(itemPositionsListener.itemPositions.value.first.index,
                itemPositionsListener.itemPositions.value.last.index) +
            1;
        // bottomIndex = max(itemPositionsListener.itemPositions.value.first.index,
        //     itemPositionsListener.itemPositions.value.last.index);
      } else {
        topIndex = navigatedIndex + 1;
      }

      //we'll definitely have the topIndex so get the topDate info.
      Date topDate = datesToDisplay[topIndex];

      //Because we will definitely have a firstIndex but may not have a lastIndex,
      //handle the null case before we get to the if below

      //There are four cases where we want the month buttons to change:
      //if the first of the month visible on the screen, top of either Western or Wolof
      //or bottom of either Western or Wolof.

      // late String tempMonthToPlayAndShare;

      //Handle the first two cases in one expression:
      // topIndex-1 helps keep the button on screen as it's scrolling out of view
      if (topDate.westernDate == '1') {
        currentMonthFirstDate.value = topDate;
      }

      //Here unfortunately we have a complicated if, but we are checking if there is a bottom index in play
      // else if (bottomIndex != null &&
      //     //and then now we know it's not null we test if either is a 1
      //     (datesToDisplay[bottomIndex].westernDate == '1')) {

      //   tempMonthToPlayAndShare = datesToDisplay[bottomIndex]
      //       .month; //topDate.month is the western month
      // } else {
      //   //in this case it's not a 1st of any months, so make sure the headers are hidden

      //   tempMonthToPlayAndShare = currentMonthFirstDate;
      // }
      //If we got here by direct navigation and we are going to show the headers,
      //we have to reset the FAB.

      //Then do the real set up for our view
      /*This is a bit of a hack that I don't like but it's the easiest way to get around the problem. 
        When on a header screen with the play button playing, you can be playing when teh user presses
        next month. If that happens without the setState showMonthHeaderButtons = false; then the 
        button keeps playing and does not reset with the current month. This kills the button by setting
        showMonthHeaderButtons = false for .3 seconds, and doesn't slow down the UI too much. 
      */
      // if (navigatedIndex != null) {
      //   setState(() {
      //     showMonthHeaderButtons = false;
      //   });
      // }

      // Here get the French month for the header

      Month currentMonth = (Provider.of<Months>(context, listen: false)
              .months
              .where((element) => element.monthID == topDate.month)
              .toList()[
          0]); //the [0] grabs the first in the list, which will be the only one

      // Look back from top Date and get the first record where Wolof month is not empty
      int index = topIndex;
      while (datesToDisplay[index].wolofMonthRS == "") {
        index--;
      }

      formattedAppBarTitle.value = topDate.year;
      appBarWesternMonthFR.value = currentMonth.monthFR;
      appBarWesternMonthRS.value = currentMonth.monthRS;
      appBarWesternMonthAS.value = currentMonth.monthAS;
      //this is the first record before the current topDate where a Wolof month is mentioned.
      appBarWolofMonth.value = datesToDisplay[index].wolofMonthRS;
      appBarWolofalMonth.value = datesToDisplay[index].wolofMonthAS;

      int firstOfCurrentMonthIndex = datesToDisplay.indexWhere((element) =>
          element.year == topDate.year &&
          element.month == topDate.month &&
          element.westernDate == '1');

      currentMonthFirstDate.value = datesToDisplay[firstOfCurrentMonthIndex];
    }

    //This magically finds the index we want given a year, month, and date
    int getDateIndex(String goToYear, String goToMonth, String goToDate) {
      var me = (datesToDisplay.indexWhere((element) =>
          element.year == goToYear &&
          element.month == goToMonth &&
          element.westernDate == goToDate)).toInt();

      return me;
    }

    void moveMonths(String direction) async {
      // print('moveMonths');
      //We use this to move one month forward or backward to the first of the month
      //wiht the arrow buttons in the app title bar.
      //Just feed in the direction forward or backward as a string.

      //This gets the current index of the topmost date visible.
      //The + 1 is a hack accounting for the glass app bar

      int topIndexShown =
          itemPositionsListener.itemPositions.value.first.index + 1;

      //Grab these elements and initialize the vars
      String currentYearDisplayed = (datesToDisplay[topIndexShown].year);
      String currentMonthDisplayed = (datesToDisplay[topIndexShown].month);
      late String goToMonth;
      late String goToYear;

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

      navigateToDateIndex = getDateIndex(goToYear, goToMonth, '1');

      //getDateIndex returns -1 if [element] is not found.
      //Here you've requested a date not in the data set, so go to beginning or end of set
      if (navigateToDateIndex < 0) {
        if (direction == 'forward') {
          //lenght starts 1, 2, 3; indexes start 0, 1, 2; so that's why the -1 here
          navigateToDateIndex = datesToDisplay.length - 1;
        } else if (direction == 'backward') {
          navigateToDateIndex = 1;
        }
      }

      //Adjust for the glass app bar
      navigateToDateIndex = navigateToDateIndex - 1;

      //This uses the scrollcontroller to whisk us to the desired date

      itemScrollController.jumpTo(index: navigateToDateIndex);

      updateAfterNavigation(
          navType: NavType.jumped, navigatedIndex: navigateToDateIndex);
    }

    Future pickDateToShow() async {
      // print('pickDateToShow');
      DateTime lastDate = DateTime(
          int.parse(datesToDisplay.last.year),
          int.parse(datesToDisplay.last.month),
          int.parse(datesToDisplay.last.westernDate));

      final chosenDate = await showDatePicker(
        context: context,
        initialDate: initialDateTime,
        firstDate: DateTime(2020, 8),
        lastDate: lastDate,
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
      //-1 to account for the app bar hiding the first tile
      int navigateToIndex = getDateIndex(goToYear, goToMonth, goToDate) - 1;
      //then passes it to the scroll controlloer to get us there
      itemScrollController.jumpTo(index: navigateToIndex);
      //and then updates the interface to match the new date
      updateAfterNavigation(
          navType: NavType.jumped, navigatedIndex: navigateToIndex);
    }

    //The widget that is used for all the month headers
    Widget monthNames(ValueNotifier<String> notifier, TextAlign textAlign) {
      return ValueListenableBuilder(
          valueListenable: notifier,
          builder: (context, String value, _) {
            return Text(
              value,
              style: appBarMonthsStyle,
              textAlign: textAlign,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          });
    }

    //the row of month names in the app bar
    Widget monthRow() {
      late Row row;

      List<Widget> monthNameWidgets = [];

      //this pushes the month names over to the right in widescreen view
      double spaceAvailable = isPhone ? screenwidth : (datePanelWidth) - 16;

      //for larger screens we can show more month names:
      //western month in RS and AS, then wolof in RS and AS
      if (spaceAvailable > 368) {
        monthNameWidgets = [
          monthNames(appBarWesternMonthFR, TextAlign.left),
          Text(
            '/',
            style: appBarMonthsStyle,
          ),
          monthNames(appBarWesternMonthAS, TextAlign.right),
          const Expanded(
              child: SizedBox(
            width: 1,
          )),
          monthNames(appBarWolofMonth, TextAlign.left),
          Text(
            '/',
            style: appBarMonthsStyle,
          ),
          monthNames(appBarWolofalMonth, TextAlign.right),
        ];
      } else {
        //if not a large screen just show western month in RS, then wolof in AS
        monthNameWidgets = [
          monthNames(appBarWesternMonthFR, TextAlign.left),
          monthNames(appBarWolofalMonth, TextAlign.right)
        ];
      }

      row = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: monthNameWidgets);

      return Container(
          padding: isPhone
              ? const EdgeInsets.symmetric(horizontal: 8)
              : EdgeInsets.only(left: (scripturePanelWidth) + 16, right: 8),
          color: Colors.transparent,
          child: row);
    }

    Widget datesSection() {
      return MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: NotificationListener(
          onNotification: (dynamic notification) {
            if (notification is ScrollEndNotification) {
              updateAfterNavigation(navType: NavType.scrolled);
            }
            return true;
          },
          child: Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
                  behavior:
                      MyCustomScrollBehavior().copyWith(scrollbars: false),
                  child: ScrollablePositionedList.builder(
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    physics: const BouncingScrollPhysics(),
                    initialScrollIndex: initialScrollIndex!,
                    itemBuilder: (ctx, i) => DateTile(
                      currentDate: datesToDisplay[i],
                      contentColWidth: contentColWidth,
                      headerImageHeight: headerImageHeight,
                      adaptiveMargin: adaptiveMargin,
                      isPhone: isPhone,
                    ),
                    itemCount: datesToDisplay.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    //this image backdrop goes behind the whole screen if widescreen and just date panel if phone
    Widget imageBackdrop({required Widget child}) {
      return ValueListenableBuilder(
        valueListenable: currentMonthFirstDate,
        child: child,
        builder: (context, value, child) {
          return SmoothAnimatedContainer(
            duration: lastNavigatedVia == NavType.jumped
                ? const Duration(milliseconds: 0)
                : const Duration(milliseconds: 2000),
            curve: Curves.ease,
            height: double.infinity,
            width: double.infinity,
            decoration: userPrefsListenTrue.backgroundImage!
                ? BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/${currentMonthFirstDate.value.month.toString()}.jpg',
                          bundle: DefaultAssetBundle.of(context)),
                      fit: BoxFit.cover,
                    ),
                  )
                : BoxDecoration(color: Theme.of(context).highlightColor),
            child: BackdropFilter(
              // This is not exactly as I want it, this is for the bg image - but in
              // widescreen view it makes the verses blurry.
              filter: isPhone
                  ? ImageFilter.blur(sigmaX: 1, sigmaY: 5)
                  : ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: userPrefs.backgroundImage!
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topCenter,
                          colors: [
                            overlayColor.withOpacity(.7),
                            overlayColor.withOpacity(.3)
                          ],
                          stops: const [0.1, .9],
                        ),
                      )
                    : BoxDecoration(color: Theme.of(context).highlightColor),
                child: child,
              ),
            ),
          );
        },
      );
    }

    Widget versesSection() {
      return ScripturePanel(
          currentDate: currentMonthFirstDate.value,
          monthData: allMonths,
          contentColWidth: contentColWidth,
          headerImageHeight: headerImageHeight,
          scripturePanelWidth: scripturePanelWidth,
          adaptiveMargin: adaptiveMargin,
          size: size,
          isPhone: isPhone,
          kIsWeb: kIsWeb);
    }

    return Scaffold(
      key: scaffoldStateKey,
      extendBodyBehindAppBar: true,
      //Theme + BackdropFilter gets the glass theme on the drawer
      drawerScrimColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white.withOpacity(.1)
          : Colors.black.withOpacity(.1),
      drawer: BackdropFilter(
          filter: userPrefs.glassEffects!
              ? ImageFilter.blur(sigmaX: 50, sigmaY: 50)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: const MainDrawer()),

      appBar: glassAppBar(
          scaffoldStateKey: scaffoldStateKey,
          context: context,
          title: formattedAppBarTitle.value,
          height: 89.0,
          actions: [
            //light/dark theme

            // IconButton(
            //     onPressed: () {
            //       Theme.of(context).brightness == Brightness.light
            //           ? themeProvider.setDarkTheme()
            //           : themeProvider.setLightTheme();
            //     },
            //     icon: Theme.of(context).brightness == Brightness.light
            //         ? const Icon(Icons.light_mode)
            //         : const Icon(Icons.dark_mode)),

            //Navigate one month back
            IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                ),
                onPressed: () => moveMonths('backward')),

            //Date picker
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => pickDateToShow(),
            ),

            //one month forward
            IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () => moveMonths('forward')),
          ],
          extraRow: monthRow()),
      body: isPhone
          ? Stack(
              children: [imageBackdrop(child: datesSection()), versesSection()],
            )
          : imageBackdrop(
              child: Row(
                children: [
                  SizedBox(width: scripturePanelWidth, child: versesSection()),
                  SizedBox(width: datePanelWidth, child: datesSection()),
                ],
              ),
            ),
    );
  }
}
