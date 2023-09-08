import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../providers/user_prefs.dart';

PreferredSize glassAppBar(
    {required BuildContext context,
    required String title,
    double height = 56, //56 normal app bar height but is overrideable
    required List<Widget> actions,
    Widget? extraRow}) {
  UserPrefs userPrefs = Provider.of<UserPrefs>(context, listen: true).userPrefs;

  return PreferredSize(
    preferredSize: Size(double.infinity, height),
    child: ClipRRect(
      child: BackdropFilter(
        filter: userPrefs.glassEffects!
            ? ImageFilter.blur(sigmaX: 50, sigmaY: 50)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Column(
          children: [
            AppBar(
                // status bar w/clock/wifi connectivity etc
                systemOverlayStyle:
                    Theme.of(context).brightness == Brightness.light
                        ? SystemUiOverlayStyle.dark
                        : SystemUiOverlayStyle.light,
                foregroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                elevation: 0.0,
                backgroundColor: userPrefs.glassEffects!
                    ? Colors.transparent
                    : Theme.of(context).colorScheme.secondaryContainer,
                title: Text(title),
                actions: actions),
            if (extraRow != null) extraRow
          ],
        ),
      ),
    ),
  );
}
