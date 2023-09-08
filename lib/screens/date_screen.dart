// ignore_for_file: sized_box_for_whitespace

import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:intl/intl.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
// import 'package:share/share.dart';
import 'package:palette_generator/palette_generator.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:animated_box_decoration/animated_box_decoration.dart';

import '../providers/user_prefs.dart';
import '../providers/months.dart';
import '../providers/route_args.dart';
import '../providers/theme.dart';
import '../providers/fps.dart';

import '../widgets/drawer.dart';
// import '../widgets/play_button.dart';
import '../widgets/date_tile.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/bottom_sheet.dart';

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
/////////

class DateScreen extends StatefulWidget {
  const DateScreen({Key? key}) : super(key: key);

  static const routeName = '/date-screen';

  @override
  DateScreenState createState() => DateScreenState();
}

class DateScreenState extends State<DateScreen> {
  //For the ScrollablePositionedList
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  ItemScrollController itemScrollController = ItemScrollController();

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
  // String formattedAppBarTitle = "";
  // String appBarWesternMonthFR = "";
  // String appBarWesternMonthRS = "";
  // String appBarWesternMonthAS = "";
  // String appBarWolofMonth = "";
  // String appBarWolofalMonth = "";
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

  @override
  void initState() {
    UserPrefs prefsProvider = Provider.of<UserPrefs>(context, listen: false);
    userPrefs = prefsProvider.userPrefs;

    //The data - display 'infinite' list; here infinite being all dates in the data
    datesToDisplay = Provider.of<Months>(context, listen: false).dates;
    allMonths = Provider.of<Months>(context, listen: false).months;

    // currentMonthFirstDate = ValueNotifier(datesToDisplay[0]);

    //If already on low power setting, don't bother checking;
    //Also if user has one time chosen a power setting and knows where it is, don't check anymore

    // enableFpsMonitoring(); //for testing, always turns on fps monitoring
    if (userPrefs.shouldTestDevicePerformance!) enableFpsMonitoring();

    late DateScreenArgs args;

    // When first opening, there are no arguments, so go to current date using the argument format
    // if (ModalRoute.of(context)?.settings.arguments == null) {
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
      //It gives a little bounce and you can't scroll any further down.
      args = DateScreenArgs(
          date: lastDateInData.westernDate,
          month: lastDateInData.month,
          year: lastDateInData.year);
    }

    //This initializes with a value the month we initially open to.
    //If it's a 1, it will display the buttons, but if not, it will not show anyway
    int firstOfCurrentMonthIndex = datesToDisplay.indexWhere((element) =>
        element.year == args.year &&
        element.month == args.month &&
        element.westernDate == '1');

    currentMonthFirstDate =
        ValueNotifier(datesToDisplay[firstOfCurrentMonthIndex]);

    //This is the index of the initial date to show in that infinite list
    //This sets up the first date you see as that initialDateIndex but will be changed as we scroll
    initialScrollIndex = (datesToDisplay.indexWhere((element) =>
        args.year == element.year &&
        args.month == element.month &&
        args.date == element.westernDate)).toInt();

    //Get the initialDate as a DateTime
    initialDateTime = DateFormat('yyyy M d', 'fr_FR')
        .parse('${args.year} ${args.month} ${args.date}');
    //Then make it nice for the initial appBarTitle
    //To change format of title bar change both in didChangeDependencies & in main build
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

    appBarWesternMonthFR.value = currentMonth.monthFR;
    appBarWesternMonthRS.value = currentMonth.monthRS;
    appBarWesternMonthAS.value = currentMonth.monthAS;
    appBarWolofMonth.value = datesToDisplay[index].wolofMonthRS;
    appBarWolofalMonth.value = datesToDisplay[index].wolofMonthAS;

    currentMonthFirstDate.addListener(() {
      print('currentMonthFirstDate.addListener');
      if (Provider.of<UserPrefs>(context, listen: false)
          .userPrefs
          .changeThemeColorWithBackground!) {
        // setColor will refresh back to main.dart, so will automatically update the bg image, not setState necessary
        setColor();
      }
      // if the changeThemeColorWithBackground is off but backgroundImage on,
      //this will trigger the background change and is also needed even if
      //backgroundImage off to renew the verse info.
      else {
        print('setState in currentMonthFirstDate listener');
        setState(() {});
      }
    });

    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   print('didChangeDependencies');
  //   @override

  //   //We need context several places here so using this method rather than initState,
  //       //where there is no context - didChangeDependencies is initState with context

  //       /*
  //   In the initial version of the app we arrived here with route arguments.
  //   Following the 2020 version we're going to this screen being the intial screen,
  //   but leaving the logic in case in the future we want to navigate back to this screen
  //   using route args. A bit confusing reading through for the current version.
  //   So the below is the incoming args from the Navigator.of command
  //   from wherever we've arrived from, or possibly null.
  //   */

  //   super.didChangeDependencies();
  // }

  Future<void> enableFpsMonitoring() async {
    debugPrint('starting fps test');
    Fps.instance!.start();

    Fps.instance!.addFpsCallback((fpsInfo) {
      // print(fpsInfo);
      // Note below format of fpsInfo object
      // FpsInfo fpsInfo = FpsInfo(fps, totalCount, droppedCount, drawFramesCount);

      //If the reported fps is under 10 fps, not good. Add one observation to danger list, otherwise add one to good list
      (fpsInfo.fps < 10) ? fpsDangerZone++ : fpsWorking++;

      //If we've observed 10 bad fps settings:
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
    debugPrint('FPS consistently low: ask to enableLightAnimation');
    Fps.instance!.stop();
    //Set the preference
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('changeThemeColorWithBackground', false);
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    // setState(() {});

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
    print('setColor fired');
    // Image img = Image.network(currentChannel.image);
    String monthAsString = currentMonthFirstDate.value.month.toString();
    ImageProvider myBackground = AssetImage('assets/images/$monthAsString.jpg');

    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(myBackground);

    try {
      themeColor = paletteGenerator.dominantColor!.color;
    } catch (e) {
      debugPrint('problem setting palette generator color');
      themeColor = Colors.teal;
    }
    if (!mounted) return;
    Provider.of<ThemeModel>(context, listen: false).setThemeColor(themeColor);
  }

  @override
  void dispose() {
    currentMonthFirstDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserPrefs userPrefsListenTrue =
        Provider.of<UserPrefs>(context, listen: true).userPrefs;

    late int navigateToDateIndex; //this is for later on when the user navigates
    // int lastIndex = datesToDisplay.length - 1;
    final Size size = MediaQuery.of(context).size;
    final screenwidth = size.width;
    final screenheight = size.height;

    final Color overlayColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    final bool isPhone = (screenwidth + screenheight) <= 1400;

    // Column width for the name row
    late double contentColWidth;
    late double headerImageHeight;
    late EdgeInsets adaptiveMargin;

    //if big screen
    if (!isPhone) {
      contentColWidth = 600;
      headerImageHeight = screenheight / 3;
      // adaptiveMargin = EdgeInsets.symmetric(
      //     horizontal: (screenwidth - contentColWidth) / 2, vertical: 0);
      adaptiveMargin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5);
      //small screen
    } else if (isPhone) {
      contentColWidth = screenwidth - 10;
      headerImageHeight = 200;
      adaptiveMargin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    }

    print('date_screen build');

    // var themeProvider = Provider.of<ThemeModel>(context, listen: false);

    Color appBarItemColor = Theme.of(context).brightness == Brightness.light
        ? Colors.black87
        : Colors.white;

    TextStyle appBarMonthsStyle = Theme.of(context)
        .textTheme
        .titleLarge!
        .copyWith(fontFamily: "Harmattan", color: appBarItemColor);

    // Updates the appbar title with the month and shows or hides the play and share buttons
    Future<void> updateAfterNavigation({int? navigatedIndex}) async {
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
      //The + 1 is a hack accounting for the glass app bar
      var topIndexShown =
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
          navigateToDateIndex = datesToDisplay.length + 1;
        } else if (direction == 'backward') {
          navigateToDateIndex = 0;
        }
      }

      //Adjust for the glass app bar
      navigateToDateIndex = navigateToDateIndex - 1;
      //This uses the scrollcontroller to whisk us to the desired date
      itemScrollController.jumpTo(index: navigateToDateIndex);
      updateAfterNavigation(navigatedIndex: navigateToDateIndex);
    }

    Future pickDateToShow() async {
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
      updateAfterNavigation(navigatedIndex: navigateToIndex);
    }

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

    Widget monthRow() {
      late Row row;

      List<Widget> monthNameWidgets = [];

      double spaceAvailable = isPhone ? screenwidth : (size.width * .4) - 16;

      if (spaceAvailable > 360) {
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
              : EdgeInsets.only(left: (size.width * .6) + 8, right: 8),
          color: userPrefsListenTrue.glassEffects!
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondaryContainer,
          child: row);
    }

    Widget datesSection() {
      return SmoothAnimatedContainer(
        duration: const Duration(seconds: 2),
        curve: Curves.ease,
        height: double.infinity,
        width: double.infinity,
        decoration: userPrefsListenTrue.backgroundImage!
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/${currentMonthFirstDate.value.month.toString()}.jpg'),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(color: Theme.of(context).highlightColor),
        child: BackdropFilter(
          // This is not exactly as I want it, this is for the bg image - but in
          // widescreen view it makes the verses blurry.
          filter: isPhone
              ? ImageFilter.blur(sigmaX: 1, sigmaY: 5)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: userPrefs.backgroundImage!
                ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        overlayColor.withOpacity(.7),
                        overlayColor.withOpacity(.3)
                      ],
                      stops: const [0.1, .9],
                    ),
                  )
                : BoxDecoration(color: Theme.of(context).highlightColor),
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: NotificationListener(
                onNotification: (dynamic notification) {
                  if (notification is ScrollEndNotification) {
                    updateAfterNavigation();
                  }
                  return true;
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        //The 2.8 Flutter behavior is to not have mice grabbing and dragging - but we do want this in the web version of the app, so the custom scroll behavior here
                        behavior: MyCustomScrollBehavior()
                            .copyWith(scrollbars: false),
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
            ),
          ),
        ),
      );
    }

    Widget versesSection() {
      return MonthBottomSheet(
          currentDate: currentMonthFirstDate.value,
          monthData: allMonths,
          contentColWidth: contentColWidth,
          headerImageHeight: headerImageHeight,
          adaptiveMargin: adaptiveMargin,
          size: size,
          isPhone: isPhone,
          kIsWeb: kIsWeb);
    }

    return Scaffold(
      extendBodyBehindAppBar: isPhone ? true : false,
      //Theme + BackdropFilter gets the glass theme on the drawer
      drawerScrimColor: Colors.transparent,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          useMaterial3:
              false, //important! Material3 doesn't play nice with transparent drawers...
          // Set the transparency here

          canvasColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white.withOpacity(.5)
              : Colors.black.withOpacity(.5),
        ),
        child: BackdropFilter(
            filter: userPrefs.glassEffects!
                ? ImageFilter.blur(sigmaX: 50, sigmaY: 50)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: const MainDrawer()),
      ),

      appBar: glassAppBar(
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
              children: [datesSection(), versesSection()],
            )
          : Row(
              children: [
                Container(width: size.width * .6, child: versesSection()),
                Container(width: size.width * .4, child: datesSection()),
              ],
            ),
    );
  }
}
