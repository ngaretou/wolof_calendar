import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../providers/user_prefs.dart';

PreferredSize glassAppBar(
    {required BuildContext context,
    GlobalKey<ScaffoldState>? scaffoldStateKey,
    Widget? title,
    double height = 56, //56 normal app bar height but is overrideable
    required List<Widget> actions,
    Widget? extraRow}) {
      
  late Widget appBarToUse;

  UserPrefs userPrefs = Provider.of<UserPrefs>(context, listen: true).userPrefs;

  // This creates a custom appBar from a Row for color continuity when using an extra row
  if (scaffoldStateKey != null) {
    Theme.of(context).brightness == Brightness.light
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    List<Widget> replacementAppBarButtons = [
      IconButton(
          padding: const EdgeInsets.all(16),
          onPressed: () => scaffoldStateKey.currentState!.openDrawer(),
          icon: const Icon(Icons.menu)),
     if (title!=null)title,
      const Expanded(
          child: SizedBox(
        width: 10,
      ))
    ];

    replacementAppBarButtons.addAll(actions);

    appBarToUse = SafeArea(
      child: Column(
        children: [
          Expanded(child: Row(children: replacementAppBarButtons)),
          if (extraRow != null) extraRow
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
        actions: actions);
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
