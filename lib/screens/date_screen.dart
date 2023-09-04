import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:animated_box_decoration/animated_box_decoration.dart';

import '../providers/user_prefs.dart';
import '../providers/months.dart';
import '../providers/route_args.dart';
import '../providers/theme.dart';
import '../providers/fps.dart';

import '../widgets/drawer.dart';
import '../widgets/play_button.dart';
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
  //This is used just for the initial navigation on open
  int? initialScrollIndex;
  //Holders for the app bar title info that gets refreshed as the user navigates
  String formattedAppBarTitle = "";
  String appBarWesternMonthFR = "";
  String appBarWesternMonthRS = "";
  String appBarWesternMonthAS = "";
  String appBarWolofMonth = "";
  String appBarWolofalMonth = "";
  //this gets initialized so it can never be null but is really set below
  bool showMonthHeaderButtons = false;
  //used both for that initial navigation on open AND for the starting date for the date picker
  late DateTime initialDateTime;

  // the fade-in speed for the button animations in milliseconds
  final int fadeInSpeed = 300;
  //store the month that we'll grab the verses to play and share
  String monthToPlayAndShare = "";
  // late String monthToPlayAndShare;

  //the image to show in the background
  ValueNotifier<int> monthNumber = ValueNotifier(1);

  @override
  void initState() {
    UserPrefs userPrefs =
        Provider.of<UserPrefs>(context, listen: false).userPrefs;

    monthNumber.addListener(() {
      if (!userPrefs.lowPowerMode!) {
        setColor();
      }
    });

    //If already on low power setting, don't bother checking;
    //Also if user has one time chosen a power setting and knows where it is, don't check anymore

    // enableFpsMonitoring(); //for testing, always turns on fps monitoring
    if (userPrefs.shouldTestDevicePerformance!) enableFpsMonitoring();
    super.initState();
  }

  Future<void> enableFpsMonitoring() async {
    print('starting fps test');
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
    print('FPS consistently good: disable monitoring');
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    Fps.instance!.stop();
  }

  Future<void> enableLightAnimation() async {
    print('FPS consistently low: ask to enableLightAnimation');
    Fps.instance!.stop();
    //Set the preference
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('lowPowerMode', true);
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);

    // setState(() {});

    //Give the user a message and a chance to cancel
    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //   duration: Duration(seconds: 8),
    //   content: Icon(Icons.power),
    // Text(
    //   AppLocalizations.of(context).lowPowerModeMessage,
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
    // Image img = Image.network(currentChannel.image);
    ImageProvider myBackground = AssetImage(
        'assets/images/backgrounds/${monthNumber.value.toString()}.jpg');
    // ImageProvider(
    //     'assets/images/backgrounds/${imageNumber.toString()}.jpg');
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(myBackground);

    //   //get same color no matter what brightness or...
    try {
      themeColor = paletteGenerator.dominantColor!.color;
    } catch (e) {
      themeColor = Colors.teal;
    }
    if (!mounted) return;
    Provider.of<ThemeModel>(context, listen: false).setThemeColor(themeColor);

    //   //get different seed color depending on brightness
    //   try {
    //     if (themeModel.currentTheme!.brightness == Brightness.light) {
    //       accentColor = paletteGenerator.dominantColor!.color;
    //     } else {
    //       try {
    //         accentColor = paletteGenerator.darkVibrantColor!.color;
    //       } catch (e) {
    //         accentColor = paletteGenerator.dominantColor!.color;
    //       }
    //     }
    //   } catch (e) {
    //     accentColor = Colors.teal;
    //   }

    //   // await Future.delayed(const Duration(milliseconds: 50));

    // .setTheme(color: accentColor);
  }

  @override
  void didChangeDependencies() {
    @override

    // print('didChangeDependencies if is executing');

        //We need context several places here so using this method rather than initState,
        //where there is no context - didChangeDependencies is initState with context

        /*
    In the initial version of the app we arrived here with route arguments. 
    Following the 2020 version we're going to this screen being the intial screen, 
    but leaving the logic in case in the future we want to navigate back to this screen
    using route args. A bit confusing reading through for the current version.  
    So the below is the incoming args from the Navigator.of command 
    from wherever we've arrived from, or possibly null. 
    */

        late DateScreenArgs args;

    // When first opening, there are no arguments, so go to current date using the argument format
    if (ModalRoute.of(context)?.settings.arguments == null) {
      DateTime now = DateTime.now();
      String currentDate = DateFormat('d', 'fr_FR').format(now);
      String currentMonth = DateFormat('M', 'fr_FR').format(now);
      String currentYear = DateFormat('yyyy', 'fr_FR').format(now);

      //The data - display 'infinite' list; here infinite being all dates in the data
      datesToDisplay = Provider.of<Months>(context, listen: false).dates;

      //Before we open to today's date, check if today's date is in the data
      if (datesToDisplay.any((element) =>
          currentYear == element.year &&
          currentMonth == element.month &&
          currentDate == element.westernDate)) {
        //Now that we know current date, today, is in the data, open to today's date
        args = DateScreenArgs(
            date: currentDate, month: currentMonth, year: currentYear);
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
    }

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
    formattedAppBarTitle = args.year!;
    //This initializes with a value the month we initially open to.
    //If it's a 1, it will display the buttons, but if not, it will not show anyway
    monthToPlayAndShare = args.month!;

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

    appBarWesternMonthFR = currentMonth.monthFR;
    appBarWesternMonthRS = currentMonth.monthRS;
    appBarWesternMonthAS = currentMonth.monthAS;
    appBarWolofMonth = datesToDisplay[index].wolofMonthRS;
    appBarWolofalMonth = datesToDisplay[index].wolofMonthAS;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    monthNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late int navigateToDateIndex; //this is for later on when the user navigates
    // int lastIndex = datesToDisplay.length - 1;
    final Size size = MediaQuery.of(context).size;

    final screenwidth = MediaQuery.of(context).size.width;
    print('date_screen build');

    // var themeProvider = Provider.of<ThemeModel>(context, listen: false);
    UserPrefs userPrefs =
        Provider.of<UserPrefs>(context, listen: true).userPrefs;

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
      int? bottomIndex;

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
        //itemPositionsListener's 'first' and 'last' are relative to scroll direction.
        //This is how to get the scroll direction

        topIndex = min(itemPositionsListener.itemPositions.value.first.index,
                itemPositionsListener.itemPositions.value.last.index) +
            1;
        bottomIndex = max(itemPositionsListener.itemPositions.value.first.index,
            itemPositionsListener.itemPositions.value.last.index);
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

      late bool showHeaders;
      late String tempMonthToPlayAndShare;

      //Handle the first two cases in one expression:
      // topIndex-1 helps keep the button on screen as it's scrolling out of view
      if (topDate.westernDate == '1' ||
          datesToDisplay[topIndex - 1].westernDate == '1') {
        showHeaders = true;
        tempMonthToPlayAndShare = topDate.month;
      }

      //Here unfortunately we have a complicated if, but we are checking if there is a bottom index in play
      else if (bottomIndex != null &&
          //and then now we know it's not null we test if either is a 1
          (datesToDisplay[bottomIndex].westernDate == '1')) {
        showHeaders = true;
        tempMonthToPlayAndShare = datesToDisplay[bottomIndex]
            .month; //topDate.month is the western month
      } else {
        //in this case it's not a 1st of any months, so make sure the headers are hidden
        showHeaders = false;
        tempMonthToPlayAndShare = monthToPlayAndShare;
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
      if (showHeaders == true && navigatedIndex != null) {
        setState(() {
          showMonthHeaderButtons = false;
        });
      }

      // Timer(Duration(milliseconds: fadeInSpeed), () {
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

      monthToPlayAndShare = tempMonthToPlayAndShare;

      setState(() {
        formattedAppBarTitle = topDate.year;
        appBarWesternMonthFR = currentMonth.monthFR;
        appBarWesternMonthRS = currentMonth.monthRS;
        appBarWesternMonthAS = currentMonth.monthAS;
        appBarWolofMonth = datesToDisplay[index].wolofMonthRS;
        appBarWolofalMonth = datesToDisplay[index].wolofMonthAS;
        showMonthHeaderButtons = showHeaders;
      });

      monthNumber.value = int.parse(topDate.month);
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

    void adaptiveShare(String script) async {
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
      for (var element in monthData.verses) {
        // monthData.verses.forEach((element) {
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
      }

      //Put together the whole sharing string
      final String textToShare =
          '$name: $lineBreak $lineBreak $versesToShare https://sng.al/cal';

      //if it's not the web app, share using the device share function
      if (!kIsWeb) {
        Share.share(textToShare);
      } else {
        //If it's the web app version best way to share is probably email, so put the text to share in an email
        final String url = "mailto:?subject=Arminaatu Wolof&body=$textToShare";

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw 'Could not launch $url';
        }
      }
    }

    Widget monthNames(String data, TextAlign textAlign) {
      return Text(
        data,
        style: appBarMonthsStyle,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget monthRow() {
      late Row row;

      if (screenwidth > 344) {
        //larger screen
        row = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
          ],
        );
      } else {
        //smaller screen
        row = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            monthNames(appBarWolofMonth, TextAlign.left),
            const Text('/'),
            monthNames(appBarWolofalMonth, TextAlign.right)
          ],
        );
      }

      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: userPrefs.glassEffects!
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondaryContainer,
          child: row);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: const MainDrawer()),
      ),
      floatingActionButton: showMonthHeaderButtons
          ? PlayButton(
              file: monthToPlayAndShare,
            )
          : null,
      appBar: glassAppBar(
          context: context,
          title: formattedAppBarTitle,
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

            //Share button
            AnimatedOpacity(
              opacity: showMonthHeaderButtons ? 1.0 : 0.0,
              duration: Duration(milliseconds: fadeInSpeed),
              child: IconButton(
                  icon: const Icon(Icons.share),
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
                                      child: const Text("Wolof"),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        adaptiveShare('roman');
                                      }),
                                  TextButton(
                                      child: const Text(" وࣷلࣷفَلْ ",
                                          style: TextStyle(
                                              fontFamily: "Harmattan",
                                              fontSize: 22)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        adaptiveShare('arabic');
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
            ),
            //Navigate one month back
            IconButton(
                icon: const Icon(Icons.arrow_back_ios),
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
      body: ValueListenableBuilder(
          valueListenable: monthNumber,
          builder: (context, value, _) {
            // The regular AnimatedContainer does great animations except for the DecorationImage.
            // This pacakge provides smooth transitions for the background images.
            return Stack(children: [
              SmoothAnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.ease,
                height: double.infinity,
                width: double.infinity,
                decoration: userPrefs.backgroundImage!
                    ? BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/backgrounds/${value.toString()}.jpg'),
                          fit: BoxFit.cover,
                        ),
                      )
                    : BoxDecoration(color: Theme.of(context).highlightColor),
                child: BackdropFilter(
                  filter: userPrefs.glassEffects!
                      ? ImageFilter.blur(sigmaX: 1, sigmaY: 5)
                      : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
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
                                itemBuilder: (ctx, i) =>
                                    DateTile(currentDate: datesToDisplay[i]),
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
              MonthBottomSheet(size: size)
            ]);
          }),
    );
  }
}
