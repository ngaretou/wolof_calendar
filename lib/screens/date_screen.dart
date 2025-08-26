import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../providers/user_prefs.dart';
import '../providers/months.dart';
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

// enum NavType {
//   jumped,
//   scrolled,
// }

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
  int initialScrollIndex = 0;

  //Holders for the app bar title info that gets refreshed as the user navigates
  //Doing this with valuenotifiers saves lots of rebuilds
  ValueNotifier<String> formattedAppBarTitle = ValueNotifier("");
  ValueNotifier<String> appBarWesternMonthFR = ValueNotifier("");
  ValueNotifier<String> appBarWesternMonthRS = ValueNotifier("");
  ValueNotifier<String> appBarWesternMonthAS = ValueNotifier("");
  ValueNotifier<String> appBarWolofMonth = ValueNotifier("");
  ValueNotifier<String> appBarWolofalMonth = ValueNotifier("");

  //used both for that initial navigation on open AND for the starting date for the date picker
  DateTime initialDateTime = DateTime.now();

  // the fade-in speed for the button animations in milliseconds
  final int fadeInSpeed = 300;

  //store the first day of the month that we'll use for monthly headers
  late ValueNotifier<Date> currentMonthFirstDate;

  bool _isLoading = false;
  bool _hasMoreNext = true;
  bool _hasMorePrevious = true;

  @override
  void initState() {
    super.initState();
    userPrefs = Provider.of<UserPrefs>(context, listen: false).userPrefs;
    allMonths = Provider.of<Months>(context, listen: false).months;

    // enableFpsMonitoring(); //for testing, always turns on fps monitoring
    if (userPrefs.shouldTestDevicePerformance!) enableFpsMonitoring();

    datesToDisplay = Provider.of<Months>(context, listen: false).dates;

    // Set up the initial app bar values currentMonthFirstDate
    final String currentDate = DateFormat('d', 'fr_FR').format(initialDateTime);
    final String currentMonthString =
        DateFormat('M', 'fr_FR').format(initialDateTime);
    final String currentYear =
        DateFormat('yyyy', 'fr_FR').format(initialDateTime);
    DateTime startHere = initialDateTime;

    //Before we open to today's date, check if today's date is in the data
    if (datesToDisplay.any((element) =>
        currentYear == element.year &&
        currentMonthString == element.month &&
        currentDate == element.westernDate)) {
      //Now that we know current date, today, is in the data, open to today's date
      startHere = DateTime(int.parse(currentYear),
          int.parse(currentMonthString), int.parse(currentDate));
    } else {
      // print('today not in the data, going to last entry');
      //Get the last entry in the list
      Date lastDateInData = datesToDisplay.last;
      startHere = DateTime(
        int.parse(lastDateInData.year),
        int.parse(lastDateInData.month),
        int.parse(lastDateInData.westernDate),
      );
    }

    initialScrollIndex = ((datesToDisplay.indexWhere((element) =>
                startHere.year.toString() == element.year &&
                startHere.month.toString() == element.month &&
                startHere.day.toString() == element.westernDate)) -
            1)
        .toInt();

    currentMonthFirstDate = ValueNotifier(datesToDisplay[initialScrollIndex]);

    _updateAppBar(initialScrollIndex);

    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        final first = positions.first.index;

        final last = positions.last.index;

        if (min(first, last) < 10 && !_isLoading) {
          _loadPrevious();
        }

        if (max(first, last) > (datesToDisplay.length - 10) && !_isLoading) {
          _loadNext();
        }
      }
    });
  }

  void _loadNext() async {
    if (!_hasMoreNext) return;

    setState(() {
      _isLoading = true;
    });
    final hasMore =
        await Provider.of<Months>(context, listen: false).loadNextMonth();
    if (!hasMore) {
      setState(() {
        _hasMoreNext = false;
      });
    }
    setState(() {
      datesToDisplay = Provider.of<Months>(context, listen: false).dates;
      _isLoading = false;
    });
  }

  void _loadPrevious() async {
    if (!_hasMorePrevious || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final firstIndex = min(
        itemPositionsListener.itemPositions.value.first.index,
        itemPositionsListener.itemPositions.value.last.index);
    final oldListSize = datesToDisplay.length;

    final hasMore =
        await Provider.of<Months>(context, listen: false).loadPreviousMonth();

    if (mounted) {
      if (hasMore) {
        final newDates = Provider.of<Months>(context, listen: false).dates;
        final newListSize = newDates.length;
        final itemsAdded = newListSize - oldListSize;

        final newFirstIndex = firstIndex + itemsAdded;

        setState(() {
          datesToDisplay = newDates;
        });

        itemScrollController.jumpTo(index: newFirstIndex + 1);
      } else {
        setState(() {
          _hasMorePrevious = false;
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void moveMonths(String direction) {
    final topIndexShown = min(
        itemPositionsListener.itemPositions.value.first.index,
        itemPositionsListener.itemPositions.value.last.index);

    String currentYearDisplayed = (datesToDisplay[topIndexShown + 1].year);
    String currentMonthDisplayed = (datesToDisplay[topIndexShown + 1].month);
    late String goToMonth;
    late String goToYear;

    if (direction == 'forward') {
      if (currentMonthDisplayed != '12') {
        goToMonth = ((int.parse(currentMonthDisplayed)) + 1).toString();
        goToYear = currentYearDisplayed;
      } else if (currentMonthDisplayed == '12') {
        goToMonth = '1';
        goToYear = ((int.parse(currentYearDisplayed)) + 1).toString();
      }
    }

    if (direction == 'backward') {
      if (currentMonthDisplayed != '1') {
        goToMonth = ((int.parse(currentMonthDisplayed)) - 1).toString();
        goToYear = currentYearDisplayed;
      } else if (currentMonthDisplayed == '1') {
        goToMonth = '12';
        goToYear = ((int.parse(currentYearDisplayed)) - 1).toString();
      }
    }

    navigateToDate(DateTime(int.parse(goToYear), int.parse(goToMonth), 1));
  }

  Future<void> pickDateToShow() async {
    final monthsProvider = Provider.of<Months>(context, listen: false);
    final firstCalendarDate = monthsProvider.firstDate;
    final lastCalendarDate = monthsProvider.lastDate;

    final chosenDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(
          int.parse(firstCalendarDate.year),
          int.parse(firstCalendarDate.month),
          int.parse(firstCalendarDate.westernDate)),
      lastDate: DateTime(
          int.parse(lastCalendarDate.year),
          int.parse(lastCalendarDate.month),
          int.parse(lastCalendarDate.westernDate)),
      locale: const Locale("fr", "FR"),
    );

    if (chosenDate == null) {
      return;
    }
    navigateToDate(chosenDate);
  }

  void navigateToDate(DateTime date) {
    final monthsProvider = Provider.of<Months>(context, listen: false);
    final firstCalendarDate = DateTime(
        int.parse(monthsProvider.firstDate.year),
        int.parse(monthsProvider.firstDate.month),
        int.parse(monthsProvider.firstDate.westernDate));
    final lastCalendarDate = DateTime(
        int.parse(monthsProvider.lastDate.year),
        int.parse(monthsProvider.lastDate.month),
        int.parse(monthsProvider.lastDate.westernDate));

    if (date.isBefore(firstCalendarDate) || date.isAfter(lastCalendarDate)) {
      return; // Date is out of bounds, do nothing.
    }

    setState(() {
      _isLoading = true;
    });

    int indexToJumpTo = datesToDisplay.indexWhere((element) =>
        date.year.toString() == element.year &&
        date.month.toString() == element.month &&
        date.day.toString() == element.westernDate);

    if (indexToJumpTo != -1) {
      itemScrollController.jumpTo(
          index: indexToJumpTo == 0 ? 0 : indexToJumpTo - 1);
      _updateAppBar(indexToJumpTo);
      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      Provider.of<Months>(context, listen: false)
          .fetchInitialDates(date)
          .then((_) {
        if (!mounted) return;
        datesToDisplay.clear();
        datesToDisplay = Provider.of<Months>(context, listen: false).dates;

        initialScrollIndex = (datesToDisplay.indexWhere((element) =>
            element.year == date.year.toString() &&
            element.month == date.month.toString() &&
            element.westernDate == date.day.toString()));

        if (initialScrollIndex == -1) {
          initialScrollIndex = (datesToDisplay.length / 2).round();
        }

        final initialDate = datesToDisplay[initialScrollIndex];
        int firstOfCurrentMonthIndex = datesToDisplay.indexWhere((element) =>
            element.year == initialDate.year &&
            element.month == initialDate.month &&
            element.westernDate == '1');

        if (firstOfCurrentMonthIndex == -1) {
          firstOfCurrentMonthIndex = 0;
        }

        setState(() {
          currentMonthFirstDate =
              ValueNotifier(datesToDisplay[firstOfCurrentMonthIndex]);
          itemScrollController.jumpTo(index: initialScrollIndex - 1);
          _updateAppBar(initialScrollIndex);
          _isLoading = false;
          _hasMoreNext = true;
          _hasMorePrevious = true;
        });
      });
    }
  }

  void _updateAppBar(int index) {
    if (datesToDisplay.isEmpty || index >= datesToDisplay.length) return;

    Date topDate = datesToDisplay[index];
    Month currentMonth =
        allMonths.firstWhere((element) => element.monthID == topDate.month);

    int wolofIndex = index;
    while (datesToDisplay[wolofIndex].wolofMonthRS == "") {
      wolofIndex--;
    }

    formattedAppBarTitle.value = topDate.year;
    appBarWesternMonthFR.value = currentMonth.monthFR;
    appBarWesternMonthRS.value = currentMonth.monthRS;
    appBarWesternMonthAS.value = currentMonth.monthAS;
    appBarWolofMonth.value = datesToDisplay[wolofIndex].wolofMonthRS;
    appBarWolofalMonth.value = datesToDisplay[wolofIndex].wolofMonthAS;

    int firstOfCurrentMonthIndex = datesToDisplay.indexWhere((element) =>
        element.year == topDate.year &&
        element.month == topDate.month &&
        element.westernDate == '1');

    if (firstOfCurrentMonthIndex != -1) {
      currentMonthFirstDate =
          ValueNotifier(datesToDisplay[firstOfCurrentMonthIndex]);
    }
  }

  Future<void> enableFpsMonitoring() async {
    Fps.instance!.start();
    Fps.instance!.addFpsCallback((fpsInfo) {
      (fpsInfo.fps < 10) ? fpsDangerZone++ : fpsWorking++;
      if (fpsDangerZone > 5) enableLightAnimation();
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
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('changeThemeColorWithBackground', false);
    Provider.of<UserPrefs>(context, listen: false)
        .savePref('shouldTestDevicePerformance', false);
  }

  Future<void> setColor() async {
    String monthAsString = currentMonthFirstDate.value.month;
    ImageProvider myBackground = AssetImage('assets/images/$monthAsString.jpg');
    Brightness brightness = Theme.of(context).brightness;

    try {
      final newColorScheme = await ColorScheme.fromImageProvider(
          provider: myBackground, brightness: brightness);
      if (!mounted) return;
      Provider.of<ThemeModel>(context, listen: false).setTheme(newColorScheme);
    } catch (e) {
      debugPrint('problem setting palette generator color');
    }
  }

  @override
  void dispose() {
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
    datesToDisplay = Provider.of<Months>(context).dates;
    allMonths = Provider.of<Months>(context).months;

    final Size size = MediaQuery.of(context).size;
    final screenwidth = size.width;
    final screenheight = size.height;

    final double datePanelWidth = max(screenwidth * .4, 350);
    final double scripturePanelWidth = screenwidth - datePanelWidth;

    final Color overlayColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.grey;

    final bool isPhone =
        ((screenwidth + screenheight) <= 1400) || screenwidth < 750;

    late double contentColWidth;
    late double headerImageHeight;
    late EdgeInsets adaptiveMargin;

    if (!isPhone) {
      contentColWidth = 600;
      headerImageHeight = 275;
      adaptiveMargin = const EdgeInsets.symmetric(horizontal: 5, vertical: 5);
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
      double spaceAvailable = isPhone ? screenwidth : (datePanelWidth) - 16;

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
      if (datesToDisplay.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: NotificationListener(
          onNotification: (dynamic notification) {
            if (notification is UserScrollNotification) {
              final positions = itemPositionsListener.itemPositions.value;
              if (positions.isNotEmpty) {
                // fixes the problem where 'first' and 'last' are relative
                final first = positions.first.index;

                final last = positions.last.index;

                _updateAppBar(min(first, last));
              }
            }
            return true;
          },
          child: Column(
            children: [
              if (_isLoading) const CircularProgressIndicator(),
              Expanded(
                child: ScrollConfiguration(
                  behavior:
                      MyCustomScrollBehavior().copyWith(scrollbars: false),
                  child: ScrollablePositionedList.builder(
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    physics: const BouncingScrollPhysics(),
                    initialScrollIndex: initialScrollIndex,
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
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    Widget imageBackdrop({required Widget child}) {
      return ValueListenableBuilder(
        valueListenable: currentMonthFirstDate,
        child: child,
        builder: (context, value, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.ease,
            height: double.infinity,
            width: double.infinity,
            decoration: userPrefs.backgroundImage!
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
                            overlayColor.withAlpha(179),
                            overlayColor.withAlpha(77)
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
      if (datesToDisplay.isEmpty) {
        return Container();
      }
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
      drawerScrimColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white.withAlpha(26)
          : Colors.black.withAlpha(26),
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
            IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () => pickDateToShow()),
            IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                ),
                onPressed: () => moveMonths('backward')),
            IconButton(
              icon: Stack(
                alignment: const AlignmentDirectional(.0, .5),
                children: [
                  Text(
                    DateFormat('d', 'fr_FR').format(DateTime.now()),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onPressed: () {
                navigateToDate(DateTime.now());
              },
            ),
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

class SmoothAnimatedContainer extends StatefulWidget {
  final Widget child;
  final BoxDecoration decoration;
  final Duration duration;
  final Curve curve;
  final double height;
  final double width;

  const SmoothAnimatedContainer({
    super.key,
    required this.child,
    required this.decoration,
    required this.duration,
    required this.curve,
    required this.height,
    required this.width,
  });

  @override
  SmoothAnimatedContainerState createState() => SmoothAnimatedContainerState();
}

class SmoothAnimatedContainerState extends State<SmoothAnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Decoration> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = DecorationTween(
      begin: widget.decoration,
      end: widget.decoration,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(SmoothAnimatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.decoration != oldWidget.decoration) {
      _animation = DecorationTween(
        begin: oldWidget.decoration,
        end: widget.decoration,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: _animation.value,
          height: widget.height,
          width: widget.width,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
