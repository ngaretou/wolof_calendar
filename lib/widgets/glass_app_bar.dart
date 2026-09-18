import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/user_prefs.dart';
import 'overflow_menu.dart';

PreferredSize glassAppBar({
  required BuildContext context,
  required bool isPhone,
  Widget? title,
  double height = 56, //56 normal app bar height but is overrideable
  required List<Widget> actions,
  Widget? extraRow,
}) {
  late Widget appBarToUse;

  UserPrefs userPrefs = Provider.of<UserPrefs>(
    context,
    listen: false,
  ).userPrefs;

  void openOverflowMenu(bool isPhone) {
    if (isPhone) {
      Navigator.push(context, transparentRoute(OverflowMenu(isPhone: isPhone)));
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 500, maxWidth: 400),
            child: AppMenuNavigator(isPhone: isPhone),
          ),
        ),
      );
    }
  }

  // This creates a custom appBar from a Row for color continuity when using an extra row
  if (extraRow != null) {
    // this is outdated as of SDK 36
    Theme.of(context).brightness == Brightness.light
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    List<Widget> replacementAppBarButtons = [
      IconButton(
        padding: const EdgeInsets.all(16),
        onPressed: () => openOverflowMenu(isPhone),
        icon: const Icon(Icons.menu),
      ),
      ?title,
      const Expanded(child: SizedBox(width: 10)),
    ];

    replacementAppBarButtons.addAll(actions);

    appBarToUse = SafeArea(
      child: Column(
        children: [
          Expanded(child: Row(children: replacementAppBarButtons)),
          extraRow,
        ],
      ),
    );
  } else {
    // This creates a normal appBar when not using an extra row
    appBarToUse = AppBar(
      // status bar w/clock/wifi connectivity etc
      systemOverlayStyle: Theme.of(context).brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      foregroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      title: title,
      actions: actions,
    );
  }

  return PreferredSize(
    preferredSize: Size(double.infinity, height),
    child: ClipRRect(
      child: BackdropFilter(
        filter: userPrefs.glassEffects!
            ? ImageFilter.blur(sigmaX: 40, sigmaY: 30)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          color: userPrefs.glassEffects!
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondaryContainer,
          child: appBarToUse,
        ),
      ),
    ),
  );
}

class GlassScaffold extends StatelessWidget {
  final String? title;
  final bool isPhone;
  final Widget child;
  const GlassScaffold({
    super.key,
    this.title,
    required this.isPhone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    UserPrefs userPrefs = Provider.of<UserPrefs>(
      context,
      listen: false,
    ).userPrefs;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: userPrefs.glassEffects!
          ? Colors.transparent
          : Theme.of(context).canvasColor,

      appBar: glassAppBar(
        isPhone: isPhone,
        context: context,
        title: title != null ? Text(title!) : null,
        actions: [],
      ),

      //If the width of the screen is greater or equal to 730 (whether or not is Phone is true)
      //show the wide view
      body: Container(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white12
            : Colors.black12,
        child: BackdropFilter(
          filter: userPrefs.glassEffects!
              ? ImageFilter.blur(sigmaX: 75, sigmaY: 75)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: userPrefs.glassEffects!
                ? Colors.transparent
                : Theme.of(context).canvasColor,
            child: child,
          ),
        ),
      ),
    );
  }
}

PageRouteBuilder transparentRoute(Widget page) {
  return PageRouteBuilder(
    opaque: false,
    pageBuilder: (BuildContext context, _, _) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),

    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.2),
      );

      final slideAnimation =
          Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: const Interval(0.2, 1.0)),
          );

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: slideAnimation, child: child),
      );
    },
  );
}

class AppMenuNavigator extends StatelessWidget {
  final bool isPhone;

  const AppMenuNavigator({super.key, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return transparentRoute(
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              leading: Builder(
                builder: (context) {
                  final rootNav = Navigator.of(context, rootNavigator: true);
                  return rootNav.canPop()
                      ? IconButton(
                          onPressed: rootNav.pop,
                          icon: Icon(Icons.close),
                        )
                      : SizedBox();
                },
              ),
            ),
            body: OverflowMenu(isPhone: isPhone),
          ),
        );
      },
    );
  }
}
